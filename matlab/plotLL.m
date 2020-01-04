function plotLL(data_all,cm_all,acc_all,group,style)
disp('Plotting data...')
% data_all: all results from compileSubs fxn
% group: 0 = failed trials only, 1 = completed trials only, 2 = all trials

%% Initialize test parameters
numPos = max(data_all(:,4));
numTests = max(data_all(:,3));
numLoads = max(data_all(:,2));
numSubs = max(data_all(:,1));
l_name = {'static', 'dynamic'};
if numLoads == 3
    loadLabel = [0 400 600];
else
    loadLabel = [0 400 500 600];
end

%% Scale metrics
data_all(:,6) = data_all(:,6).*100;
data_all(:,10) = data_all(:,10).*100;
data_all(:,14) = data_all(:,14).*100;
data_all(:,15) = data_all(:,15).*100;

end

