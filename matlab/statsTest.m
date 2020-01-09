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
all.Pos = nominal(all.Pos);
all.Sub = nominal(all.Sub);
all.Train = nominal(all.Train);
all.Load = nominal(all.Load);

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