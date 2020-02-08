function plotBiorob(data_all,p,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

switch type
    case 1
        %% Plot all data with points
        figure
        [ax]=tight_subplot(1,p.nLoads,[.03 .02],[.08 .08],[.09 0.03]);
        
        fig_ind = 1;
        y_ind = 1;
        for met = [15]
            for ld = 1:p.nLoads
                axes(ax(fig_ind));
                hold all
                for test_pos = 1:p.nPos
                    ave_all = zeros(p.nSubs,2);
                    %             ave_all = [];
                    for train = 2
                        for sub = 1:p.nSubs
                            ind = data_all(:,3) == train & data_all(:,4) == test_pos & data_all(:,1) == sub & data_all(:,2) == ld;
                            ave = nanmean(data_all(ind,met));
                            %plot(j,ave,'.','Color',cblue(j,:),'MarkerSize',8)
                            ave_all(sub,train) = ave;
                        end
                        %se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                        %violinplot(ave_all(:,train),j,'PosSpec',j,'ViolinColor',cblue(j,:));
                        vplot(:,test_pos) = ave_all(:,train);
                        %errorbar_ez('boxwhisk',j, ave_all(:,train),se,.4,cblue(j,:))
                    end
                end
                assignin('base','vplot',vplot);
                vs = violinplot(vplot,1:test_pos,'ShowData',true,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',cblue(1:p.nPos,:),'Max',100,'Min',0);
                %assignin('base','vs',vs);
                ylim([0 100])
                minx = .4;
                maxx = p.nPos+.6;
                midx = (minx + maxx)/2;
                xlim([minx maxx])
                
                set(gca,'XTick',[])
                if ld > 1
                    set(gca,'YTick',[])
                else
                    ylabel('Offline Accuracy (%)')
                end
                if met == 6
                    title(p.loadLabels{ld})
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
        
        %%
    case 2
        figure
        [ax]=tight_subplot(4,p.nLoads,[.03 .02],[.08 .08],[.09 0.03]);
        
        fig_ind = 1;
        for met = [6]
            for tr_pos = 1:p.nPos
                for tr_ld = 3
                    for test_ld = 1:p.nLoads
                        axes(ax(fig_ind));
                        hold all
                        for test_pos = 1:p.nPos
                            ave = NaN(p.nSubs,1);
                            for sub = 1:p.nSubs
                                ind = data_all(:,1) == sub & data_all(:,3) == tr_pos & data_all(:,2) == tr_ld & data_all(:,4) == test_pos & data_all(:,5) == test_ld;
                                ave(sub) = nanmean(data_all(ind,met));
                            end
                            %se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                            vplot(:,test_pos) = ave;
                            %disp([num2str(test_pos) ',' num2str(tr_pos) ',' num2str(tr_ld) ',' num2str(test_ld)])
                            %errorbar_ez('boxwhisk',j, ave_all(:,train),se,.4,cblue(j,:))
                        end
                        vs = violinplot(vplot,1:test_pos,'ShowData',false,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',cblue(1:p.nPos,:),'Max',100,'Min',0);
                        ylim([0 100])
                        minx = .4;
                        maxx = p.nPos+.6;
                        xlim([minx maxx])
                        title([num2str(min(nanmean(vplot,1)),'%.2f') '% - ' num2str(max(nanmean(vplot,1)),'%.2f') '%'])
                        %title([num2str(range(nanmean(vplot,1)),'%.2f') '%'])
                        
                        set(gca,'XTick',[])
                        if test_ld > 1
                            set(gca,'YTick',[])
                        else
                            ylabel('Offline Accuracy (%)')
                        end
                        if tr_pos == p.nPos
                            set(gca,'XTick',1:p.nPos)
                            set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
                        elseif tr_pos == 1
                            %                             title(p.loadLabels{test_ld})
                        end
                        set(gca,'linewidth',1)
                        fig_ind = fig_ind + 1;
                    end
                end
            end
        end
    case 3
        carray = repmat(cblue(1:p.nPos,:),3,1);
        figure
        hold all
        for met = [6]
            vplot = NaN(p.nSubs,p.nLoads*p.nPos);
            for tr_ld = 1:p.nLoads
                for tr_pos = 1:p.nPos
                    vind = 1;
                    for sub = 1:p.nSubs
%                         for test_ld = 1:p.nLoads
%                             for test_pos = 1:p.nPos
                                ind = data_all(:,1) == sub & data_all(:,3) == tr_pos & data_all(:,2) == tr_ld;% & data_all(:,4) == test_pos & data_all(:,5) == test_ld;
                                vplot(sub,tr_pos + 4*(tr_ld-1)) = nanmean(data_all(ind,met));
                                vind = vind + 1;
                                
                                %se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                                %errorbar_ez('boxwhisk',j, ave_all(:,train),se,.4,cblue(j,:))
%                             end
%                         end
                    end
                end
            end
            assignin('base','vplot',vplot)
            vs = violinplot(vplot,1:p.nPos*p.nLoads,'ShowData',false,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',carray,'Max',100,'Min',0);
            
        end
        ylim([0 100])
        set(gca,'linewidth',1)
        
end
