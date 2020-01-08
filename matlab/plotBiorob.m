function plotBiorob(data_all,data_dof,p)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

%% Plot all data with points
figure
[ax]=tight_subplot(5,p.nLoads,[.03 .02],[.08 .08],[.09 0.03]);

fig_ind = 1;
y_ind = 1;
for met = [6 14 10 7 15]
    for load = 1:p.nLoads
        axes(ax(fig_ind));
        hold all
        for j = 1:p.nPos
            ave_all = zeros(p.nSubs,2);
            for train = 1
                for sub = 1:p.nSubs
                    ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub & data_all(:,2) == load;
                    ave = nanmean(data_all(ind,met));
                    %plot(j,ave,'.','Color',cblue(j,:),'MarkerSize',8)
                    ave_all(sub,train) = ave;
                end
                se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                errorbar_ez('boxwhisk',j, ave_all(:,train),se,.4,cblue(j,:))
            end
        end
        ylim([0 100])
        minx = .4;
        maxx = p.nPos+.6;
        midx = (minx + maxx)/2;
        xlim([minx maxx])
        
        set(gca,'XTick',[])
        if load > 1
            set(gca,'YTick',[])
        else
            ylabel(p.metLabels{y_ind})
        end
        if met == 6
            title(p.loadLabels{load})
        elseif met == 15
            set(gca,'XTick',1:p.nPos)
            set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
        elseif met == 7
            ylim([0 20])
        end
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
    end
    
    y_ind = y_ind + 1;
end

