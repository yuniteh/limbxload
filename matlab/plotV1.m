function plotV1(data_all,cm_all,acc_all,group,p)
disp('Plotting data...')
% data_all: all results from compileSubs fxn
% group: 0 = failed trials only, 1 = completed trials only, 2 = all trials
p.metLabels = [{'Completion Rate'},{'Completion Time (s)'},{'Path Efficiency'},{'Time in Target(s)'},{'Stopping Efficacy'},{'Mean Error'},{'Max Time In'}, {'Best Window In'}, {'Movement Efficacy'}];

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

%% Compile metrics
num_mets = size(data_all,2) - 6;
mean_mets = cell(2,num_mets);
se_mets = cell(2,num_mets);

for j = 1:size(mean_mets,2)
    mean_mets{1,j} = zeros(p.nPos,p.nTests);
    mean_mets{2,j} = zeros(p.nLoads,p.nTests);
    se_mets{1,j} = zeros(p.nPos,p.nTests);
    se_mets{2,j} = zeros(p.nLoads,p.nTests);
end

for i = 1:p.nTests
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
    
    for j = 1:p.nPos
        posInd = pos == j;
        for k = 1:size(mean_mets,2)
            temp = NaN(p.nSubs,1);
            for ii = 1:p.nSubs
                if k == 1
                    metInd = posInd & sub == ii;
                else
                    metInd = cInd & posInd & sub == ii;
                end
                temp(ii) = nanmean(mets(metInd,k));
            end
            mean_mets{1,k}(j,i) = nanmean(temp);
            se_mets{1,k}(j,i) = nanstd(temp)./sqrt(p.nSubs - sum(isnan(temp)));
        end
    end
    
    for j = 1:p.nLoads
        loadInd = load == j;
        for k = 1:size(mean_mets,2)
            temp = NaN(p.nSubs,1);
            for ii = 1:p.nSubs
                
                if k == 1
                    metInd = loadInd & sub == ii;
                else
                    metInd = cInd & loadInd & sub == ii;
                end
                temp(ii) = nanmean(mets(metInd,k));
            end
            mean_mets{2,k}(j,i) = nanmean(temp);
            se_mets{2,k}(j,i) = nanstd(temp)./sqrt(p.nSubs - sum(isnan(temp)));
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
ylim([0 100])
ylabel('Completion Rate')
legend(p.leg)
set(gca,'XTick',1:p.nPos)
xlabel('Positions')

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
    ylabel(p.metLabels{i})
    set(gca,'XTick',[])
    if i == 1
        legend(p.leg)
    elseif i == 13
        set(gca,'XTick',1:p.nPos)
        xlabel('Position')
    end
    fig_ind = fig_ind + 1;
end
linkaxes(ax,'x')
xlim([.5 p.nPos+.5])

%% plot while blocking position
x = [1:p.nLoads; 1:p.nLoads]';
figure
hold all
for i = 1:p.nTests
    stdshade(mean_mets{2,1}(:,i)',se_mets{2,1}(:,i)',.3,c(i,:))
end
ylim([0 100])
ylabel('Completion Rate')
legend(p.leg)
set(gca,'XTick',1:p.nLoads)
set(gca,'XTickLabels',p.load)
xlabel('Loads (g)')

figure
[ax]=tight_subplot(4,1);
fig_ind = 1;
for i = [1 9 5 2]
    axes(ax(fig_ind));
    hold all
    for j = 1:p.nTests
        stdshade(mean_mets{2,i}(:,j)',se_mets{2,i}(:,j)',.3,c(j,:));
        %plot(mean_mets{2,i}(:,j),'-','LineWidth',1.5,'MarkerSize',15,'Color',c(j,:))
    end
    %errorbar(x,mean_mets{2,i},se_mets{2,i},'k.')
    if i == 2
        ylim([0 ceil(max(max(mean_mets{2,i} + se_mets{2,i})))])
    else
        ylim([0 100])
    end
    ylabel(p.metLabels{i})
    set(gca,'XTick',1:p.nLoads)
    set(gca,'XTickLabels',[])
    if i == 1
        legend(p.leg)
    elseif i == 2
        set(gca,'XTickLabels',p.load)
        xlabel('Load (g)')
    end
    fig_ind = fig_ind + 1;
end

linkaxes(ax,'x')
xlim([1 p.nLoads+.2])

%% PLOT OFFLINE CONFUSION MATRICES
figure
plotConfMat(cm_all{1},['NM'; 'HO';'HC';'WP';'WS';'WF';'WE'],'blue')
figure
plotConfMat(cm_all{2},['NM'; 'HO'; 'HC'; 'WP';'WS';'WF';'WE'],'red mat')

%% PLOT OFFLINE ACCURACIES OF ALL CONDITIONS
figure
plotLimbLoadMat(acc_all{1,1},acc_all{1,2},1:p.nPos,flip(p.load),'grey')
figure
plotLimbLoadMat(acc_all{2,1},acc_all{2,2},1:p.nPos,flip(p.load),'grey')
end