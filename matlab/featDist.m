function featDist(subType)
subAll = loadSubs(subType,1);
nPos = 4;
nLoad = 3;

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'));
        disp(subAll.subs{subInd})
        m_dist = cell(nLoad,nPos,max(params(:,2)));               % mahalanobis distance
        RI = nan(nLoad,nPos, max(params(:,2)));                 % repeatability index
        MSA = RI;                                           % mean semi-principal axis
        SI = nan(nLoad,nPos, max(params(:,2)));
        SI2 = nan(nLoad,nPos,max(params(:,2)));
        SI_class = SI;
        
        for load_i = 1:nLoad
            for pos = 1:nPos
                for cl = 1:max(params(:,2))
                    test_feat = feat(params(:,1) == load_i+2 & params(:,2) == cl & params(:,3) == pos,:);
                    stat_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == 1,:);
                    if ~isempty(stat_feat) && ~isempty(test_feat)
                        test_cen = mean(test_feat);         % testing data centroid
                        test_ax = 2.*std(test_feat);        % testing data semi-principal axis
                        stat_cen = mean(stat_feat);         % static data centroid
                        stat_ax = 2.*std(stat_feat);        % static data semi-principal axis
                        m_dist{load_i,pos,cl} = sqrt(mahal(test_feat,stat_feat));
                        RI(load_i,pos,cl) = modmahal(test_feat,stat_feat);
                        MSA(load_i,pos,cl) = geomean(test_ax);
                        
                        % SI calculation
                        for c = 1:max(params(:,2))
                            %if c ~= cl
                            SI_feat = feat(params(:,1) == 3 & params(:,2) == c & params(:,3) == 1,:);
                            SI_temp = modmahal(test_feat,SI_feat);
                            if SI_temp < SI(load_i,pos,cl) || isnan(SI(load_i,pos,cl))
                                if c ~= cl
                                    SI(load_i,pos,cl) = SI_temp;
                                end
                            end
                            if SI_temp < SI2(load_i,pos,cl) || isnan(SI2(load_i,pos,cl))
                                SI2(load_i,pos,cl) = SI_temp;
                                SI_class(load_i,pos,cl) = c;
                            end
                            %end
                        end
                    end
                end
            end
        end
        save([path '\train_data.mat'],'feat','params','m_dist','RI','MSA','SI','SI_class','SI2');
    end
    clearvars -except sub subInd nPos nLoad subAll subType
end

%%
subAll = loadSubs(subType,1);
nPos = 4;
nLoad = 3;
data_train = [];

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'));
        disp(subAll.subs{subInd})
        for load_i = 1:nLoad
            for pos = 1:nPos
                for cl = 1:max(params(:,2))
                    data_train = [data_train; subInd, load_i, pos, cl, RI(load_i,pos,cl), SI(load_i,pos,cl), MSA(load_i,pos,cl), SI_class(load_i,pos,cl), SI2(load_i,pos,cl)];
                end
            end
        end
    end
    clearvars -except subInd nPos nLoad subAll subType data_train
end

%%
RI_mat = cell(max(data_train(:,2)),1);
MSA_mat = RI_mat;
SI_c = cell(max(data_train(:,2)),max(data_train(:,3)));
SI_mat = RI_mat;

for load_i = 1:max(data_train(:,2))
    RI_mat{load_i} = nan(max(data_train(:,3)),max(data_train(:,4)));
    MSA_mat{load_i} = nan(max(data_train(:,3)),max(data_train(:,4)));
    SI_mat{load_i} = nan(max(data_train(:,3)),max(data_train(:,4)));
    for pos = 1:max(data_train(:,3))
        SI_c{load_i,pos} = zeros(max(data_train(:,4)));
        for cl = 1:max(data_train(:,4))
            ind = data_train(:,2) == load_i & data_train(:,3) == pos & data_train(:,4) == cl;
            RI_mat{load_i}(pos,cl) = nanmean(data_train(ind,5));
            MSA_mat{load_i}(pos,cl) = nanmean(data_train(ind,7));
            SI_mat{load_i}(pos,cl) = nanmean(data_train(ind,6));
            for c2 = 1:max(data_train(:,4))
                SI_c{load_i,pos}(cl,c2) = SI_c{load_i,pos}(cl,c2) + sum(data_train(ind,8) == c2);
            end
        end
    end
end
end
