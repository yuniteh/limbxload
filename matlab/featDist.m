subAll = loadSubs(subType,1);
nPos = 4;


for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];    
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'));
        disp(subAll.subs{subInd})
        m_dist = cell(nPos,max(params(:,2)));               % mahalanobis distance
        RI = zeros(nPos, max(params(:,2)));                 % repeatability index
        MSA = RI;                                           % mean semi-principal axis
        SI = nan(nPos, max(params(:,2)));
        SI_class = SI;
        for pos = 1:nPos
            for cl = 1:max(params(:,2))
                test_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == pos,:);
                stat_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == 1,:);
                if ~isempty(stat_feat) && ~isempty(test_feat)
                    test_cen = mean(test_feat);         % testing data centroid
                    test_ax = 2.*std(test_feat);        % testing data semi-principal axis
                    stat_cen = mean(stat_feat);         % static data centroid
                    stat_ax = 2.*std(stat_feat);        % static data semi-principal axis
                    m_dist{pos,cl} = sqrt(mahal(test_feat,stat_feat));
                    RI(pos,cl) = 0.5*sqrt(mahal(mean(test_feat),stat_feat));
                    MSA(pos,cl) = geomean(test_ax);
                    
                    % SI calculation
                    for c = 1:max(params(:,2))
                        if c ~= cl
                            SI_feat = feat(params(:,1) == 3 & params(:,2) == c & params(:,3) == pos,:);
                            SI_temp = 0.5*sqrt(mahal(mean(SI_feat),test_feat));
                            if SI_temp < SI(pos,cl) || isnan(SI(pos,cl))
                                SI(pos,cl) = SI_temp;
                                SI_class(pos,cl) = c;
                            end
                        end
                    end
                end
            end
        end
        save([path '\train_data.mat'],'feat','params','m_dist','RI','MSA','SI','SI_class');
    end
end

