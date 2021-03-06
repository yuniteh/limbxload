%% CREATE TABLES
group = 2;
if group < 2
    cInd = data_all(:,6) == group;
else
    cInd = ones(size(data_all(:,6))) == 1;
end

static = array2table(data_all(data_all(:,3) == 1 & cInd,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});%,'SubType'});
dynamic = array2table(data_all(data_all(:,3) == 2 & cInd,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});
all = array2table(data_all(cInd,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});
stat_nl = array2table(data_all(data_all(:,3) == 1 & cInd & data_all(:,2) == 1,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});

%% ASSIGN CATEGORICAL FACTORS
all.Pos = categorical(all.Pos,[1,2,3,4]);
all.Sub = categorical(all.Sub);
all.Train = categorical(all.Train,[1,2]);
all.Load = categorical(all.Load,[1,2,3]);

static.Pos = categorical(static.Pos,[1,2,3,4]);
static.Sub = categorical(static.Sub);
%static.Load = static.Load - 1;
%static.Load(static.Load == 1) = 0;
%static.Load(static.Load == 2) = 400;
%static.Load(static.Load == 3) = 500;
static.Load = categorical(static.Load,[1,2,3]);
%static.Load = static.Load - 1;
%static.SubType = categorical(static.SubType,[1,2]);

dynamic.Pos = nominal(dynamic.Pos);
dynamic.Sub = nominal(dynamic.Sub);
dynamic.Load = nominal(dynamic.Load);

stat_nl.Pos = nominal(stat_nl.Pos);
stat_nl.Sub = nominal(stat_nl.Pos);

%%
mod = fitlme(static,'Accuracy~Pos+Load+Pos*Load+(1|Sub)')%,'dummyvarcoding','effects')
anova(mod)

%%

mod = fitlme(all,'Eff~Pos + Load + Train + Pos*Load + Load*Train + Pos*Train + (1|Sub)')
rmod = fitlme(all,'Eff~Pos + Load + Pos*Load + (1|Sub)')

%%
NM = array2table(data_train(data_train(:,3) == 1,:),'VariableNames',{'Sub','Load','Pos','DOF','RI','SI','MSA','SI_class','SI2'});


NM.Pos = categorical(NM.Pos,[1,2,3,4]);
NM.Sub = categorical(NM.Sub);
NM.Load = categorical(NM.Load,[1,2,3]);

mod = fitlme(NM,'RI~Pos+Load+Pos*Load+(1|Sub)')%,'dummyvarcoding','effects')
anova(mod)

%% biorob
met = array2table(data_all,'VariableNames',{'Sub','TrLoad','TrPos','Pos','Load','Accuracy'});
met.TrLoad = categorical(met.TrLoad);
met.Sub = categorical(met.Sub);
met.TrPos = categorical(met.TrPos);

mod = fitlme(met,'Accuracy ~ TrLoad+TrPos+(1|Sub)','dummyvarcoding','effects')
anova(mod)

%%
out = data.tr;
tr_type = 1;
metList = {'comp','time','move','stop'};
out = out(out.tr == tr_type & out.dof ~= 1 & out.sub < 3,:);
% out = out(out.dof ~= 1,:);

%%
out.DF = out.sub;
out.DF(out.DF<3,:) = 1;
out.DF(out.DF>2,:) = 2;

%%
out.pos = categorical(out.pos,[1,2,3,4]);
out.tr = categorical(out.tr,[1,2]);
out.sub = categorical(out.sub);
out.ld = categorical(out.ld,[1,2,3]);
% out.subType = categorical(out.subType,[1,2]);
out.DF = categorical(out.DF);

%%
mod = fitlme(out,[met '~pos + ld + tr + pos*tr + pos*ld + ld*tr + pos*tr*ld + (1|sub)'],'dummyvarcoding','effects');
anova(mod)

%%
mod = fitlme(out,[met '~pos + ld + tr + DF*pos + DF*ld + pos*tr + pos*ld + ld*tr + pos*tr*ld + (1|sub)'],'dummyvarcoding','effects');
anova(mod)


%%
mod = fitlme(out,[met '~pos*tr + ld*tr + pos*tr*ld + (1|sub)'],'dummyvarcoding','effects');
anova(mod)

%%
mod = fitlme(out,[met '~pos + ld + pos*ld + (1|sub)'],'dummyvarcoding','effects')
anova(mod)

%%
clear p;
for m = 1:4
    met = metList{m};
    mod{m} = fitlme(out,[met '~ pos*ld + (1|sub)'],'dummyvarcoding','effects','fitmethod','reml');
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
h = zeros(1,12);
posc = nchoosek(2:5,2);
ldc = nchoosek(5:7,2);
posp = zeros(length(posc),4);
ldp = zeros(length(ldc),4);
for i = 1:length(posc)
    hi = h;
    if any(posc(i,:) == 5)
        hi(2:4) = [-1 -1 -1];
    else
        hi(posc(i,2)) = -1;
    end
    hi(posc(i,1)) = hi(posc(i,1)) + 1;
    for m = 1:4
        posp(i,m) = coefTest(mod{m},hi);
    end
end
for i = 1:length(ldc)
    hi = h;
    if any(ldc(i,:) == 7)
        hi(5:6) = [-1 -1];
    else
        hi(ldc(i,2)) = -1;
    end
    hi(ldc(i,1)) = hi(ldc(i,1)) + 1;
    for m = 1:4
        ldp(i,m) = coefTest(mod{m},hi);
    end
end

%%
testmod = fitlme(out,['comp ~ pos + ld + pos*ld + (1|sub)'],'dummyvarcoding','effects','fitmethod','reml');
anova(testmod,'DFmethod','satterthwaite')
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
new = [];
for subI = 1:14
    for posI = 1:4
        for ldI = 1:3
            for dofI = 1:6
                new = [new; subI posI ldI dofI static.Complete(static.Sub == subI &...
                    static.Pos == posI & static.Load == ldI & static.DOF == dofI,:) out.comp(...
                    out.sub == subI & out.pos == posI & out.ld == ldI & out.dof == dofI+1,:)];
                
            end
        end
    end
end
