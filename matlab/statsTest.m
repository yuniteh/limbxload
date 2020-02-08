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






