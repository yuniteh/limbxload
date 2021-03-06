clear
close
clc
%%
subType = 'AB';
new = 1;

%% run if there are new subs
importData();

%%
if new == 1
    % import excel data
    loadSubs(subType);
    % parse all training data
    parseTrainData(subType);
end

%% calculate metrics and compile subs
[data_all, data_dof, subs_all] = compileSubs(subType,1); %1 for recompile

%% cut arm pos = 5 and load = 500
if sum(data_all(:,2) == 4) > 0 
    ind = data_all(:,2) == 3;
    data_all(ind,:) = [];
    data_all(data_all(:,2) == 4,2) = 3;
    ind = data_all(:,4) == 5;
    data_all(ind,:) = [];
    
    ind = data_dof(:,2) == 3;
    data_dof(ind,:) = [];
    data_dof(data_dof(:,2) == 4,2) = 3;
    ind = data_dof(:,4) == 5;
    data_dof(ind,:) = [];
end
%%
[cm_all, acc_all, sub_rate, FS] = calcOffline(subType);
data_all = combineData(data_all,sub_rate,'ave');
%%
uisave({'data_all','data_dof','subs_all','cm_all','acc_all'},'alldata')

%% create all figures
plotLL(data_all,data_dof,cm_all,acc_all,2,subType,'biorob')

%% run statistical analysis
[p, struct] = stats(data_all);