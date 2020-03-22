function plotTNSRE(data,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);
cgreen = linspecer(5,'green');
cgreen = flipud(cgreen);
metList = {'comp','time','move','stop'};
nLd = max(data.ld);
nPos = max(data.pos);
nSub = max(data.sub);
metLabels = {'Completion Rate (%)','Completion Time (s)', 'Movement Efficacy (%)','Stopping Efficacy (%)'};

%% Plot static data with points
switch type
    case 'interaction'
        figure
        [ax]=tight_subplot(4,3,[.05 .06],[.07 .03],[.09 0.04]);
        
        fig_ind = 1;
        y_ind = 1;
        for metI = 1:4
            met = metList{metI};
            for ld = 1:nLd
                axes(ax(fig_ind));
                hold all
                for pos = 1:nPos
                    ave = nan(nSub,1);
                    for sub = 1:nSub
                        ave(sub) = nanmean(data.(met)(data.sub == sub & data.pos == pos & data.ld == ld & data.tr == 1,:));
                    end
                    minx = 0.4;
                    maxx = nPos+.6;
                    xlim([minx maxx])
                    %             errorbar_ez('boxwhisk',pos,ave,0,.4,cblue(pos,:))
                    errorbar_ez('bar',pos,nanmean(ave),nanstd(ave)./sqrt(sum(~isnan(ave))),.4,cblue(pos,:))
                end
                
                if strcmp(met,'time')
                    ylim([0 20])
                else
                    ylim([0 100])
                end
                
                set(gca,'XTick',[])
                if ld > 1
                    set(gca,'YTick',[])
                else
                    ylabel(met)
                end
                set(gca,'linewidth',1)
                fig_ind = fig_ind + 1;
            end
            y_ind = y_ind + 1;
        end
        
    case 'all'
        figure
        [ax]=tight_subplot(4,1,[.05 .06],[.07 .03],[.09 0.04]);
        
        fig_ind = 1;
        for metI = 1:4
            met = metList{metI};
            axes(ax(fig_ind));
            hold all
            for pos = 1:nPos
                ave = nan(nSub,1);
                for sub = 1:nSub
                    ave(sub) = nanmean(data.(met)(data.sub == sub & data.pos == pos & data.tr == 1,:));
                end
                minx = 0.4;
                maxx = nPos+.6;
                xlim([minx maxx])
                %             errorbar_ez('boxwhisk',pos,ave,0,.4,cblue(pos,:))
                errorbar_ez('bar',pos,nanmean(ave),nanstd(ave)./sqrt(sum(~isnan(ave))),.4,cblue(pos,:))
            end
            
            if strcmp(met,'time')
                ylim([0 20])
            else
                ylim([0 100])
            end
            
            set(gca,'XTick',[])
            ylabel(met)
            set(gca,'linewidth',1)
            
            fig_ind = fig_ind + 1;
        end
    case 'bars'
        figure
        [ax]=tight_subplot(4,2,[.04 .06],[.06 .03],[.1 0.01]);
        c = [cblue(2,:); cgreen(4,:)];
        
        se = zeros(nLd,2);
        aves = zeros(nLd,2);
        fig_ind = 1;
        y_ind = 1;
        for metI = 1:4
            met = metList{metI};
            axes(ax(fig_ind));
            hold all
            for pos = 1:nPos
                for train = 1:2
                    ave_all = zeros(nSub,2);
                    for sub = 1:nSub
                        ind = data.tr == train & data.pos == pos & data.sub == sub;
                        ave = nanmean(data.(met)(ind,:));
                        ave_all(sub,train) = ave;
                    end
                    se(pos,train) = nanstd(ave_all(:,train))/sqrt(sum(~isnan(ave_all(:,train))));
                    aves(pos,train) = nanmean(ave_all(:,train));
                end
            end
            b = bar(aves,'BarWidth',1,'LineWidth',1);
            ebar(aves,se)
            for bi = 1:2
                set(b(bi),'FaceColor', c(bi,:));
            end
            if strcmp(met,'time')
                ylim([0 20])
            else
                ylim([0 100])
            end
            set(gca,'XTick',1:nPos)
            if y_ind == 4
                set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4'])
                xlabel('Limb Position')
            else
                set(gca,'XTickLabels',[])
            end
            xlim([0.5 nPos+.5])
            ylabel(metLabels{metI})
            fig_ind = fig_ind + 2;
            y_ind = y_ind + 1;
            set(gca,'linewidth',1)
        end

        se = zeros(nLd,2);
        aves = zeros(nLd,2);
        fig_ind = 2;
        for metI = 1:4
            met = metList{metI};
            axes(ax(fig_ind));
            hold all
            for ld = 1:nLd
                for train = 1:2
                    ave_all = zeros(nSub,2);
                    for sub = 1:nSub
                        ind = data.tr == train & data.ld == ld & data.sub == sub;
                        ave = nanmean(data.(met)(ind,:));
                        ave_all(sub,train) = ave;
                    end
                    se(ld,train) = nanstd(ave_all(:,train))/sqrt(sum(~isnan(ave_all(:,train))));
                    aves(ld,train) = nanmean(ave_all(:,train));
                end
            end
            b = bar(aves,'BarWidth',1,'LineWidth',1);
            ebar(aves,se)
            for bi = 1:2
                set(b(bi),'FaceColor', c(bi,:));
            end
            if strcmp(met,'time')
                ylim([0 20])
            else
                ylim([0 100])
                set(gca,'YTick',0:25:100)
            end
            set(gca,'XTick',1:nLd)
            if fig_ind == 8
                set(gca,'XTickLabels',[{'0g'};{'400g'};{'600g'}])
                xlabel('Load')
            else
                set(gca,'XTickLabels',[]);
            end
            xlim([0.5 nLd+.5])
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

end
