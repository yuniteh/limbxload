
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
        SI_class = SI;
        for load = 1:nLoad
            for pos = 1:nPos
                for cl = 1:max(params(:,2))
                    test_feat = feat(params(:,1) == load+2 & params(:,2) == cl & params(:,3) == pos,:);
                    stat_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == 1,:);
                    if ~isempty(stat_feat) && ~isempty(test_feat)
                        test_cen = mean(test_feat);         % testing data centroid
                        test_ax = 2.*std(test_feat);        % testing data semi-principal axis
                        stat_cen = mean(stat_feat);         % static data centroid
                        stat_ax = 2.*std(stat_feat);        % static data semi-principal axis
                        m_dist{load,pos,cl} = sqrt(mahal(test_feat,stat_feat));
                        RI(load,pos,cl) = modmahal(test_feat,stat_feat);
                        MSA(load,pos,cl) = geomean(test_ax);
                        
                        % SI calculation
                        for c = 1:max(params(:,2))
                            %if c ~= cl
                            SI_feat = feat(params(:,1) == 3 & params(:,2) == c & params(:,3) == 1,:);
                            SI_temp = modmahal(test_feat,SI_feat);
                            if SI_temp < SI(load,pos,cl) || isnan(SI(load,pos,cl))
                                if c ~= cl
                                    SI(load,pos,cl) = SI_temp;
                                end
                                SI_class(load,pos,cl) = c;
                            end
                            %end
                        end
                    end
                end
            end
        end
        save([path '\train_data.mat'],'feat','params','m_dist','RI','MSA','SI','SI_class');
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
        for load = 1:nLoad
            for pos = 1:nPos
                for cl = 1:max(params(:,2))
                    data_train = [data_train; subInd, load, pos, cl, RI(load,pos,cl), SI(load,pos,cl), MSA(load,pos,cl), SI_class(load,pos,cl)];
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

for load = 1:max(data_train(:,2))
    RI_mat{load} = nan(max(data_train(:,3)),max(data_train(:,4)));
    MSA_mat{load} = nan(max(data_train(:,3)),max(data_train(:,4)));
    for pos = 1:max(data_train(:,3))
        SI_c{load,pos} = zeros(max(data_train(:,4)));
        for cl = 1:max(data_train(:,4))
            ind = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) == cl;
            RI_mat{load}(pos,cl) = nanmean(data_train(ind,5));
            MSA_mat{load}(pos,cl) = nanmean(data_train(ind,7));
            for c2 = 1:max(data_train(:,4))
                SI_c{load,pos}(cl,c2) = SI_c{load,pos}(cl,c2) + sum(data_train(ind,end) == c2);
            end
        end
    end
end

