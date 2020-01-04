function plotFullSimple(data_all,p,subType)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);
close all

%% Plot all data with points
figure
[ax]=tight_subplot(5,p.nLoads,[.03 .02],[.03 .03],[.09 0]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    for load = 1:p.nLoads
        axes(ax(fig_ind));
        hold all
        for j = 1:p.nPos
            ave_all = zeros(p.nSubs,2);
            for train = 1:2
                for sub = 1:p.nSubs
                    ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub & data_all(:,2) == load;
                    ave = nanmean(data_all(ind,met));
                    plot(j + (train - 1)*(p.nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                    ave_all(sub,train) = ave;
                end
                se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                errorbar_ez('boxwhisk',j + (train - 1)*(p.nPos+1), ave_all(:,train),se,.4,cblue(j,:))
            end
        end
        if met ~= 7
            ylim([0 100])
            mid = (.4 + p.nPos+(p.nPos+1)+.6)/2;
            plot([mid mid],[0 100],'k--','LineWidth',1)
        else
            ylim([0 20])
            plot([mid mid],[0 20],'k--','LineWidth',1)
        end
        minx = .4;
        maxx = p.nPos+(p.nPos+1)+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        set(gca,'XTick',[])
        if load > 1
            set(gca,'YTick',[])
        else
            ylabel(p.metLabels{y_ind})
        end
        if met == 6
            title(p.loadLabels{load},'FontWeight','Normal')
        elseif met == 15
            set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
            set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
        end
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
    end
    
    y_ind = y_ind + 1;
end

%% Plot while blocking load (AB summary)
if strcomp(subType,'AB')
    figure
    [ax]=tight_subplot(1,5,[.05 .05],[.12 .03],[.05 0]);
    
    fig_ind = 1;
    y_ind = 1;
    for met = [6 14 10 7 15]
        axes(ax(fig_ind));
        hold all
        for j = 1:p.nPos
            ave_all = zeros(p.nSubs,2);
            for train = 1:2
                for sub = 1:p.nSubs
                    ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub;
                    ave = nanmean(data_all(ind,met));
                    ave_all(sub,train) = ave;
                end
                se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                errorbar_ez('box',j + (train - 1)*(p.nPos+1), nanmean(ave_all(:,train)),se,.4,cblue(j,:))
            end
        end
        if met ~= 7
            ylim([0 100])
            mid = (.4 + p.nPos+(p.nPos+1)+.6)/2;
            plot([mid mid],[0 100],'k--','LineWidth',1)
        else
            ylim([0 20])
            plot([mid mid],[0 20],'k--','LineWidth',1)
        end
        minx = .4;
        maxx = p.nPos+(p.nPos+1)+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        ylabel(p.metLabels{y_ind})
        set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
        set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
        
        y_ind = y_ind + 1;
    end
    
    %% Plot while blocking limb position (AB summary)
    figure
    [ax]=tight_subplot(1,5,[.05 .05],[.12 .03],[.05 0]);
    
    fig_ind = 1;
    y_ind = 1;
    for met = [6 14 10 7 15]
        axes(ax(fig_ind));
        hold all
        for j = 1:p.nLoads
            ave_all = zeros(p.nSubs,2);
            for train = 1:2
                for sub = 1:p.nSubs
                    ind = data_all(:,3) == train & data_all(:,2) == j & data_all(:,1) == sub;
                    ave = nanmean(data_all(ind,met));
                    %plot(j + (train - 1)*(nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                    ave_all(sub,train) = ave;
                end
                se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                errorbar_ez('box',j + (train - 1)*(p.nLoads+1), nanmean(ave_all(:,train)),se,.4,cgreen(j,:))
            end
        end
        if met ~= 7
            ylim([0 100])
            mid = (.4 + p.nLoads+(p.nLoads+1)+.6)/2;
            plot([mid mid],[0 100],'k--','LineWidth',1)
        else
            ylim([0 20])
            plot([mid mid],[0 20],'k--','LineWidth',1)
        end
        minx = .4;
        maxx = p.nLoads+(p.nLoads+1)+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        ylabel(p.metLabels{y_ind})
        set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
        set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
        
        y_ind = y_ind + 1;
    end
    
    %% Plot while blocking load and training method (TR summary)
else
    figure
    [ax]=tight_subplot(1,5,[.05 .05],[.2 .03],[.05 0]);
    
    fig_ind = 1;
    y_ind = 1;
    for met = [6 14 10 7 15]
        axes(ax(fig_ind));
        hold all
        for j = 1:p.nPos
            ave_all = zeros(p.nSubs,1);
            for sub = 1:p.nSubs
                ind = data_all(:,4) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                ave_all(sub) = ave;
            end
            se = nanstd(ave_all)/sqrt(p.nSubs);
            errorbar_ez('box',j, nanmean(ave_all),se,.4,cblue(j,:))
        end
        if met ~= 7
            ylim([0 100])
            mid = (.4 + p.nPos+.6)/2;
        else
            ylim([0 20])
        end
        minx = .4;
        maxx = p.nPos+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        if met == 10
            xlabel('Limb Position')
        end
        ylabel(p.metLabels{y_ind})
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
        
        y_ind = y_ind + 1;
    end
    
    %% Plot while blocking limb position and training method (TR summary)
    figure
    [ax]=tight_subplot(1,5,[.05 .05],[.2 .03],[.05 0]);
    
    fig_ind = 1;
    y_ind = 1;
    for met = [6 14 10 7 15]
        axes(ax(fig_ind));
        hold all
        for j = 1:p.nLoads
            ave_all = zeros(p.nSubs,1);
            for sub = 1:p.nSubs
                ind = data_all(:,2) == j & data_all(:,1) == sub;
                ave = nanmean(data_all(ind,met));
                %plot(j + (train - 1)*(nPos+1),ave,'.','Color',cblue(j,:),'MarkerSize',8)
                ave_all(sub) = ave;
            end
            se = nanstd(ave_all)/sqrt(p.nSubs);
            errorbar_ez('box',j , nanmean(ave_all),se,.4,cgreen(j,:))
        end
        if met ~= 7
            ylim([0 100])
        else
            ylim([0 20])
        end
        minx = .4;
        maxx = p.nLoads+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        ylabel(p.metLabels{y_ind})
        set(gca,'XTickLabels',[0, 400, 600])
        if met == 10
            xlabel('Load (g)')
        end
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
        
        y_ind = y_ind + 1;
    end
end

end
