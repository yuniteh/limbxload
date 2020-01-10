train_feat = feat(params(:,1) == 3 & params(:,3) == 1,:);
train_class = params(params(:,1) == 3 & params(:,3) == 1,2);

[w,c,muClass,C,Sb] = trainLDA(train_feat, train_class);
C = C*7;

%%
[V,D,W] = eig(C\Sb);

realW = real(V(:,1:3));

%%
dim_feat = train_feat*realW;

%%
for i = 1:4
    feat_all{i} = feat(params(:,1) == 4 & params(:,3) == i,:)*realW;
    class_all{i} = params(params(:,1) == 4 & params(:,3) == i,2);
end

%%
c = colormap(lines);
hold all
for i = 1:7
    plot3(dim_feat(train_class == i,1),dim_feat(train_class == i,2),dim_feat(train_class == i,3),'o','color',c(i,:))
end

%%
hold all
for pos = 1
    for i = 1:7
        plot3(feat_all{pos}(class_all{pos} == i,1),feat_all{pos}(class_all{pos} == i,2),feat_all{pos}(class_all{pos} == i,3),'x')
    end
end