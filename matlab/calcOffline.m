function [cm_all, acc_all, sub_rate, FS] = calcOffline(subType)

subAll = loadSubs(subType,1);
fold = 1;
numLoads = 3;
numPos = 4;

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
sub_rate = cell(size(subAll.subs,1),2);
FS = cell(size(subAll.subs,1),1);

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'))
        
        feat_full = feat;
        params_full = params;
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
        nPos = max(params(:,3));
        nLoad = max(params(:,1) - 2);
        
        % create training and testing indices for feedforward static
        if sum(params(:,1) == 3) > 0
            skip = 0;
            [train_stat, test_stat] = crossval(params(params(:,1) == 3 & params(:,3) == 1,2),fold);
        else
            skip = 1;
        end
        
        % create training and testing indices for feedforward dynamic
        nsamps = (size(train_stat,2)+size(test_stat,2))/max(params(:,2));           % number of samples from feedforward static
        for i = 1:max(params(:,2))
            temp_ind = find(params(:,1) == 2 & params(:,2) == i);                   % index for dynamic training in current DOF
            temp_perm = temp_ind(randperm(length(temp_ind),length(temp_ind)));      % shuffle dynamic training data
            temp_class(:,i) = temp_perm(1:nsamps);                                  % grab indices for same number of samples as feedforward static
        end
        class_ind = reshape(temp_class,[],1);
        [train_dyn, test_dyn] = crossval(params(class_ind,2),fold);                 % create crossval indices for dynamic training
        clear temp_class
        
        RI_all = cell(nLoad,1);
        MSA_te_all = RI_all;
        SI_te_all = RI_all;
        
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
                    [w,c] = trainLDA(feat_temp(train_ind(i_fold,:),:), true_temp(train_ind(i_fold,:),2));
                    [class_out(i_fold,:)] = classifyLDA(feat_temp(test_ind(i_fold,:),:),w,c);
                    class_true(i_fold,:) = true_temp(test_ind(i_fold,:),2);
                end
                class_true = reshape(class_true,1,[]);
                class_out = reshape(class_out,1,[]);
                cm = confusionmat(class_true,class_out);
                sub_rate{subInd,te_type} = NaN(numPos,numLoads);
                
                % ACCURACY FOR FEEDFORWARD DATA
            else
                for tr_type = 1:2               % 1 = static, 2 = dynamic
                    class_out = zeros(sum(ind),fold);
                    class_true = class_out;                                             % initialize testing data ground truth
                    pos = class_out;
                    % TRAINING USING STATIC FEEDFORWARD DATA
                    if tr_type == 1
                        if skip ~= 1                                            % skip if data was corrupted
                            stat_ind = params(:,1) == 3 & params(:,3) == 1;     % index for no load, pos 1 feedforward
                            cur_feat = feat(stat_ind,:);                        % features for no load, pos 1 feedforward
                            cur_params = params(stat_ind,:);                    % params for no load, pos 1 feedforward
                            
                            % IF CLASSIFYING NO LOAD FEEDFORWARD CONDITION
                            if te_type == 3
                                sup_ind = ind & params(:,3) ~= 1;                               % index for no load, all positions except pos 1
                                class_out = zeros(size(test_stat,2) + sum(sup_ind),fold);       % initialize testing data classifier output
                                class_true = class_out;                                             % initialize testing data ground truth
                                pos = class_out;                                                    % initialize testing data position matrix
                            end
                            
                            
                            RI = zeros(nPos,nClass);
                            MSA_te = RI;
                            SI_te = RI;
                            MSA_tr = zeros(1,nClass);
                            SI_tr = MSA_tr;
                            
                            % cross validation
                            for i_fold = 1:fold
                                train_feat = cur_feat(train_stat(i_fold,:),:);
                                train_params = cur_params(train_stat(i_fold,:),:);
                                if te_type == 3
                                    test_feat = [cur_feat(test_stat(i_fold,:),:); feat(sup_ind,:)];
                                    test_params = [cur_params(test_stat(i_fold,:),:); params(sup_ind,:)];
                                else
                                    test_feat = feat(ind,:);
                                    test_params = params(ind,:);
                                end
                                
                                % record position and class for confusion matrices
                                class_true(:,i_fold) = test_params(:,2);
                                pos(:,i_fold) = test_params(:,3);
                                
                                % train and classify
                                [w,c] = trainLDA(train_feat, train_params(:,2));
                                [class_out(:,i_fold)] = classifyLDA(test_feat,w,c);
                                
                                % calculate feature space metrics
                                [tmp_RI, tmp_MSA_tr, tmp_MSA_te, tmp_SI_tr, tmp_SI_te] = ...
                                    calcFeatDist([train_params train_feat],[test_params test_feat]);
                                
                                RI = RI + tmp_RI./fold;
                                MSA_te = MSA_te + tmp_MSA_te./fold;
                                SI_te = SI_te + tmp_SI_te./fold;
                                MSA_tr = MSA_tr + tmp_MSA_tr./fold;
                                SI_tr = SI_tr + tmp_SI_tr./fold;
                            end
                            RI_all{te_type - 2} = RI;
                            MSA_te_all{te_type - 2} = MSA_te;
                            SI_te_all{te_type - 2} = SI_te;
                        end
                        
                        % TRAINING USING DYNAMIC DATA
                    elseif tr_type == 2
                        for i_fold = 1:fold
                            train_feat = feat(class_ind(train_dyn),:);
                            train_params = params(class_ind(train_dyn),:);
                            test_feat = feat(ind,:);
                            test_params = params(ind,:);
                            
                            % record position and class for confusion matrices
                            class_true(:,i_fold) = test_params(:,2);
                            pos(:,i_fold) = test_params(:,2);
                            
                            % train and classify
                            [w,c] = trainLDA(train_feat,train_params(:,2));
                            [class_out(:,i_fold)] = classifyLDA(test_feat,w,c);
                        end
                        %                     k_max = 1;
                        %                     train_ind = params(:,1) == ii;
                        %                     [w,c] = trainLDA(feat(train_ind,:), params(train_ind,2));
                        %                     pos = params(ind,3);
                        %                     class_true = params(ind,2);
                        %                     class_out = classifyLDA(feat(ind,:),w,c);
                    end
                    
                    % COMBINING RESULTS ACROSS SUBJECTS
                    if skip ~= 1
                        for j = 1:max(params(:,3))
                            for k = 1:fold
                                pos_ind = pos(:,k) == j;
                                count = sum(class_out(pos_ind,k) == class_true(pos_ind,k));
                                acc_all{tr_type,1}(te_type - 2,j) = acc_all{tr_type,1}(te_type-2,j) + count;
                                acc_all{tr_type,2}(te_type - 2,j) = acc_all{tr_type,2}(te_type-2,j) + sum(pos_ind);
                                sub_rate{subInd,tr_type}(j,te_type - 2) = count/sum(pos_ind);
                            end
                        end
                    end
                    clear class_out class_true pos
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
        FS{subInd}.RI = RI_all;
        FS{subInd}.MSA_tr = MSA_tr;
        FS{subInd}.MSA_te = MSA_te_all;
        FS{subInd}.SI_tr = SI_tr;
        FS{subInd}.SI_te = SI_te_all;
    end
end
for i = 1:2
    acc_all{i,1} = flipud(acc_all{i,1});
    acc_all{i,2} = flipud(acc_all{i,2});
end
end
