clear
close
clc
%%
subType = 'TR';
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
%%
[cm_all, acc_all, sub_rate] = calcOffline(subType,1);
data_all = combineData(data_all,sub_rate);
uisave({'data_all','data_dof','subs_all','cm_all','acc_all'},'alldata')

%% create all figures
plotLL(data_all,data_dof,cm_all,acc_all,2,subType,'biorob')

%% run statistical analysis
[p, struct] = stats(data_all);