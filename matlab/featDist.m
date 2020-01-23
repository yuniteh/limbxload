subAll = loadSubs(subType,1);

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'));
        disp(subAll.subs{subInd})
        d = zeros(4,7);
        v = d;
        for pos = 1:4
            for cl = 1:max(params(:,2))
                test_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == pos,:);
                stat_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == 1,:);
                if ~isempty(stat_feat)
                    d(pos,cl) = mean(sqrt(mahal(test_feat,stat_feat)));
                    v(pos,cl) = var(sqrt(mahal(test_feat,stat_feat)));
                end
            end
        end
        
        d
        v
    end
end
