function [cm_all, acc_all, sub_rate] = calcOffline(subType)
% cval = 0, no cross validation, use full static training data
% cval = 1, cross validation using same day static training data
subAll = loadSubs(subType,1);
win = 200;
fold = 10;
if strcmp(subType,'AB')
    numLoads = 3;
    numPos = 4;
    loads = [0 400 600];
else
    numLoads = 3;
    numPos = 4;
    loads = [0 400 600];
end

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

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'))
        if strcmp(subType,'AB')         % remove position 5 and load = 500g
            ind = params(:,1) == 5;
            params(ind,:) = [];
            params(params(:,1) == 6,1) = 5;
            feat(ind,:) = [];
            ind = params(:,3) == 5;
            params(ind,:) = [];
            feat(ind,:) = [];
        end
        group = unique(params(:,1));
        
        % create training and testing indices for feedforward static
        if sum(params(:,1) == 3) > 0
            skip = 0;
            [train_stat, test_stat] = crossval(params(params(:,1) == 3 & params(:,3) == 1,2),fold);
        else
            skip = 1;
        end
        
        % create training and testing indices for feedforward dynamic
        nsamps = (size(train_stat,2)+size(test_stat,2))/max(params(:,2));
        for i = 1:max(params(:,2))
            temp_ind = find(params(:,1) == 2 & params(:,2) == i);
            temp_perm = temp_ind(randperm(length(temp_ind),length(temp_ind)));
            temp_class(:,i) = temp_perm(1:nsamps);
        end
        class_ind = reshape(temp_class,[],1);
        [train_dyn, test_dyn] = crossval(params(class_ind,2),fold);
        clear temp_class
        for i = group'
            ind = params(:,1) == i;
            if i < 3
                feat_temp = feat(ind,:);
                true_temp = params(ind,:);
                [train_ind, test_ind] = crossval(params(ind,2),fold);
                class_out = zeros(fold, size(test_ind,2));
                class_true = class_out;
                for j = 1:fold
                    [w,c] = trainLDA(feat_temp(train_ind(j,:),:), true_temp(train_ind(j,:),2));
                    [class_out(j,:)] = classifyLDA(feat_temp(test_ind(j,:),:),w,c);
                    class_true(j,:) = true_temp(test_ind(j,:),2);
                end
                class_true = reshape(class_true,1,[]);
                class_out = reshape(class_out,1,[]);
                cm = confusionmat(class_true,class_out);
                sub_rate{subInd,i} = NaN(numPos,numLoads);
            else
                for ii = 1:2 % 1 = static, 2 = dynamic
                    if ii == 1  % use cross validation for static training
                        if skip ~= 1    % skip if data was corrupted
                            k_max = fold;
                            stat_ind = params(:,1) == 3 & params(:,3) == 1;
                            cur_feat = feat(stat_ind,:);
                            cur_params = params(stat_ind,:);
                            if i == 3
                                sup_ind = ind & params(:,3) ~= 1;
                                class_out = zeros(size(test_stat,2) + sum(sup_ind),fold);
                                class_true = class_out;
                                pos = class_out;
                                for j = 1:fold
                                    test_feat = [cur_feat(test_stat(j,:),:); feat(sup_ind,:)];
                                    pos(:,j) = [cur_params(test_stat(j,:),3); params(sup_ind,3)];
                                    [w,c] = trainLDA(cur_feat(train_stat(j,:),:), cur_params(train_stat(j,:),2));
                                    [class_out(:,j)] = classifyLDA(test_feat,w,c);
                                    class_true(:,j) = [cur_params(test_stat(j,:),2); params(sup_ind,2)];
                                end
                            else
                                
                                class_out = zeros(sum(ind),fold);
                                class_true = class_out;
                                pos = class_out;
                                for j = 1:fold
                                    [w,c] = trainLDA(cur_feat(train_stat(j,:),:), cur_params(train_stat(j,:),2));
                                    [class_out(:,j)] = classifyLDA(feat(ind,:),w,c);
                                    class_true(:,j) = params(ind,2);
                                    pos(:,j) = params(ind,3);
                                end
                            end
                        end
                    else
                        k_max = fold;
                        for j = 1:fold
                            train_feat = feat(class_ind(train_dyn),:);
                            [w,c] = trainLDA(train_feat,params(class_ind(train_dyn),2));
                            [class_out(:,j)] = classifyLDA(feat(ind,:),w,c);
                            class_true(:,j) = params(ind,2);
                            pos(:,j) = params(ind,3);
                        end
                        %                     k_max = 1;
                        %                     train_ind = params(:,1) == ii;
                        %                     [w,c] = trainLDA(feat(train_ind,:), params(train_ind,2));
                        %                     pos = params(ind,3);
                        %                     class_true = params(ind,2);
                        %                     class_out = classifyLDA(feat(ind,:),w,c);
                    end
                    if skip ~= 1
                        for j = 1:max(params(:,3))
                            for k = 1:k_max
                                pos_ind = pos(:,k) == j;
                                count = sum(class_out(pos_ind,k) == class_true(pos_ind,k));
                                acc_all{ii,1}(i - 2,j) = acc_all{ii,1}(i-2,j) + count;
                                acc_all{ii,2}(i - 2,j) = acc_all{ii,2}(i-2,j) + sum(pos_ind);
                                sub_rate{subInd,ii}(j,i - 2) = count/sum(pos_ind);
                            end
                        end
                    end
                    clear class_out class_true pos
                end
            end
            cm_temp = cm_all{i};
            for j = 1:size(cm,1)
                for k = 1:size(cm,2)
                    cm_temp(j,k) = cm_temp(j,k) + cm(j,k);
                end
            end
            cm_all{i} = cm_temp;
        end  
    end
end
for i = 1:2
    acc_all{i,1} = flipud(acc_all{i,1});
    acc_all{i,2} = flipud(acc_all{i,2});
end
end
