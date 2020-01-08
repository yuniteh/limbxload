function plotFullSimple(data_all,p,subType)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);
%close all

%% Plot static data with points
%marks = [{'o'},{'+'},{'*'},{'d'},{'s'},{'^'},{'p'}];
xvals = ones(p.nSubs,1);
normval = ones(p.nSubs,1);
for train = 1:2
    figure
    [ax]=tight_subplot(2,4,[.05 .06],[.07 .03],[.09 0.04]);
    
    fig_ind = 1;
    for figtype = 1:2
        y_ind = 1;
        for met = [6 14 10 7]
            for load = 1
                axes(ax(fig_ind));
                hold all
                
                for j = 1:p.nPos
                    ave_all = zeros(p.nSubs,2);
                    for sub = 1:p.nSubs
                        ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub & data_all(:,2) == load;
                        ave = nanmean(data_all(ind,met));
                        if strcmp(subType,'TR')
                            %plot(((2*j)-1)+.15*(sub-4),ave,marks{sub},'Color','k','MarkerSize',8,'MarkerFaceColor',cblue(j+1,:))
                        end
                        ave_all(sub,train) = ave;
                        if j == 1
                            normval(sub) = ave;
                        end
                    end
                    minx = 0.4;
                    maxx = p.nPos+.6;
                    xlim([minx maxx])
                    for sub = 1:p.nSubs
                        %plot((2*j)-1,ave_all(sub,train)-normval(sub),'o','Color','k','MarkerSize',8,'MarkerFaceColor',cblue(j+1,:))
                    end
                    if figtype == 1
                        errorbar_ez('boxwhisk',j, ave_all(:,train),0,.4,cblue(j,:))
                        miny = 0;
                        maxy = 1;
                    elseif j > 1
                        plot([minx maxx],[0 0],'k-','LineWidth',1)
                        se = nanstd(ave_all(:,train)-normval)/sqrt(p.nSubs);
                        errorbar_ez('bar',j, nanmean(ave_all(:,train)-normval,1),se,.4,cblue(j,:))
                        miny = -1;
                        maxy = 1;
                    end
                end
                
                
                if met ~= 7
                    ylim([miny*100 maxy*100])
                else
                    ylim([miny*20 maxy*20])
                end
                
                set(gca,'XTick',[])
                if load > 3
                    set(gca,'YTick',[])
                else
                    ylabel(p.metLabels{y_ind})
                end
                if figtype == 2
                    set(gca,'XTick',1:p.nPos)
                    set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
                end
                set(gca,'linewidth',1)
                fig_ind = fig_ind + 1;
            end
            
            y_ind = y_ind + 1;
        end
    end
end


%% Plot all data with points
% marks = [{'o'},{'+'},{'*'},{'d'},{'s'},{'^'},{'p'}];
% for train = 1:2
%     figure
%     [ax]=tight_subplot(5,p.nLoads,[.03 .02],[.03 .03],[.09 0]);
%
%     fig_ind = 1;
%     y_ind = 1;
%     for met = [6 14 10 7 15]
%         for load = 1:p.nLoads
%             axes(ax(fig_ind));
%             hold all
%             for j = 1:p.nPos
%                 ave_all = zeros(p.nSubs,2);
%                 for sub = 1:p.nSubs
%                     ind = data_all(:,3) == train & data_all(:,4) == j & data_all(:,1) == sub & data_all(:,2) == load;
%                     ave = nanmean(data_all(ind,met));
%                     if strcmp(subType,'TR')
%                         plot(j+.1*(sub-4),ave,marks{sub},'Color',cblue(j,:),'MarkerSize',8,'MarkerFaceColor',cblue(j,:))
%                     end
%                     ave_all(sub,train) = ave;
%                 end
%                 se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
%                 %errorbar_ez('boxwhisk',j + (train - 1)*(p.nPos+1), ave_all(:,train),se,.4,cblue(j,:))
%             end
%             if met ~= 7
%                 ylim([0 100])
%                 mid = (.4 + p.nPos+(p.nPos+1)+.6)/2;
%                 plot([mid mid],[0 100],'k--','LineWidth',1)
%             else
%                 ylim([0 20])
%                 plot([mid mid],[0 20],'k--','LineWidth',1)
%             end
%             minx = .4;
%             maxx = p.nPos+.6;
%             midx = (minx + maxx)/2;
%             xlim([minx maxx])
%
%             set(gca,'XTick',[])
%             if load > 1
%                 set(gca,'YTick',[])
%             else
%                 ylabel(p.metLabels{y_ind})
%             end
%             if met == 6
%                 title(p.loadLabels{load},'FontWeight','Normal')
%             elseif met == 15
%                 set(gca,'XTick',[(minx+midx)/2 (midx+maxx)/2])
%                 set(gca,'XTickLabels',[{'Static'} {'Dynamic'}])
%             end
%             set(gca,'linewidth',1)
%             fig_ind = fig_ind + 1;
%         end
%
%         y_ind = y_ind + 1;
%     end
% end
end
