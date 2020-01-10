
d = zeros(4,7);

for pos = 1:4
    for cl = 1:max(params(:,2))
        test_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == pos,:);
        stat_feat = feat(params(:,1) == 3 & params(:,2) == cl & params(:,3) == 1,:);
        d(pos,cl) = .5*mean(sqrt(mahal(test_feat,stat_feat)));
    end
end

d