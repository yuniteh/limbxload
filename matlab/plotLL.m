function plotLL(data_all,cm_all,acc_all,group,style)
disp('Plotting data...')
% data_all: all results from compileSubs fxn
% group: 0 = failed trials only, 1 = completed trials only, 2 = all trials

%% Initialize test parameters
p.nPos = max(data_all(:,4));
p.nTests = max(data_all(:,3));
p.nLoads = max(data_all(:,2));
p.nSubs = max(data_all(:,1));
p.leg = {'static', 'dynamic'};
if p.nLoads == 3
    p.load = [0 400 600];
else
    p.load = [0 400 500 600];
end

p.metLabels = [{'Completion Rate (%)'},{'Movement Efficacy (%)'},{'Stopping Efficacy (%)'},{'Completion Time (s)'},{'Offline Accuracy (%)'}];
p.loadLabels = [{'0g'},{'400g'},{'600g'}];

%% Scale metrics
if max(data_all(:,6) <= 1)
    data_all(:,6) = data_all(:,6).*100;
    data_all(:,10) = data_all(:,10).*100;
    data_all(:,14) = data_all(:,14).*100;
    data_all(:,15) = data_all(:,15).*100;
end

%% Switch between plot styles
switch style
    case 'oldest'
        plotV1(data_all,cm_all,acc_all,group,p)
end
end

