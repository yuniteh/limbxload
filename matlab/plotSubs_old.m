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
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

close all
nSubs = max(data_all(:,1));
nPos = max(data_all(:,4));
nLoad = max(data_all(:,2));
nDOF = 6;

marg = 0.3;


labels = [{'Completion Rate (%)'},{'Movement Efficacy (%)'},{'Stopping Efficacy (%)'},{'Completion Time (s)'},{'Offline Accuracy (%)'}];
load_lab = [{'0g'},{'400g'},{'600g'}];

%%
figure
[ax]=tight_subplot(5,nLoad,[.03 .02],[.03 .03],[.09 0]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    for load = 1:nLoad
        axes(ax(fig_ind));
        hold all
        for j = 1:nPos
            ave_all = zeros(nSubs,2);
            for train = 1:2
                for sub = 1:nSubs
                    ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub & data_all(:,2) == load;
                    ave = nanmean(data_all(ind,met));
                    plot(j + (train - 1)*(nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                    ave_all(sub,train) = ave;
                end
                se = nanstd(ave_all(:,train))/sqrt(nSubs);
                errorbar_ez('box',j + (train - 1)*(nPos+1), nanmean(ave_all(:,train)),se,.4,cblue(j,:))
            end
        end
        if met ~= 7
            ylim([0 100])
            mid = (.4 + nPos+(nPos+1)+.6)/2;
            plot([mid mid],[0 100],'k--','LineWidth',1)
        else
            ylim([0 20])
            plot([mid mid],[0 20],'k--','LineWidth',1)
        end
        minx = .4;
        maxx = nPos+(nPos+1)+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        set(gca,'XTick',[])
        if load > 1
            set(gca,'YTick',[])
        else
            ylabel(labels{y_ind})
        end
        if met == 6
            title(load_lab{load},'FontWeight','Normal')
        elseif met == 15
            set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
            set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
        end
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
    end
    
    y_ind = y_ind + 1;
end

%%
figure
[ax]=tight_subplot(1,5,[.05 .05],[.12 .03],[.05 0]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:nPos
        ave_all = zeros(nSubs,2);
        for train = 1:2
            for sub = 1:nSubs
                    ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(nSubs);
            errorbar_ez('box',j + (train - 1)*(nPos+1), nanmean(ave_all(:,train)),se,.4,cblue(j,:))
        end
    end
    if met ~= 7
        ylim([0 100])
        mid = (.4 + nPos+(nPos+1)+.6)/2;
        plot([mid mid],[0 100],'k--','LineWidth',1)
    else
        ylim([0 20])
        plot([mid mid],[0 20],'k--','LineWidth',1)
    end
    minx = .4;
    maxx = nPos+(nPos+1)+.6;
    midx = (minx + maxx)/2;
    xlim([minx maxx])
    
    ylabel(labels{y_ind})
    set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
    set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
    set(gca,'linewidth',1)
    fig_ind = fig_ind + 1;
    
    y_ind = y_ind + 1;
end

%%
figure
    [ax]=tight_subplot(1,5,[.05 .05],[.12 .03],[.05 0]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:nLoad
        ave_all = zeros(nSubs,2);
        for train = 1:2
            for sub = 1:nSubs
                ind = data_all(:,3) == train & data_all(:,2) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                %plot(j + (train - 1)*(nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(nSubs);
            errorbar_ez('box',j + (train - 1)*(nLoad+1), nanmean(ave_all(:,train)),se,.4,cgreen(j,:))
        end
    end
    if met ~= 7
        ylim([0 100])
        mid = (.4 + nLoad+(nLoad+1)+.6)/2;
        plot([mid mid],[0 100],'k--','LineWidth',1)
    else
        ylim([0 20])
        plot([mid mid],[0 20],'k--','LineWidth',1)
    end
    minx = .4;
    maxx = nLoad+(nLoad+1)+.6;
    midx = (minx + maxx)/2;
    xlim([minx maxx])
    
    ylabel(labels{y_ind})
    set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
    set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
    set(gca,'linewidth',1)
    fig_ind = fig_ind + 1;
    
    y_ind = y_ind + 1;
end

%% TR
figure
[ax]=tight_subplot(1,5,[.05 .05],[.2 .03],[.05 0]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:nPos
        ave_all = zeros(nSubs,1);
        for sub = 1:nSubs
            ind = data_all(:,4) == j & data_all(:,1) == sub;
            ave = nanmean(data_all(ind,met));
            ave_all(sub) = ave;
        end
        se = nanstd(ave_all)/sqrt(nSubs);
        errorbar_ez('box',j, nanmean(ave_all),se,.4,cblue(j,:))
    end
    if met ~= 7
        ylim([0 100])
        mid = (.4 + nPos+.6)/2;
    else
        ylim([0 20])
    end
    minx = .4;
    maxx = nPos+.6;
    midx = (minx + maxx)/2;
    xlim([minx maxx])
    
    if met == 10
        xlabel('Limb Position')
    end
    ylabel(labels{y_ind})
    set(gca,'linewidth',1)
    fig_ind = fig_ind + 1;
    
    y_ind = y_ind + 1;
end

%%
figure
[ax]=tight_subplot(1,5,[.05 .05],[.2 .03],[.05 0]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    axes(ax(fig_ind));
    hold all
    for j = 1:nLoad
        ave_all = zeros(nSubs,1);
        for sub = 1:nSubs
            ind = data_all(:,2) == j & data_all(:,1) == sub;
            ave = nanmean(data_all(ind,met));
            %plot(j + (train - 1)*(nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
            ave_all(sub) = ave;
        end
        se = nanstd(ave_all)/sqrt(nSubs);
        errorbar_ez('box',j , nanmean(ave_all),se,.4,cgreen(j,:))
    end
    if met ~= 7
        ylim([0 100])
    else
        ylim([0 20])
    end
    minx = .4;
    maxx = nLoad+.6;
    midx = (minx + maxx)/2;
    xlim([minx maxx])
    
    ylabel(labels{y_ind})
    set(gca,'XTickLabels',[0, 400, 600])
    if met == 10
    xlabel('Load (g)')
    end
    set(gca,'linewidth',1)
    fig_ind = fig_ind + 1;
    
    y_ind = y_ind + 1;
end

%%
figure
[ax]=tight_subplot(nPos,nLoad,[.02 .02],[.1 .1],[.1 .1]);
fig_ind = 1;
for j = 1:nPos
    for load = 1:nLoad
        axes(ax(fig_ind));
        hold all
        ave_all = zeros(nSubs,2);
        for dof = 1:nDOF
            for train = 1:2
                for sub = 1:nSubs
                    if size(data_dof,2) >= dof + 5
                        ind = data_dof(:,3) == train & data_dof(:,4) == j & data_dof(:,1) == sub & data_dof(:,2) == load;
                        ave = nanmean(data_dof(ind,dof + 5));
                        plot(dof + (train - 1)*(nDOF+1),ave,'.','Color',cred(dof,:),'MarkerSize',8)
                        ave_all(sub,train) = ave;
                    end
                end
                se = nanstd(ave_all(:,train))/sqrt(nSubs);
                errorbar_ez('box',dof + (train - 1)*(nDOF+1), nanmean(ave_all(:,train)),se,.4,cred(dof,:))
            end
        end
        ylim([0 15])
        mid = (.4 + nDOF+(nDOF+1)+.6)/2;
        plot([mid mid],[0 100],'k--','LineWidth',1)
        xlim([.4 nDOF+(nDOF+1)+.6])
        
        set(gca,'XTick',[])
        set(gca,'linewidth',1)
        if load > 1
            set(gca,'YTick',[])
        end
        fig_ind = fig_ind + 1;
    end
    
    
end
%%
figure
[ax]=tight_subplot(1,nLoad,[.02 .02],[.1 .1],[.1 .1]);
c = [cblue(2,:); cred(2,:)];

for load = 1:nLoad
    axes(ax(load));
    hold all
    for train = 1:2
        for j = 1:nPos
            ave_all = zeros(nSubs,2);
            for sub = 1:nSubs
                
                ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub & data_all(:,2) == load;
                ave = nanmean(data_all(ind,met));
                plot(train + (j-1)*(2+1),ave,'.','Color',c(train,:),'MarkerSize',8)
                ave_all(sub,train) = ave;
            end
            se = nanstd(ave_all(:,train))/sqrt(nSubs);
            errorbar_ez('box',train + (j-1)*(2+1), nanmean(ave_all(:,train)),se,.4,c(train,:))
        end
    end
    if met ~= 7
        ylim([0 100])
    else
        ylim([0 20])
    end
    xlim([.4 nPos+(nPos+1)+.6])
    set(gca,'XTick',[])
    if load > 1
        set(gca,'YTick',[])
    end
end
