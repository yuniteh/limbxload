function plotBiorob(data_all,dyn_data,p,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);
start_met = find(data_all(1,:) > 10,1);

switch type
    case 1
        %% Individual testing condition results for given training condition
        figure
        [ax]=tight_subplot(1,p.nLoads,[.03 .02],[.1 .1],[.09 0.03]);
        data_all = dyn_data;
        fig_ind = 1;
        y_ind = 1;
        for met = 6
            for ld = 1:p.nLoads
                axes(ax(fig_ind));
                hold all
                for test_pos = 1:p.nPos
                    ave_all = zeros(p.nSubs,2);
                    %             ave_all = [];
                    for train = 2
                        for sub = 1:p.nSubs
                            ind = data_all(:,2) == train & data_all(:,3) == test_pos & data_all(:,1) == sub & data_all(:,4) == ld;
                            ave = nanmean(data_all(ind,met));
                            %plot(j,ave,'.','Color',cblue(j,:),'MarkerSize',8)
                            ave_all(sub,train) = ave;
                        end
                        se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                        %violinplot(ave_all(:,train),j,'PosSpec',j,'ViolinColor',cblue(j,:));
                        vplot(:,test_pos) = ave_all(:,train);
                        errorbar_ez('boxwhisk',test_pos, ave_all(:,train),se,.4,cblue(test_pos,:))
                    end
                end
                %assignin('base','vplot',vplot);
                %vs = violinplot(vplot,1:test_pos,'ShowData',true,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',cblue(1:p.nPos,:),'Max',100,'Min',0);
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
                    set(gca,'XTick',1:p.nPos)
                    set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
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
    case 2
        %% Individual test condition results given training position and load
        figure
        [ax]=tight_subplot(1,p.nLoads,[.03 .02],[.1 .1],[.09 0.03]);
        
        fig_ind = 1;
        y_ind = 1;
        for met = start_met
            acc = NaN(p.nSubs,p.nLoads*p.nPos);
            for ld = 1:p.nLoads
                axes(ax(fig_ind));
                hold all
                for test_pos = 1:p.nPos
                    ave_all = zeros(p.nSubs,1);
                    %             ave_all = [];
                    
                    for tr_pos = 1%:p.nPos
                        for tr_ld = 1%:p.nLoads
                            for sub = 1:p.nSubs
                                ind = data_all(:,3) == tr_pos & data_all(:,4) == test_pos & data_all(:,1) == sub & data_all(:,2) == tr_ld & data_all(:,5) == ld;
                                ave = nanmean(data_all(ind,met));
                                %plot(j,ave,'.','Color',cblue(j,:),'MarkerSize',8)
                                ave_all(sub,1) = ave;
                            end
                            se = nanstd(ave_all)/sqrt(p.nSubs);
                            vplot(:,test_pos) = ave_all;
                            xi = [1:4; 6:9; 11:14];
                            errorbar_ez('boxwhisk',test_pos, ave_all,se,.4,cblue(test_pos,:))
                            acc(:,test_pos+4*(ld-1)) = ave_all;
                        end
                        
                    end
                end
                
                %vs = violinplot(vplot,1:p.nPos,'ShowData',true,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',cblue(1:p.nPos,:),'Max',100,'Min',0);
                assignin('base','acc',acc);
                ylim([0 100])
                minx = .4;
                maxx = p.nPos+.6;
                midx = (minx + maxx)/2;
                xlim([minx maxx])
                %xlim([minx 15])
                
                set(gca,'XTick',[])
                if ld > 1
                    set(gca,'YTick',[])
                else
                    ylabel('Offline Accuracy (%)')
                end
                title(p.loadLabels{ld})
                set(gca,'XTick',1:p.nPos)
                set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
                set(gca,'linewidth',1)
                fig_ind = fig_ind + 1;
            end
            
            y_ind = y_ind + 1;
        end
    case 3 
        % Plot result from all test condition for all training conditions
        % in given training load
        figure
        [ax]=tight_subplot(4,p.nLoads,[.03 .02],[.08 .08],[.09 0.03]);
        
        fig_ind = 1;
        for met = start_met
            for tr_pos = 1:p.nPos
                for tr_ld = 1
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
                            %errorbar_ez('boxwhisk',j, ave_all(:,train),se,.4,cblue(j,:))
                        end
                        vs = violinplot(vplot,1:test_pos,'ShowData',false,'ShowViolin',false,'LineWidth',1.5,'ViolinColor',cblue(1:p.nPos,:),'Max',100,'Min',0);
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
    case 4
        %Plot result from worst test condition for all training conditions
        carray = [repmat(cblue(1:p.nPos,:),2,1);cgreen(2,:);cblue(1:p.nPos,:)];
        %carray(end+1,:) = cgreen(1,:);
        figure
        hold all
        for met = start_met
            vplot = NaN(1,p.nLoads*p.nPos + 1);
            acc = NaN(p.nSubs,p.nLoads*p.nPos + 1);
            for tr_ld = 1:p.nLoads
                for tr_pos = 1:p.nPos
                    for sub = 1:p.nSubs
                        vind = 1;
                        temp = NaN(p.nLoads*p.nPos,1);
                        tempdyn = temp;
                        for test_ld = 1:p.nLoads
                            for test_pos = 1:p.nPos
                                ind = data_all(:,1) == sub & data_all(:,3) == tr_pos & data_all(:,2) == tr_ld & data_all(:,4) == test_pos & data_all(:,5) == test_ld;
                                temp(vind) = nanmean(data_all(ind,met));
                                assignin('base','res',temp)
                                %                                 vplot(sub,tr_pos + 4*(tr_ld-1)) = nanmean(data_all(ind,met));
                                dyn_ind = dyn_data(:,1) == sub & dyn_data(:,2) == 2 & dyn_data(:,3) == test_pos & dyn_data(:,4) == test_ld;
                                tempdyn(vind) = nanmean(dyn_data(dyn_ind,met - 1));
                                %                                 vplot(sub,end) = nanmean(dyn_data(dyn_ind,met - 1));
                                %se = nanstd(ave_all(:,train))/sqrt(p.nSubs);
                                %errorbar_ez('boxwhisk',j, ave_all(:,train),se,.4,cblue(j,:))
                                vind = vind + 1;
                            end
                        end
                        %                         vplot(sub,tr_pos + 4*(tr_ld-1)) = min(temp);
                        %                         vplot(sub,end) = min(tempdyn);
                        tempv(sub,:) = temp;
                        tempvdy(sub,:) = tempdyn;
                    end
                    [vplot(tr_pos + 4*(tr_ld-1)) tind] = min(nanmean(tempv));
                    [vplot(end) dyind] = min(nanmean(tempvdy));
                    acc(:,tr_pos+4*(tr_ld-1)) = tempv(:,tind);
                    acc(:,end) = tempvdy(:,dyind);
                    tind
                    dyind
                end
            end
            assignin('base','acc',acc)
            ave = vplot;%nanmean(vplot);
            temp = ave(end);
            ave(end-3:end) = ave(end-4:end-1);
            ave(end-4) = temp;
            xi = [1:4 6:10 12:15];
            for bi = 1:size(ave,2)
                b = bar(xi(bi),ave(bi),'BarWidth',1,'LineWidth',1);
                set(b,'FaceColor',carray(bi,:));
            end
            %b = bar(ave,'BarWidth',.8,'LineWidth',1);
            %             for bi = 1:size(ave,2)
            %                 bi
            %                 set(b(bi),'FaceColor',carray(bi,:));
            %             end
            %vs = violinplot(vplot,1:p.nPos*p.nLoads+1,'ShowData',false,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',carray,'Max',100,'Min',0);
        end
        ylim([0 100])
        set(gca,'linewidth',1)
        
end
