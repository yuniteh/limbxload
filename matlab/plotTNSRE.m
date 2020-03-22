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
        
        se = zeros(nPos,2);
        aves = zeros(nPos,2);
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
                set(gca,'YTick',0:5:20)
            else
                ylim([0 100])
                set(gca,'YTick',0:25:100)
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
                set(gca,'YTick',0:5:20)
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
    case 'sig'
        figure
        [ax]=tight_subplot(4,2,[.04 .06],[.06 .03],[.1 0.01]);
        c = [cblue(2,:); cgreen(4,:)];
%         cblue = flip(linspecer(10,'blue'));
%         cgreen = flip(linspecer(10,'green'));
%         c(1,:,:) = cblue(3:3+4,:);
%         c(2,:,:) = cgreen(end-4:end,:);
        
        xint = .3:.3:.3*nPos;
        xint = [xint xint+(.3*nPos+.2)];
        se = zeros(nPos,2);
        aves = zeros(nPos,2);
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
                    errorbar_ez('bar',xint((train-1)*nPos+pos),aves(pos,train),se(pos,train),.15,c(train,:))
                end
            end
            xmax = max(xint)+.3;
            
            if strcmp(met,'time')
                ylim([0 20])
                set(gca,'YTick',0:5:20)
                
                plot([xmax/2 xmax/2],[0 20],'k--','Linewidth',1)
            else
                ylim([0 100])
                set(gca,'YTick',0:25:100)
                plot([xmax/2 xmax/2],[0 100],'k--','Linewidth',1)
            end
            set(gca,'XTick',xint)
            if y_ind == 4
                set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4';'P1'; 'P2';'P3';'P4'])
                xlabel('Limb Position')
            else
                set(gca,'XTickLabels',[])
            end
            
            h = gca;
            h.XAxis.TickLength =[0 0];
            xlim([0 xmax])
            ylabel(metLabels{metI})
            fig_ind = fig_ind + 2;
            y_ind = y_ind + 1;
            set(gca,'linewidth',1)
        end
        
        xint = .3:.3:.3*nLd;
        xint = [xint xint+(.3*nLd+.2)];
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
                    errorbar_ez('bar',xint((train-1)*nLd+ld),aves(ld,train),se(ld,train),.15,c(train,:))
                end
            end
            xmax = max(xint)+.3;
            
            if strcmp(met,'time')
                ylim([0 20])
                set(gca,'YTick',0:5:20)
                
                plot([xmax/2 xmax/2],[0 20],'k--','Linewidth',1)
            else
                ylim([0 100])
                set(gca,'YTick',0:25:100)
                plot([xmax/2 xmax/2],[0 100],'k--','Linewidth',1)
            end
            set(gca,'XTick',xint)
            if fig_ind == 8
                set(gca,'XTickLabels',[{'0'};{'400'};{'600'};{'0'};{'400'};{'600'}])
                xlabel('Load (g)')
            else
                set(gca,'XTickLabels',[]);
            end
            

            h = gca;
            h.XAxis.TickLength =[0 0];
            xlim([0 xmax])
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
    case 'pos'
        figure
        [ax]=tight_subplot(4,2,[.04 .06],[.06 .03],[.1 0.01]);
        c = [cblue(2,:); cgreen(4,:)];
        
        xint = .3;
        se = zeros(nPos,1);
        aves = zeros(nPos,1);
        c = flip(linspecer(6,'blue'));
        for train = 1:2
            if train == 2;
                c = flip(linspecer(6,'green'));
            end
            c = [cblue(2,:); cgreen(4,:)];
            y_ind = 1;
            for metI = 1:4
                met = metList{metI};
                axes(ax(metI));
                hold all
                for pos = 1:nPos
                    ave_all = zeros(nSub,1);
                    for sub = 1:nSub
                        ind = data.tr == train & data.pos == pos & data.sub == sub;
                        ave_all(sub) = nanmean(data.(met)(ind,:));
                    end
                    se(pos) = nanstd(ave_all)/sqrt(sum(~isnan(ave_all)));
                    aves(pos) = nanmean(ave_all);
                    errorbar_ez('bar',(train-1)*1.4+(pos*xint),aves(pos),se(pos),.15,c(train,:))
                end
                
                if strcmp(met,'time')
                    ylim([0 20])
                    set(gca,'YTick',0:5:20)
                else
                    ylim([0 100])
                    set(gca,'YTick',0:25:100)
                end
                set(gca,'XTick',1:nPos)
                if y_ind == 4
                    set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4'])
                    xlabel('Limb Position')
                else
                    set(gca,'XTickLabels',[])
                end
                h = gca;
                h.XAxis.TickLength =[0 0];
                xlim([0 2.9])
                if train == 1
                    ylabel(metLabels{metI})
                end
%                 fig_ind = fig_ind + 1;
                y_ind = y_ind + 1;
                set(gca,'linewidth',1)
            end
        end
        
        xint = .3:.3:.9;
        xint = [xint xint+1.1];
        se = zeros(nLd,1);
        aves = zeros(nLd,1);
        c = flip(linspecer(6,'blue'));
        for train = 1:2
            if train == 2;
                c = flip(linspecer(6,'green'));
            end
            c = [cblue(2,:); cgreen(4,:)];
            fig_ind = train;
            y_ind = 1;
            for metI = 1:4
                met = metList{metI};
                axes(ax(metI));
                hold all
                for ld = 1:nLd
                    ave_all = zeros(nSub,1);
                    for sub = 1:nSub
                        ind = data.tr == train & data.ld == ld & data.sub == sub;
                        ave_all(sub) = nanmean(data.(met)(ind,:));
                    end
                    se(pos) = nanstd(ave_all)/sqrt(sum(~isnan(ave_all)));
                    aves(pos) = nanmean(ave_all);
                    errorbar_ez('bar',xint((train-1)*nLd+ld),aves(ld),se(ld),.15,c(train,:))
                end
                
                if strcmp(met,'time')
                    ylim([0 20])
                    set(gca,'YTick',0:5:20)
                else
                    ylim([0 100])
                    set(gca,'YTick',0:25:100)
                end
                set(gca,'XTick',xint)
                if y_ind == 4
                    set(gca,'XTickLabels',['0g'; '400g';'600g';'0g'; '400g';'600g'])
                    xlabel('Load')
                else
                    set(gca,'XTickLabels',[])
                end
                h = gca;
                h.XAxis.TickLength =[0 0];
                xlim([0 2.9])
                if train == 1
                    ylabel(metLabels{metI})
                end
%                 fig_ind = fig_ind + 1;
                y_ind = y_ind + 1;
                set(gca,'linewidth',1)
            end
        end
end

end
