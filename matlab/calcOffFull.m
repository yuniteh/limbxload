function [cm_all, acc_all, sub_rate, featAll] = calcOffFull(subType)
%% No cross validation, using actual training data

subAll = loadSubs(subType,1);
fold = 10;
numLoads = 3;
numPos = 4;
numTr = 2;

disp('Calculating offline accuracies')

% initialize confusion matrices
cm_temp = zeros(7,7);
cm_all = cell(numLoads + 2,1);
for i = 1:length(cm_all)
    cm_all{i} = cm_temp;
end
acc_all = cell(2,numLoads);
tot_all = acc_all;

% initialize offline accuracy matrix
sub_rate = cell(size(subAll.subs,1),2,numLoads);
featAll = cell(size(subAll.subs,1),2,numLoads);

for subInd = 1:size(subAll.subs,1)
    sub_rate{subInd,1} = NaN(numPos,numLoads);
    sub_rate{subInd,2} = NaN(numPos,numLoads);
    w = cell(numTr, fold);
    c = cell(numTr, fold);
    train_feat = w;
    train_params = w;
    
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
        nClass = max(params(:,2));
        
        for train = 1:numTr
            ind = params(:,1) == train;
            train_feat{train} = feat(ind,:);
            train_params{train} = params(ind,:);
            [w{train},c{train}] = trainLDA(train_feat{train},train_params{train}(:,2));
        end
        
        % loop through classifying static, dynamic, feedforward data
        for te_type = group'
            ind = params(:,1) == te_type;         % index for current testing data group
            if te_type < 3                        % accuracy within static and dynamic training sets, not v important
                test_feat = feat(ind,:);
                test_params = params(ind,:);
                
                class_out = classifyLDA(test_feat,w{te_type},c{te_type});
                class_true = test_params(:,2);
                
                cm = confusionmat(class_true,class_out);
                
                % ACCURACY FOR FEEDFORWARD DATA
            else
                for tr_type = 1:numTr               % 1 = static, 2 = dynamic
                    
                    % cross validation
                    test_feat = feat(ind,:);
                    test_params = params(ind,:);
                    
                    % record position and class for confusion matrices
                    class_true = test_params(:,2);
                    pos = test_params(:,3);
                    
                    % train and classify
                    class_out = classifyLDA(test_feat,w{tr_type},c{tr_type});
                    
                    % calculate feature space metrics
                    featOut = calcFeatDist([train_params{tr_type} train_feat{tr_type}],[test_params test_feat]);
                    
                    % COMBINING RESULTS ACROSS SUBJECTS
                    for j = 1:max(params(:,3))
                        for k = 1:max(params(:,2))
                            pos_ind = pos == j & class_true == k;
                            count = sum(class_out(pos_ind) == class_true(pos_ind));
                            acc_all{tr_type,te_type-2}(j,k) = count;
                            tot_all{tr_type,te_type-2}(j,k) = sum(pos_ind);
                            sub_rate{subInd,tr_type,te_type-2}(j,k) = count/sum(pos_ind);
                        end
                    end
                    % combine feats
                    featAll{subInd,tr_type,te_type-2} = featOut;
                    
                    clearvars class_out class_true pos featOut
                end
            end
            cm_temp = cm_all{te_type};
            for j = 1:size(cm,1)
                for k = 1:size(cm,2)
                    cm_temp(j,k) = cm_temp(j,k) + cm(j,k);
                end
            end
            cm_all{te_type} = cm_temp;
        end
    end
end
end
