loadl = {'0g','400g','600g'};
for i = 1:3
    subplot(1,3,i)
    plotMat(RI_mat{i},'range',[0 20],'xticks',{'NM','HO','HC','WP','WS','WF','WE'},'yticks',{'P1','P2','P3','P4'},'ylabel',[],'xlabel',[])
    title(loadl(i))
end
figure
for i = 1:3
    subplot(1,3,i)
    plotMat(MSA_mat{i},'range',[.5 2],'xticks',{'NM','HO','HC','WP','WS','WF','WE'},'yticks',{'P1','P2','P3','P4'},'ylabel',[],'xlabel',[])
    title(loadl(i))
end
figure
for i = 1:3
    subplot(1,3,i)
    plotMat(SI_mat{i},'range',[5 20],'xticks',{'NM','HO','HC','WP','WS','WF','WE'},'yticks',{'P1','P2','P3','P4'},'ylabel',[],'xlabel',[])
    title(loadl(i))
end
%%
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cgreen = linspecer(5,'green');
cgreen = flipud(cgreen);

%%
load = 3;

figure

for load = 1:3
    subplot(1,3,load)
    hold all
    for i = 1:4
        for j = 1
            circles(RI_mat{1}(1,j),0-5*(i-1),MSA_mat{1}(1,j),'edgecolor',cblue(1,:),'facealpha',0,'LineWidth',1.5)
            circles(RI_mat{load}(i,j),0-5*(i-1),MSA_mat{load}(i,j),'edgecolor',cblue(i,:),'facealpha',0,'LineWidth',1.5)
            plot([0 RI_mat{load}(i,j)],[0-5*(i-1) 0-5*(i-1)],'--','color',cblue(i,:))
            circles(nanmean(RI_mat{1}(1,2:end)),0-5*(i-1),nanmean(MSA_mat{1}(1,2:end)),'edgecolor',cgreen(1,:),'facealpha',0,'LineWidth',1.5)
            
            circles(nanmean(RI_mat{load}(i,2:end)),0-5*(i-1),nanmean(MSA_mat{load}(i,2:end)),'edgecolor',cgreen(i,:),'facealpha',0,'LineWidth',1.5)
            plot([0 MSA_mat{load}(i,j)],[0-5*(i-1) 0-5*(i-1)],'--','color',cgreen(i,:))
        end
    end
    ylim([-20 5])
    xlim([-5 25])
    set(gca,'YTick',-5*3:5:0)
    set(gca,'YTickLabels',[{'P4'} {'P3'} {'P2'} {'P1'}])
    grid on
end

%%
nLoads = max(data_train(:,2));
nPos = max(data_train(:,3));
figure
[ax]=tight_subplot(3,nLoads,[.03 .02],[.08 .08],[.09 0.03]);
fig_ind = 1;
for met = 5:7
    for load = 1:nLoads
        axes(ax(fig_ind));
        for pos = 1:nPos
            ind = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) == 1;
            ind2 = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) ~= 1;
            vs = violinplot(data_train(ind,met),j,'ViolinAlpha',.7,'PosSpec',pos*2,'ShowData',true,'ShowViolin',false,'LineWidth',1.5,'ViolinColor',cblue(pos,:),'Min',0);
            %vs = violinplot(data_train(ind2,met),j,'ViolinAlpha',.7,'PosSpec',pos*2+.8,'ShowData',false,'ShowViolin',false,'LineWidth',1.5,'ViolinColor',cgreen(pos,:),'Min',0);
            
        end
        %ylim([0 50])
        xlim([1 nPos*2+.4+1])
        if met == 7
            set(gca,'XTick',2+.4:2:nPos*2+.4)
            set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
        else
            set(gca,'XTick',[])
        end
        if load > 1
            set(gca,'YTick',[])
        else
            ylabel('Repeatability Index')
        end
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
    end
end

figure
[ax]=tight_subplot(3,nLoads,[.03 .02],[.08 .08],[.09 0.03]);
fig_ind = 1;
for met = 5:7
    for load = 1:nLoads
        axes(ax(fig_ind));
        for pos = 1:nPos
            ind = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) == 1;
            ind2 = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) ~= 1;
            %vs = violinplot(data_train(ind,met),j,'ViolinAlpha',.7,'PosSpec',pos*2,'ShowData',false,'ShowViolin',false,'LineWidth',1.5,'ViolinColor',cblue(pos,:),'Min',0);
            vs = violinplot(data_train(ind2,met),j,'ViolinAlpha',.7,'PosSpec',pos*2,'ShowData',false,'ShowViolin',true,'LineWidth',1.5,'ViolinColor',cgreen(pos,:),'Min',0);
            
        end
        %ylim([0 50])
        xlim([1 nPos*2+.4+1])
        if met == 7
            set(gca,'XTick',2+.4:2:nPos*2+.4)
            set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
        else
            set(gca,'XTick',[])
        end
        if load > 1
            set(gca,'YTick',[])
        else
            ylabel('Repeatability Index')
        end
        set(gca,'linewidth',1)
        fig_ind = fig_ind + 1;
    end
end

%%
nLoads = max(data_train(:,2));
nPos = max(data_train(:,3));
figure
[ax]=tight_subplot(1,nLoads,[.03 .02],[.08 .08],[.09 0.03]);
for load = 1:nLoads
    axes(ax(load));
    for pos = 1:nPos
        ind = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) == 1;
        ind2 = data_train(:,2) == load & data_train(:,3) == pos & data_train(:,4) ~= 1;
        vs = violinplot(data_train(ind,6),j,'ViolinAlpha',.7,'PosSpec',pos*2,'ShowData',false,'LineWidth',1.5,'ViolinColor',cblue(pos,:),'Min',0);
        vs = violinplot(data_train(ind2,6),j,'ViolinAlpha',.7,'PosSpec',pos*2+.8,'ShowData',false,'LineWidth',1.5,'ViolinColor',cgreen(pos,:),'Min',0);
        
    end
    ylim([0 50])
    xlim([1 nPos*2+.4+1])
    set(gca,'XTick',2+.4:2:nPos*2+.4)
    set(gca,'XTickLabels',[{'P1'} {'P2'} {'P3'} {'P4'}])
    if load > 1
        set(gca,'YTick',[])
    else
        ylabel('Repeatability Index')
    end
    set(gca,'linewidth',1)
end
