function [featAll] = calcOff2Pos(subType)

subAll = loadSubs(subType,1);
fold = 2;
numLoads = 3;
numPos = 4;

disp('Calculating offline accuracies')

% initialize offline accuracy matrix
featAll = cell(size(subAll.subs,1),2,numLoads);
newFeat = true;

tr_mat = [1 4;1 3;2 3;3 4];

for subInd = 1:size(subAll.subs,1)
    w = cell(4,numLoads, fold);
    c = cell(4,numLoads, fold);
    
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'))
        
        if max(params(:,1)) > 5         % remove position 5 and load = 500g
            cut_ind = params(:,1) == 5;         % cut load = 500g
            params(cut_ind,:) = [];
            params(params(:,1) == 6,1) = 5;
            feat(cut_ind,:) = [];
        end
        if max(params(:,3)) > 4
            cut_ind = params(:,3) == 5;         % cut position 5
            params(cut_ind,:) = [];
            feat(cut_ind,:) = [];
        end
        group = unique(params(:,1));
        numClass = max(params(:,2));
        
        % create training and testing indices for feedforward static
        for ld = 1:numLoads
            for tr = 1:size(tr_mat,1);
                pos1 = tr_mat(tr,1);
                pos2 = tr_mat(tr,2);
                if sum(params(:,1) == ld + 2) > 0
                    [train_p1, test_p1] = crossval(params(params(:,1) == ld+2 & params(:,3) == pos1,2),fold);
                    [train_p2, test_p2] = crossval(params(params(:,1) == ld+2 & params(:,3) == pos2,2),fold);
                    
                    % TRAINING USING STATIC FEEDFORWARD DATA
                    p1_ind = params(:,1) == ld+2 & params(:,3) == pos1;     % index for no load, pos 1 feedforward
                    p1_feat = feat(p1_ind,:);                            % features for no load, pos 1 feedforward
                    p1_params = params(p1_ind,:);                        % params for no load, pos 1 feedforward
                    p2_ind = params(:,1) == ld+2 & params(:,3) == pos2;     % index for no load, pos 1 feedforward
                    p2_feat = feat(p2_ind,:);                            % features for no load, pos 1 feedforward
                    p2_params = params(p2_ind,:);                        % params for no load, pos 1 feedforward
                    
                    for test_ld = 1:numLoads
                        if sum(params(:,1) == test_ld+2) > 0
                            sup_ind = params(:,1) == test_ld+2 & params(:,3) ~= pos1 & params(:,3) ~= pos2;                               % index for no load, all positions except pos 1
                            
                            acc = zeros(numPos, numClass);
                            for k_fold = 1:fold
                                train_feat = [p1_feat(train_p1(k_fold,:),:); p2_feat(train_p2(k_fold,:),:)];
                                train_params = [p1_params(train_p1(k_fold,:),:); p2_params(train_p2(k_fold,:),:)];
                                if isempty(w{tr,ld,k_fold})
                                    [w{tr,ld,k_fold},c{tr,ld,k_fold}] = trainLDA(train_feat, train_params(:,2));
                                end
                                %                                     assignin('base','w',w)
                                %                                     assignin('base','c',c)
                                
                                
                                if test_ld == ld
                                    test_feat = [p1_feat(test_p1(k_fold,:),:); p2_feat(test_p2(k_fold,:),:); feat(sup_ind,:)];
                                    test_params = [p1_params(test_p1(k_fold,:),:); p2_params(test_p2(k_fold,:),:); params(sup_ind,:)];
                                else
                                    test_feat = feat(params(:,1) == test_ld + 2,:);
                                    test_params = params(params(:,1) == test_ld +2,:);
                                end
                                
                                % record position and class for confusion matrices
                                class_true = test_params(:,2);
                                pos_true = test_params(:,3);
                                
                                % train and classify
                                [class_out] = classifyLDA(test_feat,w{tr,ld,k_fold},c{tr,ld,k_fold});
                                
                                % combine classification results
                                for p_ind = 1:numPos
                                    for c_ind = 1:numClass
                                        test_ind = pos_true == p_ind & class_true == c_ind;
                                        acc(p_ind,c_ind) = sum(class_true(test_ind) == class_out(test_ind))/sum(test_ind);
                                    end
                                end
                                
                                % calculate feature space metrics
                                featTemp = calcFeatDist([train_params train_feat],[test_params test_feat]);
                                featTemp.acc = acc;
                                
                                % running average of feature space metrics
                                f = fieldnames(featTemp);
                                for names = 1:length(f)
                                    if newFeat
                                        featOut.(f{names}) = zeros(size(featTemp.(f{names})));
                                    end
                                    featOut.(f{names}) = featOut.(f{names}) + featTemp.(f{names})./fold;
                                end
                                newFeat = false;
                            end
                            
                            featAll{subInd,tr,ld,test_ld} = featOut;
                            
                            clearvars class_out class_true pos_true featOut
                            newFeat = true;
                        end
                    end
                end
            end
        end
    end
end
end
