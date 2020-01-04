function plotSimple(data_all,p)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(10,'red');
cred = flipud(cred);
cgreen = linspecer(5,'green');
cgreen = flipud(cgreen);
close all

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
        for j = 1:p.nPos
            ave_all = zeros(p.nSubs,2);
            for sub = 1:p.nSubs
                ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                %plot(train + (j-1)*(2+1),ave,'.','Color','k','MarkerSize',8)
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
            errorbar_ez('box',train + (j-1)*(3), nanmean(ave_all(:,train)),se,.4,c(train,:))
            %errorbar_ez('boxwhisk',train + (j-1)*(3), ave_all(:,train),se,.4,c(train,:))
            
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
    ylabel(p.metLabels{y_ind})
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
        for j = 1:p.nLoads
            ave_all = zeros(p.nSubs,2);
            for sub = 1:p.nSubs
                ind = data_all(:,3) == train & data_all(:,2) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
            errorbar_ez('box',train + (j-1)*(3), nanmean(ave_all(:,train)),se,.4,c(train,:))
            %errorbar_ez('boxwhisk',train + (j-1)*(3), ave_all(:,train),se,.4,c(train,:))
            
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
    %ylabel(p.metLabels{y_ind})
    fig_ind = fig_ind + 2;
    y_ind = y_ind + 1;
    set(gca,'linewidth',1)
end
%% position - TNSRE plots
figure
[ax]=tight_subplot(5,2,[.04 .06],[.06 .03],[.1 0.01]);
%[ax]=tight_subplot(4,2,[.1 .06],[.05 .03],[.05 0.01]);
c = [cblue(2,:); cgreen(4,:)];

xticks = zeros(3,1);
se = zeros(p.nLoads,2);
aves = zeros(p.nLoads,2);
fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:p.nPos
        for train = 1:2
            
            ave_all = zeros(p.nSubs,2);
            for sub = 1:p.nSubs
                ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                ave_all(sub,train) = ave;
            end
            se(j,train) = nanstd(ave_all(:,train))/sqrt(p.nSubs);
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
    set(gca,'XTick',1:p.nPos)
    if y_ind == 5
        set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4'])
        xlabel('Limb Position')
    else
        set(gca,'XTickLabels',[])
    end
    xlim([0.5 p.nPos+.5])
    ylabel(p.metLabels{y_ind})
    fig_ind = fig_ind + 2;
    y_ind = y_ind + 1;
    set(gca,'linewidth',1)
end
% load - blue red bars
%figure
%[ax]=tight_subplot(1,4,[.05 .05],[.12 .03],[.05 0.01]);
%c = [cblue(2,:);cred(2,:)];

xticks = zeros(3,1);
se = zeros(p.nLoads,2);
aves = zeros(p.nLoads,2);
fig_ind = 2;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:p.nLoads
        for train = 1:2
            
            ave_all = zeros(p.nSubs,2);
            for sub = 1:p.nSubs
                ind = data_all(:,3) == train & data_all(:,2) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                %plot(j + (train - 1)*(p.nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                ave_all(sub,train) = ave;
            end
            se(j,train) = nanstd(ave_all(:,train))/sqrt(p.nSubs);
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
    set(gca,'XTick',1:p.nLoads)
    if fig_ind == 10
        set(gca,'XTickLabels',[{'0g'};{'400g'};{'600g'}])
        xlabel('Load')
    else
        set(gca,'XTickLabels',[]);
    end
    xlim([0.5 p.nLoads+.5])
    %ylabel(p.metLabels{fig_ind-4})
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
end