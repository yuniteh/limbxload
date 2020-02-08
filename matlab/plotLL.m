function plotLL(data_all,data_dof,cm_all,acc_all,group,subType,style)
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
% 14: movement efficacy

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
p.nDOF = max(data_all(:,5));

p.metLabels = [{'Completion Rate (%)'},{'Movement Efficacy (%)'},{'Stopping Efficacy (%)'},{'Completion Time (s)'},{'Offline Accuracy (%)'}];
p.loadLabels = [{'0g'},{'400g'},{'600g'}];

%% Scale metrics
if max(data_all(:,6)) <= 1
    data_all(:,6) = data_all(:,6).*100;
%     data_all(:,10) = data_all(:,10).*100;
%     data_all(:,14) = data_all(:,14).*100;
%     data_all(:,15) = data_all(:,15).*100;
end

%% Switch between plot styles
switch style
    % oldest plotting function with confusion matrices and linear regression for load
    case 'oldest'  
        plotV1(data_all,cm_all,acc_all,group,p)
    % most comprehensive plots from first draft of TNSRE paper - plots all
    % conditions, summary plots, wrong DOF activations
    case 'full'
        plotFull(data_all,data_dof,p)
    % simple summary box and bar plots, used for TNSRE first submission
    case 'tnsre'
        plotSimple(data_all,p)
    % new full box and whisker and summary plots, TNSRE resubmission
    case 'tnsreV2'
        plotFullSimple(data_all,p,subType)
    % offline plots for Biorob
    case 'biorob'
        plotBiorob(data_all,p,3)
end
end

