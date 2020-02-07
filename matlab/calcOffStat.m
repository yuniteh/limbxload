function [featAll] = calcOffStat(subType)

subAll = loadSubs(subType,1);
fold = 10;
numLoads = 3;
numPos = 4;

disp('Calculating offline accuracies')

% initialize offline accuracy matrix
featAll = cell(size(subAll.subs,1),2,numLoads);
newFeat = true;

for subInd = 1:size(subAll.subs,1)
    w = cell(numPos,numLoads, fold);
    c = cell(numPos,numLoads, fold);
    
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
            for pos = 1:numPos
                if sum(params(:,1) == ld + 2) > 0
                    [train_stat, test_stat] = crossval(params(params(:,1) == ld+2 & params(:,3) == pos,2),fold);
                    
                    % TRAINING USING STATIC FEEDFORWARD DATA
                    stat_ind = params(:,1) == ld+2 & params(:,3) == pos;     % index for no load, pos 1 feedforward
                    cur_feat = feat(stat_ind,:);                            % features for no load, pos 1 feedforward
                    cur_params = params(stat_ind,:);                        % params for no load, pos 1 feedforward
                    
                    for test_ld = 1:numLoads
                        if sum(params(:,1) == test_ld+2) > 0
                            sup_ind = params(:,1) == test_ld+2 & params(:,3) ~= pos;                               % index for no load, all positions except pos 1
                                
                            acc = zeros(numPos, numClass);
                            for k_fold = 1:fold
                                train_feat = cur_feat(train_stat(k_fold,:),:);
                                train_params = cur_params(train_stat(k_fold,:),:);
                                if isempty(w{pos,ld,k_fold})
                                    [w{pos,ld,k_fold},c{pos,ld,k_fold}] = trainLDA(train_feat, train_params(:,2));
                                end
                                
                                if test_ld == ld
                                    test_feat = [cur_feat(test_stat(k_fold,:),:); feat(sup_ind,:)];
                                    test_params = [cur_params(test_stat(k_fold,:),:); params(sup_ind,:)];
                                else
                                    test_feat = feat(params(:,1) == test_ld + 2,:);
                                    test_params = params(params(:,1) == test_ld +2,:);
                                end
                                
                                % record position and class for confusion matrices
                                class_true = test_params(:,2);
                                pos_true = test_params(:,3);
                                
                                % train and classify
                                [class_out] = classifyLDA(test_feat,w{pos,ld,k_fold},c{pos,ld,k_fold});
                                
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
                            
                            featAll{subInd,pos,ld,test_ld} = featOut;
                            
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
