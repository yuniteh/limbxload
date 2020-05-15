function plotTNSRE(data,type,sv)
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
loadLabels = {'0g','400g','600g'};

%% Plot static data with points
switch type
    case 'interaction'
        
        c_a{1} = cblue;
        c_a{2} = cgreen;
        max_tr = length(unique(data.tr));
        for tr_i = 1:max_tr
            if max_tr == 1
                tr = data.tr(1);
            else
                tr = tr_i;
            end
            c = c_a{tr};
            figure
            [ax]=tight_subplot(4,3,[.03 .02],[.06 .03],[.1 0.01]);
            
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
                            ave(sub) = nanmean(data.(met)(data.sub == sub & data.pos == pos & data.ld == ld & data.tr == tr,:));
                        end
                        minx = 0.4;
                        maxx = nPos+.6;
                        xlim([minx maxx])
%                         errorbar_ez('boxwhisk',pos,ave,0,.4,c(pos,:))
                        errorbar_ez('box',pos,nanmean(ave),nanstd(ave)./sqrt(sum(~isnan(ave))),.4,c(pos,:))
                    end
                    
                    if strcmp(met,'time')
                        ylim([0 20])
                        set(gca,'YTick',0:5:20)
                    else
                        ylim([0 100])
                        set(gca,'YTick',0:25:100)
                    end
                    
                    
                    if ld > 1
                        set(gca,'YTick',[])
                    else
                        ylabel(metLabels{metI})
                    end
                    set(gca,'linewidth',1)
                    fig_ind = fig_ind + 1;
                    if y_ind == 4
                        set(gca,'XTick',1:nPos)
                        set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4'])
                        if ld == 2
                            xlabel('Limb Position')
                        end
                    else
                        set(gca,'XTick',[])
                        if y_ind == 1
                            title(loadLabels{ld})
                        end
                    end
                    
                end
                y_ind = y_ind + 1;
            end
            if sv == 1
                filename = input('filename: ','s');
                exportfig(gcf,['/Volumes/necal/Lab Member folders/Yuni Teh/projects/limbxload/images/figures/' filename])
            end
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
        c = [cblue(2,:); cgreen(2,:)];
        
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
        
        metList = {'comp','move','stop','time'};
        metLabels = {'Completion Rate (%)','Movement Efficacy (%)','Stopping Efficacy (%)','Completion Time (s)' };
        figure
        [ax]=tight_subplot(4,2,[.04 .06],[.06 .03],[.1 0.01]);
        cblue = linspecer(10,'blue');
        cblue = flipud(cblue);
        cgreen = linspecer(10,'green');
        cgreen = flipud(cgreen);
        c = [cblue(3,:); cgreen(9,:)];
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
            if strcmp(met,'comp')
                assignin('base','aves',aves)
                assignin('base','se',se)
            end
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
    case 'dof'
        figure
        [ax]=tight_subplot(4,2,[.04 .06],[.06 .03],[.1 0.01]);
        c = [cblue(2,:); cgreen(4,:)];
        %         cblue = flip(linspecer(10,'blue'));
        %         cgreen = flip(linspecer(10,'green'));
        %         c(1,:,:) = cblue(3:3+4,:);
        %         c(2,:,:) = cgreen(end-4:end,:);
        
        metList = {'comp','move','stop','time'};
        metLabels = {'Completion Rate (%)','Movement Efficacy (%)','Stopping Efficacy (%)','Completion Time (s)' };

        xint = .3:.3:.3*nPos;
        xint = [xint xint+(.3*nPos+.2)];
        fig_ind = 1;
        y_ind = 1;
        se = zeros(nPos,2);
        aves = zeros(nPos,2);
        for metI = 1:2
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
        
        xint1 = .3:.3:.3*nPos;
        xmid = max(xint1)+.25;
        xint = [xint1 xint1+(.3*nPos+.2)];
        xmid2 = max(xint)+.25;
        xint = [xint xint1+2*(.3*nPos+.2)];
        
        xmax = max(xint)+.3;
        se = zeros(nPos,3);
        aves = zeros(nPos,3);
        ctrain = 1;
        for metI = 3:4
            met = metList{metI};
            axes(ax(fig_ind));
            hold all
            for pos = 1:nPos
                for train = 1:3
                    if train == 3
                        ctrain = 2;
                        temp = data.sub(data.tr2 == train);
                    else
                        ctrain = 1;
                        temp = data.sub2(data.tr2 == train);
                    end
                    nSub = length(unique(temp));
                    ave_all = zeros(nSub,2);
                    for sub = 1:nSub
                        if train == 3
                            ind = data.tr2 == train & data.pos == pos & data.sub == sub;
                        else
                            ind = data.tr2 == train & data.pos == pos & data.sub2 == sub;
                        end
                        ave = nanmean(data.(met)(ind,:));
                        ave_all(sub,train) = ave;
                    end
                    se(pos,train) = nanstd(ave_all(:,train))/sqrt(sum(~isnan(ave_all(:,train))));
                    aves(pos,train) = nanmean(ave_all(:,train));
                    errorbar_ez('bar',xint((train-1)*nPos+pos),aves(pos,train),se(pos,train),.15,c(ctrain,:))
                end
            end
            
            if strcmp(met,'time')
                ylim([0 20])
                set(gca,'YTick',0:5:20)
                
                plot([xmid xmid],[0 20],'k--','Linewidth',1)
                plot([xmid2 xmid2],[0 20],'k--','Linewidth',1)
            else
                ylim([0 100])
                set(gca,'YTick',0:25:100)
                plot([xmid xmid],[0 100],'k--','Linewidth',1)
                plot([xmid2 xmid2],[0 100],'k--','Linewidth',1)
            end
            set(gca,'XTick',xint)
            if y_ind == 4
                set(gca,'XTickLabels',['P1'; 'P2';'P3';'P4';'P1'; 'P2';'P3';'P4';'P1'; 'P2';'P3';'P4'])
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
        
        xint = .15:.2:.2*nLd;
        xint = [xint xint+(.2*nLd+.1)];
        xmax = max(xint)+.15;
        se = zeros(nLd,2);
        aves = zeros(nLd,2);
        fig_ind = 2;
        nSub = max(data.sub);
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
                    errorbar_ez('bar',xint((train-1)*nLd+ld),aves(ld,train),se(ld,train),.1,c(train,:))
                end
            end
            
            
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
