function [cm_all, acc_all, sub_rate, featAll] = calcOffline(subType)

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
acc_all = cell(2,2);
for i = 1:length(acc_all)
    acc_all{i,1} = zeros(numLoads, numPos);
    acc_all{i,2} = zeros(numLoads, numPos);
end

% initialize offline accuracy matrix
sub_rate = cell(size(subAll.subs,1),2,numLoads);
featAll = cell(size(subAll.subs,1),2,numLoads);
newFeat = true;

for subInd = 1:size(subAll.subs,1)
    w = cell(numTr, fold);
    c = cell(numTr, fold);
    train_feat = w;
    train_params = w;
    
    sub = subAll.subs{subInd};
    %path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    path = ['C:\Users\yteh\Documents\git\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
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
        
        % create training and testing indices for feedforward static
        if sum(params(:,1) == 3) > 0
            tr_start = 1;
            [train_stat, test_stat] = crossval(params(params(:,1) == 3 & params(:,3) == 1,2),fold);
            
            % TRAINING USING STATIC FEEDFORWARD DATA
            stat_ind = params(:,1) == 3 & params(:,3) == 1;     % index for no load, pos 1 feedforward
            cur_feat = feat(stat_ind,:);                        % features for no load, pos 1 feedforward
            cur_params = params(stat_ind,:);                    % params for no load, pos 1 feedforward
        else
            tr_start = 2;
        end
        
        % create training and testing indices for feedforward dynamic
        nsamps = (size(train_stat,2)+size(test_stat,2))/nClass;           % number of samples from feedforward static
        temp_class = nan(nsamps,nClass);
        for i = 1:nClass
            temp_ind = find(params(:,1) == 2 & params(:,2) == i);                   % index for dynamic training in current DOF
            temp_perm = temp_ind(randperm(length(temp_ind),length(temp_ind)));      % shuffle dynamic training data
            temp_class(:,i) = temp_perm(1:nsamps);                                  % grab indices for same number of samples as feedforward static
        end
        class_ind = reshape(temp_class,[],1);
        [train_dyn, test_dyn] = crossval(params(class_ind,2),fold);                 % create crossval indices for dynamic training
        
        for k_fold = 1:fold
            if tr_start == 1
                train_feat{1,k_fold} = cur_feat(train_stat(k_fold,:),:);
                train_params{1,k_fold} = cur_params(train_stat(k_fold,:),:);
                [w{1,k_fold},c{1,k_fold}] = trainLDA(train_feat{1,k_fold}, train_params{1,k_fold}(:,2));
            end
            train_feat{2,k_fold} = feat(class_ind(train_dyn(k_fold,:)),:);
            train_params{2,k_fold} = params(class_ind(train_dyn(k_fold,:)),:);
            [w{2,k_fold},c{2,k_fold}] = trainLDA(train_feat{2,k_fold}, train_params{2,k_fold}(:,2));
        end
        clear temp_class
        
        % loop through classifying static, dynamic, feedforward data
        for te_type = group'
            ind = params(:,1) == te_type;         % index for current testing data group
            if te_type < 3                        % accuracy within static and dynamic training sets, not v important
                feat_temp = feat(ind,:);
                true_temp = params(ind,:);
                [train_ind, test_ind] = crossval(params(ind,2),fold);
                
                class_out = zeros(fold, size(test_ind,2));
                class_true = class_out;
                for i_fold = 1:fold
                    %                     [w1,c1] = trainLDA(feat_temp(train_ind(i_fold,:),:), true_temp(train_ind(i_fold,:),2));
                    %                     [class_out(i_fold,:)] = classifyLDA(feat_temp(test_ind(i_fold,:),:),w1,c1);
                    %                     class_true(i_fold,:) = true_temp(test_ind(i_fold,:),2);
                end
                class_true = reshape(class_true,1,[]);
                class_out = reshape(class_out,1,[]);
                cm = confusionmat(class_true,class_out);
                
            % ACCURACY FOR FEEDFORWARD DATA
            else
                for tr_type = tr_start:numTr               % 1 = static, 2 = dynamic
                    if tr_type == 1 && te_type == 3
                        % IF CLASSIFYING NO LOAD FEEDFORWARD CONDITION
                        sup_ind = ind & params(:,3) ~= 1;                               % index for no load, all positions except pos 1
                        class_out = zeros(size(test_stat,2) + sum(sup_ind),fold);       % initialize testing data classifier output
                        class_true = class_out;                                             % initialize testing data ground truth
                        pos = class_out;                                                    % initialize testing data position matrix
                    else
                        class_out = zeros(sum(ind),fold);
                        class_true = class_out;                                             % initialize testing data ground truth
                        pos = class_out;
                    end
                    
                    % cross validation
                    for i_fold = 1:fold
                        test_feat = feat(ind,:);
                        test_params = params(ind,:);
                        % STATIC TRAINING
                        if tr_type == 1 && te_type == 3
                            test_feat = [cur_feat(test_stat(i_fold,:),:); feat(sup_ind,:)];
                            test_params = [cur_params(test_stat(i_fold,:),:); params(sup_ind,:)];
                        end
                        
                        % record position and class for confusion matrices
                        class_true(:,i_fold) = test_params(:,2);
                        pos(:,i_fold) = test_params(:,3);
                        
                        % train and classify
                        [class_out(:,i_fold)] = classifyLDA(test_feat,w{tr_type,i_fold},c{tr_type,i_fold});
                        
                        % calculate feature space metrics
                        featTemp = calcFeatDist([train_params{tr_type,i_fold} train_feat{tr_type,i_fold}],[test_params test_feat]);
                        
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
                    
                    % COMBINING RESULTS ACROSS SUBJECTS
                    for j = 1:max(params(:,3))
                        for dof = 1:max(params(:,2))
                            tot_ind = 0;
                            tot_count = 0;
                            for k = 1:fold
                                pos_ind = pos(:,k) == j & class_true(:,k) == dof;
                                tot_ind = tot_ind + sum(pos_ind);
                                count = sum(class_out(pos_ind,k) == class_true(pos_ind,k));
                                tot_count = tot_count + count;
                                acc_all{tr_type,1}(te_type - 2,j) = acc_all{tr_type,1}(te_type-2,j) + count;
                                acc_all{tr_type,2}(te_type - 2,j) = acc_all{tr_type,2}(te_type-2,j) + sum(pos_ind);
                                
                            end
                            sub_rate{subInd,tr_type,te_type - 2}(j,dof) = tot_count/tot_ind;
                        end
                    end
                    % combine feats
                    featAll{subInd,tr_type,te_type-2} = featOut;
                    
                    clearvars class_out class_true pos featOut
                    newFeat = true;
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
for i = 1:2
    acc_all{i,1} = flipud(acc_all{i,1});
    acc_all{i,2} = flipud(acc_all{i,2});
end
end
