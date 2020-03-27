out = data.ab;
tr_type = 0;
metList = {'comp','time','move','stop'};
out = out(out.tr ~= tr_type & out.dof ~= 1,:);

%%
out.DF = out.sub;
out.DF(out.DF<3,:) = 1;
out.DF(out.DF>2,:) = 2;

%%
out.pos = categorical(out.pos,[1,2,3,4]);
out.tr = categorical(out.tr,[1,2]);
out.sub = categorical(out.sub);
out.ld = categorical(out.ld,[1,2,3]);
out.DF = categorical(out.DF);

%%
clear p;
for m = 1:4
    met = metList{m};
    mod{m} = fitlme(out,[met '~ pos+ld + (1|sub)'],'dummyvarcoding','effects','fitmethod','reml');
    disp(met)
    an_out = anova(mod{m},'DFmethod','satterthwaite')
    temp = dataset2table(an_out);
    p(:,m) = temp.pValue(2:end);
end

cor = nan(size(p));
for i = 1:size(p,1)
    [cor(i,:), h] = bonf_holm(p(i,:),0.05);
end

%%
% out = old(old.dof ~= 1,:);
posc = nchoosek(1:4,2);
ldc = nchoosek(1:3,2);
posp = zeros(length(posc),4);
ldp = zeros(length(ldc),4);
for m = 1:4
    met = out.(metList{m});
    [p,~,stats] = anovan(met,{out.pos,out.ld,out.sub},'varnames',{'pos','ld','sub'},...
        'model',[1 0 0; 0 1 0;0 0 1],'random',3,'display','off');
    temp = multcompare(stats);
    posp(:,m) = temp(:,end);
    temp = multcompare(stats,'dimension',2);
    ldp(:,m) = temp(:,end);
end

cor_p = nan(size(posp));
h = cor_p;
for i = 1:size(posp,1)
    [cor_p(i,:), h(i,:)] = bonf_holm(posp(i,:),0.05);
end
cor = nan(size(ldp));
h = cor;
for i = 1:size(ldp,1)
    [cor(i,:), h(i,:)] = bonf_holm(ldp(i,:),0.05);
end

%%
out = data.ab;
stat = out(out.tr == 1 & out.pos == 1 & out.dof ~= 1,:);
p = nan(4,4);
for m = 1:4
    met = metList{m};
    for pos = 1:4
        dyn = out(out.tr == 2 & out.pos == pos & out.dof ~= 1,:);
        
        stata = nan(max(stat.sub),1);
        dyna = stata;
        for sub = 1:max(stat.sub)
            stata(sub) = nanmean(stat.(met)(stat.sub == sub));
            dyna(sub) = nanmean(dyn.(met)(dyn.sub == sub));
        end
        [h,p(m,pos)] = ttest(stata,dyna);
    end
end
