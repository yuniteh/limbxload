function [p, struct] = stats(data_all)
%% All data format
% 1: subject id
% 2: load
% 3: training set
% 4: arm position
% 5: target DOF
% 6: completion flag
% 7: trial time
% 8: path efficiency
% 9: samples in target
% 10: percent movement in target
% 11: distance
% 12: maximum time in target
% 13: sliding window maximum time in target

%% CREATE TABLES
group = 2;
if group < 2
    cInd = data_all(:,6) == group;
else
    cInd = ones(size(data_all(:,6))) == 1;
end

static = array2table(data_all(data_all(:,3) == 1 & cInd,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});
dynamic = array2table(data_all(data_all(:,3) == 2 & cInd,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});
all = array2table(data_all(cInd,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});
stat_nl = array2table(data_all(data_all(:,3) == 1 & cInd & data_all(:,2) == 1,:),'VariableNames',{'Sub','Load','Train','Pos','DOF','Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'});
%% ASSIGN CATEGORICAL FACTORS
all.Pos = nominal(all.Pos);
all.Sub = nominal(all.Sub);
all.Train = nominal(all.Train);
all.Load = nominal(all.Load);

static.Pos = nominal(static.Pos);
static.Sub = nominal(static.Sub);
static.Load = nominal(static.Load);

dynamic.Pos = nominal(dynamic.Pos);
dynamic.Sub = nominal(dynamic.Sub);
dynamic.Load = nominal(dynamic.Load);

stat_nl.Pos = nominal(stat_nl.Pos);
stat_nl.Sub = nominal(stat_nl.Pos);

%% RUN ANOVAN
vars = {'Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'};

% [completion rate, completion time, stopping efficacy, movement
% efficacy, accuracy]
p_all = zeros(6,5);
p_stat = zeros(3,5);
p_dyn = p_stat;

ind = 1;
for i = [1 9 5 2 10]
p_all(:,ind) = anovan(all.(vars{i}),{all.Pos, all.Load, all.Train, all.Sub},...
    'varnames',{'Pos','Load','Train','Sub'},'model',[1 0 0 0; 0 1 0 0; 0 0 1 0; 1 0 1 0; 1 1 0 0; 0 1 1 0],'random',4,'display','off');
p_stat(:,ind) = anovan(static.(vars{i}),{static.Pos, static.Load, static.Sub},...
    'varnames',{'Pos','Load','Sub'},'model',[1 0 0; 0 1 0; 1 1 0],'random',3,'display','off');
p_dyn(:,ind) = anovan(dynamic.(vars{i}),{dynamic.Pos, dynamic.Load, dynamic.Sub},...
    'varnames',{'Pos','Load','Sub'},'model',[1 0 0; 0 1 0; 1 1 0],'random',3,'display','off');
ind = ind + 1;
end
p.full.all = p_all;
p.full.stat = p_stat;
p.full.dyn = p_dyn;
%% RUN ANOVAN PT 2
vars = {'Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'};

p_all = zeros(3,5);
p_stat = zeros(1,5);
p_dyn = p_stat;

ind = 1;
for i = [1 9 5 2 10]
[p_all(:,ind), tbl, struct_all(ind)] = anovan(all.(vars{i}),{all.Pos, all.Load, all.Train, all.Sub},...
    'varnames',{'Pos','Load','Train','Sub'},'model',[1 0 0 0; 0 1 0 0; 0 0 1 0],'random',4,'display','off');
[p_stat(:,ind), tbl, struct_stat(ind)] = anovan(static.(vars{i}),{static.Pos, static.Load, static.Sub},...
    'varnames',{'Pos','Load','Sub'},'model',[1 0 0],'random',3,'display','off');
%[p_dyn(:,ind), tbl, struct_dyn(ind)] = anovan(dynamic.(vars{i}),{dynamic.Pos, dynamic.Load, dynamic.Sub},...
    %'varnames',{'Pos','Load','Sub'},'model',[1 0 0; 0 1 0],'random',3,'display','off');
ind = ind + 1;
end
p.red.all = p_all;
p.red.stat = p_stat;
p.red.dyn = p_dyn;
struct.all = struct_all;
struct.stat = struct_stat;
struct.dyn = struct_dyn;

%% RUN ANOVAN PT 2
vars = {'Complete','Time','Path','In','PMove','Distance','MaxIn','Sliding','Eff','Accuracy'};

p_nl = zeros(1,5);

ind = 1;
for i = [1 9 5 2 10]
p_nl(:,ind) = anovan(stat_nl.(vars{i}),{stat_nl.Pos, stat_nl.Sub},...
    'varnames',{'Pos','Sub'},'model',[1 0],'random',2,'display','off');
ind = ind + 1;
end
p.full.nl = p_nl;
end