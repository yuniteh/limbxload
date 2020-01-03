function plotAll(data_all,cm_all,acc_all,group)
disp('Plotting data...')
% data_all: all results from compileSubs fxn
% group: 0 = failed trials only, 1 = completed trials only, 2 = all trials

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

%% Plot metrics while blocking testing load
num_mets = size(data_all,2) - 6;
mean_mets = cell(2,num_mets);
se_mets = cell(2,num_mets);

for j = 1:size(mean_mets,2)
    mean_mets{1,j} = zeros(numPos,numTests);
    mean_mets{2,j} = zeros(numLoads,numTests);
    se_mets{1,j} = zeros(numPos,numTests);
    se_mets{2,j} = zeros(numLoads,numTests);
end

data_all(:,6) = data_all(:,6).*100;
data_all(:,10) = data_all(:,10).*100;
data_all(:,14) = data_all(:,14).*100;
data_all(:,15) = data_all(:,15).*100;
labels = [{'Completion Rate'},{'Completion Time (s)'},{'Path Efficiency'},{'Time in Target(s)'},{'Stopping Efficacy'},{'Mean Error'},{'Max Time In'}, {'Best Window In'}, {'Movement Efficacy'}];
for i = 1:numTests
    ind = data_all(:,3) == i;
    pos = data_all(ind,4);
    load = data_all(ind,2);
    sub = data_all(ind,1);
    mets = data_all(ind,6:end-1);
    
    if group < 2
        cInd = mets(:,1) == group;
    else
        cInd = ones(size(mets(:,1)));
    end
    
    for j = 1:numPos
        posInd = pos == j;
        for k = 1:size(mean_mets,2)
            temp = NaN(numSubs,1);
            for ii = 1:numSubs
                if k == 1
                    metInd = posInd & sub == ii;
                else
                    metInd = cInd & posInd & sub == ii;
                end
                temp(ii) = nanmean(mets(metInd,k));
            end
            mean_mets{1,k}(j,i) = nanmean(temp);
            se_mets{1,k}(j,i) = nanstd(temp)./sqrt(numSubs - sum(isnan(temp)));
        end
    end
    
    for j = 1:numLoads
        loadInd = load == j;
        for k = 1:size(mean_mets,2)
            temp = NaN(numSubs,1);
            for ii = 1:numSubs
                
                if k == 1
                    metInd = loadInd & sub == ii;
                else
                    metInd = cInd & loadInd & sub == ii;
                end
                temp(ii) = nanmean(mets(metInd,k));
            end
            mean_mets{2,k}(j,i) = nanmean(temp);
            se_mets{2,k}(j,i) = nanstd(temp)./sqrt(numSubs - sum(isnan(temp)));
        end
    end
    
end

%% plot while blocking load
figure
c = [57 93 122; 255 95 95];
c = c./255;
hold all
b = bar(mean_mets{1,1},'EdgeColor','None');
ebar(mean_mets{1,1},se_mets{1,1})
for i = 1:2
    set(b(i),'FaceColor', c(i,:));
end
ylim([0 1])
ylabel('Completion Rate')
legend(l_name)
set(gca,'XTick',1:numPos)
xlabel('Position')

figure
[ax]=tight_subplot(4,1);
fig_ind = 1;
for i = [1 9 5 2]
    axes(ax(fig_ind));
    hold all
    %errorbar_ez('box',j + (train - 1)*(nPos+1), nanmean(ave_all(:,train)),se,.4,cblue(j,:))
    b = bar(mean_mets{1,i},'EdgeColor','None','BarWidth',1);
    ebar(mean_mets{1,i},se_mets{1,i})
    for j = 1:2
        set(b(j),'FaceColor', c(j,:));
    end
    if i == 2
        ylim([0 ceil(max(max(mean_mets{1,i} + se_mets{1,i})))])
    else
        ylim([0 100])
    end
    ylabel(labels{i})
    set(gca,'XTick',[])
    if i == 1
        legend(l_name)
    elseif i == 13
        set(gca,'XTick',1:numPos)
        xlabel('Position')
    end
    fig_ind = fig_ind + 1;
end
linkaxes(ax,'x')
xlim([.5 numPos+.5])

%% plot while blocking position
x = [1:numLoads; 1:numLoads]';
figure
hold all
for i = 1:numTests
    stdshade(mean_mets{2,1}(:,i)',se_mets{2,1}(:,i)',.3,c(i,:))
end
ylim([0 1])
ylabel('Completion Rate')
legend(l_name)
set(gca,'XTick',1:numLoads)
set(gca,'XTickLabels',loadLabel)
xlabel('Loads (g)')

figure
[ax]=tight_subplot(4,1);
fig_ind = 1;
for i = [1 9 5 2]
    axes(ax(fig_ind));
    hold all
    for j = 1:numTests
        stdshade(mean_mets{2,i}(:,j)',se_mets{2,i}(:,j)',.3,c(j,:));
        %plot(mean_mets{2,i}(:,j),'-','LineWidth',1.5,'MarkerSize',15,'Color',c(j,:))
    end
    %errorbar(x,mean_mets{2,i},se_mets{2,i},'k.')
    if i == 2
        ylim([0 ceil(max(max(mean_mets{2,i} + se_mets{2,i})))])
    else
        ylim([0 100])
    end
    ylabel(labels{i})
    set(gca,'XTick',1:numLoads)
    set(gca,'XTickLabels',[])
    if i == 1
        legend(l_name)
    elseif i == 2
        set(gca,'XTickLabels',loadLabel)
        xlabel('Load (g)')
    end
    fig_ind = fig_ind + 1;
end

linkaxes(ax,'x')
xlim([1 numLoads+.2])

%% PLOT OFFLINE CONFUSION MATRICES
figure
plotConfMat(cm_all{1},['NM'; 'HO';'HC';'WP';'WS';'WF';'WE'],'blue')
figure
plotConfMat(cm_all{2},['NM'; 'HO'; 'HC'; 'WP';'WS';'WF';'WE'],'red mat')

%% PLOT OFFLINE ACCURACIES OF ALL CONDITIONS
figure
plotLimbLoadMat(acc_all{1,1},acc_all{1,2},1:numPos,flip(loadLabel),'grey')
figure
plotLimbLoadMat(acc_all{2,1},acc_all{2,2},1:numPos,flip(loadLabel),'grey')
end