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

%%
data_all(:,6) = data_all(:,6).*100;
data_all(:,10) = data_all(:,10).*100;
data_all(:,14) = data_all(:,14).*100;
data_all(:,15) = data_all(:,15).*100;

%%
met = 15;

cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(10,'red');
cred = flipud(cred);
cgreen = linspecer(5,'green');
cgreen = flipud(cgreen);

close all
nSubs = max(data_all(:,1));
nPos = max(data_all(:,4));
nLoad = max(data_all(:,2));
nDOF = 6;

marg = 0.3;


labels = [{'Completion Rate (%)'},{'Movement Efficacy (%)'},{'Stopping Efficacy (%)'},{'Completion Time (s)'},{'Offline Accuracy (%)'}];
load_lab = [{'0g'},{'400g'},{'600g'}];

%% position - blue red
figure
[ax]=tight_subplot(5,2,[.04 .06],[.06 .03],[.1 0.01]);
%[ax]=tight_subplot(4,2,[.1 .06],[.05 .03],[.05 0.01]);
c = [cblue(2,:); cgreen(4,:)];

xticks = zeros(4,1);
fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for train = 1:2
        for j = 1:nPos
            ave_all = zeros(nSubs,2);
            for sub = 1:nSubs
                ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                %plot(train + (j-1)*(2+1),ave,'.','Color','k','MarkerSize',8)
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(nSubs);
            errorbar_ez('box',train + (j-1)*(3), nanmean(ave_all(:,train)),se,.4,c(train,:))
            xticks(j) = ((1+ (j-1)*(3)) + (2 + (j-1)*(3)))/2;
        end
    end
    if met ~= 7
        ylim([0 100])
    else
        ylim([0 20])
    end
    set(gca,'YTick',[0 25 50 75 100])
    set(gca,'XTick',xticks)
    set(gca,'XTickLabels',[])
    if y_ind == 5
        set(gca,'YTick',[0 5 10 15 20])
        set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4'])
        xlabel('Limb Position')
    end
    xlim([.4 train + (j-1)*(2+1)+.6])
    ylabel(labels{y_ind})
    y_ind = y_ind + 1;
    fig_ind = fig_ind + 2;
    set(gca,'linewidth',1)
end

% load - blue red
% figure
% [ax]=tight_subplot(1,5,[.05 .05],[.2 .03],[.05 0]);
% c = [cblue(2,:); cred(2,:)];

xticks = zeros(3,1);
fig_ind = 2;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for train = 1:2
        for j = 1:nLoad
            ave_all = zeros(nSubs,2);
            for sub = 1:nSubs
                ind = data_all(:,3) == train & data_all(:,2) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(nSubs);
            errorbar_ez('box',train + (j-1)*(3), nanmean(ave_all(:,train)),se,.4,c(train,:))
            xticks(j) = ((1+ (j-1)*(3)) + (2 + (j-1)*(3)))/2;
        end
    end
    if met ~= 7
        ylim([0 100])
    else
        ylim([0 20])
    end
    set(gca,'YTick',[0 25 50 75 100])
    set(gca,'XTick',xticks)
    set(gca,'XTickLabels',[])
    if y_ind == 5
        set(gca,'YTick',[0 5 10 15 20])
        set(gca,'XTickLabels',[{'0g'};{'400g'};{'600g'}])
        xlabel('Load')
    end
    xlim([.4 train + (j-1)*(2+1)+.6])
    %ylabel(labels{y_ind})
    fig_ind = fig_ind + 2;
    y_ind = y_ind + 1;
    set(gca,'linewidth',1)
end
%% position - blue red bars
figure
[ax]=tight_subplot(5,2,[.04 .06],[.06 .03],[.1 0.01]);
%[ax]=tight_subplot(4,2,[.1 .06],[.05 .03],[.05 0.01]);
c = [cblue(2,:); cgreen(4,:)];

xticks = zeros(3,1);
se = zeros(nLoad,2);
aves = zeros(nLoad,2);
fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:nPos
        for train = 1:2
            
            ave_all = zeros(nSubs,2);
            for sub = 1:nSubs
                ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                ave_all(sub,train) = ave;
            end
            se(j,train) = nanstd(ave_all(:,train))/sqrt(nSubs);
            aves(j,train) = nanmean(ave_all(:,train));
        end
    end
    b = bar(aves,'BarWidth',1,'LineWidth',1);
    ebar(aves,se)
    for bi = 1:2
        set(b(bi),'FaceColor', c(bi,:));
    end
    if met ~= 7
        ylim([0 100])
    else
        ylim([0 20])
    end
    set(gca,'XTick',1:nPos)
    if y_ind == 5
    set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4'])
    xlabel('Limb Position')
    else
        set(gca,'XTickLabels',[])
    end
    xlim([0.5 nPos+.5])
    ylabel(labels{y_ind})
    fig_ind = fig_ind + 2;
    y_ind = y_ind + 1;
    set(gca,'linewidth',1)
end
% load - blue red bars
%figure
%[ax]=tight_subplot(1,4,[.05 .05],[.12 .03],[.05 0.01]);
%c = [cblue(2,:);cred(2,:)];

xticks = zeros(3,1);
se = zeros(nLoad,2);
aves = zeros(nLoad,2);
fig_ind = 2;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:nLoad
        for train = 1:2
            
            ave_all = zeros(nSubs,2);
            for sub = 1:nSubs
                ind = data_all(:,3) == train & data_all(:,2) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                %plot(j + (train - 1)*(nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                ave_all(sub,train) = ave;
            end
            se(j,train) = nanstd(ave_all(:,train))/sqrt(nSubs);
            aves(j,train) = nanmean(ave_all(:,train));
        end
    end
    b = bar(aves,'BarWidth',1,'LineWidth',1);
    ebar(aves,se)
    for bi = 1:2
        set(b(bi),'FaceColor', c(bi,:));
    end
    if met ~= 7
        ylim([0 100])
    else
        ylim([0 20])
    end
    set(gca,'XTick',1:nLoad)
    if fig_ind == 10
    set(gca,'XTickLabels',[{'0g'};{'400g'};{'600g'}])
    xlabel('Load')
    else
        set(gca,'XTickLabels',[]);
    end
    xlim([0.5 nLoad+.5])
    %ylabel(labels{fig_ind-4})
    fig_ind = fig_ind + 2;
    set(gca,'linewidth',1)
    %         % get handle to current axes
    %     a = gca;
    %     % set box property to off and remove background color
    %     set(a,'box','off','color','none')
    %     % create new, empty axes with box but without ticks
    %     b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',1);
    %     % set original axes as active
    %     axes(a)
    %legend('Static','Dynamic')
end