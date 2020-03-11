function plotMEC(data,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

%% initialize variables
if ~isfield(data,'ab')
    nSub = max(data.sub);
    nTrain = max(data.tr);
    nPos = max(data.pos);
    nLd = max(data.ld);
    nDOF = max(data.dof);
end
metNames = {'acc','RI','MSA_te','MSA_tr','SI_te','SI_tr','comp','time','move','stop'};
posNames = {'P1','P2','P3','P4'};
dofNames = {'NM','HO','HC','WP','WS','WF','WE'};
switch type
    case 'matrix'
        ab = data.ab;
        tr = data.tr;
        abSub = max(ab.sub);
        trSub = max(tr.sub);
        nLd = max(ab.ld);
        nPos = max(ab.pos);
        nDOF = max(ab.dof);
        %% matrix of features
        figure
        nMet = 3;
        [ax_ab]= tight_subplot(nMet,nLd,[.03 .02],[.1 .1],[.09 0.03]);
        figure
        [ax_tr] = tight_subplot(nMet,nLd,[.03 .02],[.1 .1],[.09 0.03]);
        
        y_ind = 1;
        for met_i = [2 5 3]
            met = metNames{met_i};
            
            for train = 2
                mat_ab = nan(nLd,nPos,nDOF);
                mat_tr = mat_ab;
                for ld = 1:nLd
                    for pos = 1:nPos
                        for dof = 1:nDOF
                            temp_ab = nan(abSub,1);
                            temp_tr = nan(trSub,1);
                            for sub = 1:abSub
                                ind_ab = ab.tr == train & ab.pos == pos & ab.sub == sub & ab.ld == ld & ab.dof == dof;
                                temp_ab(sub) = nanmean(ab.(met)(ind_ab));
                            end
                            for sub = 1:trSub
                                ind_tr = tr.tr == train & tr.pos == pos & tr.sub == sub & tr.ld == ld & tr.dof == dof;
                                temp_tr(sub) = nanmean(tr.(met)(ind_tr));
                            end
                            mat_ab(ld,pos,dof) = nanmean(temp_ab);
                            mat_tr(ld,pos,dof) = nanmean(temp_tr);
                            
                        end
                    end
                end
                fig_ind = 1;
                for ld = 1:nLd
                    matabLd = squeeze(mat_ab(ld,:,:));
                    mattrLd = squeeze(mat_tr(ld,:,:));
                    maxMet = max([max(mat_ab(:)) max(mat_tr(:))]);
                    
                    if fig_ind == 1
                        posLabel = posNames;
                        yLabel = met;
                        if y_ind == nMet
                            dofLabel = dofNames;
                        else
                            dofLabel = ' ';
                        end
                    else
                        posLabel = ' ';
                        yLabel = ' ';
                        if y_ind == nMet
                            dofLabel = dofNames;
                        else
                            dofLabel = ' ';
                        end
                    end
                    axes(ax_ab(fig_ind + (y_ind-1)*nLd));
                    plotMat(matabLd,'xticks',dofLabel,'yticks',posLabel,'colors','blue',...
                        'range',[0 maxMet],'xlabel',' ','ylabel',yLabel)
                    axes(ax_tr(fig_ind + (y_ind-1)*nLd));
                    plotMat(mattrLd,'xticks',dofLabel,'yticks',posLabel,'colors','blue',...
                        'range',[0 maxMet],'xlabel',' ','ylabel',yLabel)
                    fig_ind = fig_ind + 1;
                    
                end
                
            end
            y_ind = y_ind + 1;
        end
    case 'bars'
        ab = data.ab;
        tr = data.tr;
        abSub = max(ab.sub);
        trSub = max(tr.sub);
        nLd = max(ab.ld);
        nPos = max(ab.pos);
        nDOF = max(ab.dof);
        %% matrix of features
        figure
        nMet = 3;
        [ax_ab]= tight_subplot(nMet,nLd,[.03 .02],[.1 .1],[.09 0.03]);
        figure
        [ax_tr] = tight_subplot(nMet,nLd,[.03 .02],[.1 .1],[.09 0.03]);
        
        y_ind = 1;
        for met_i = [2 1 9]
            met = metNames{met_i};
            for train = 2
                mat_ab = nan(nLd,nPos,abSub);
                mat_tr = nan(nLd,nPos,trSub);
                for ld = 1:nLd
                    for pos = 1:nPos
                        for sub = 1:abSub
                            
                            ind_ab = ab.tr == train & ab.pos == pos & ab.sub == sub & ab.ld == ld;
                            mat_ab(ld,pos,sub) = nanmean(ab.(met)(ind_ab));
                            if strcmp(met,'RI')
                                mat_ab(ld,pos,sub) = nanmean(ab.(met)(ind_ab & ab.dof == 1));
                                %                                 mat_ab(ld,pos,sub) = 1./mat_ab(ld,pos,sub);
                            end
                        end
                        for sub = 1:trSub
                            ind_tr = tr.tr == train & tr.pos == pos & tr.sub == sub & tr.ld == ld;
                            mat_tr(ld,pos,sub) = nanmean(tr.(met)(ind_tr));
                            if strcmp(met,'RI')
                                mat_tr(ld,pos,sub) = nanmean(tr.(met)(ind_tr & tr.dof == 1));
                                %                                 mat_tr(ld,pos,sub) = 1./mat_tr(ld,pos,sub);
                            end
                        end
                    end
                end
                fig_ind = 1;
                assignin('base','matab',mat_ab)
                assignin('base','mattr',mat_tr)
                for ld = 1:nLd
                    matabLd = squeeze(mat_ab(ld,:,:));
                    mattrLd = squeeze(mat_tr(ld,:,:));
                    
                    if fig_ind == 1
                        maxVal = max([max(mat_ab(:)) max(mat_tr(:))]);
                        yTicks = 0:maxVal/5:maxVal;
                        yLabel = met;
                        if y_ind == nMet
                            posLabel = posNames;
                        else
                            posLabel = ' ';
                        end
                    else
                        yTicks = [];
                        yLabel = ' ';
                        if y_ind == nMet
                            posLabel = posNames;
                        else
                            posLabel = ' ';
                        end
                    end
                    for pos = 1:nPos
                        axes(ax_ab(fig_ind + (y_ind-1)*nLd));
                        hold all
                        errorbar_ez('bar',pos, nanmean(matabLd(pos,:)),nanstd(matabLd(pos,:))./sqrt(sum(~isnan(matabLd(pos,:)))),.4,cblue(pos,:))
                        if isempty(yTicks)
                            set(gca,'YTick',[])
                        else
                            ylabel(met);
                        end
                        if y_ind == nMet
                            set(gca,'XTick',1:nPos)
                            set(gca,'XTickLabel',posNames)
                        else
                            set(gca,'XTick',[])
                        end
                        
                        if strcmp(met,'RI')
                            ylim([0 maxVal])
                        else
                            ylim([0 100])
                        end
                        xlim([0 5])
                        axes(ax_tr(fig_ind + (y_ind-1)*nLd));
                        hold all
                        errorbar_ez('bar',pos, nanmean(mattrLd(pos,:)),nanstd(mattrLd(pos,:))./sqrt(sum(~isnan(mattrLd(pos,:)))),.4,cblue(pos,:))
                        if isempty(yTicks)
                            set(gca,'YTick',[])
                        else
                            ylabel(met);
                        end
                        if y_ind == nMet
                            set(gca,'XTick',1:nPos)
                            set(gca,'XTickLabel',posNames)
                        else
                            set(gca,'XTick',[])
                        end
                        if strcmp(met,'RI')
                            ylim([0 maxVal])
                        else
                            ylim([0 100])
                        end
                        xlim([0 5])
                    end
                    fig_ind = fig_ind + 1;
                    
                end
                
            end
            y_ind = y_ind + 1;
        end
    case 'corr'
        %% correlation of features
        met1 = 'RI';
        met2 = 'move';
        figure
        hold all
        met1_all = [];
        met2_all = [];
        c = linspecer(nSub);
        datamod = [];
        for train = 1:2
            %             datamod = [];
            submean = zeros(nSub,1);
            for sub = 1:nSub
                met1_all = [];
                met2_all = [];
                %                 subplot(1,nSub,sub)
                for ld = 1:nLd
                    for pos = 1:nPos
                        %                         for dof = 1:nDOF
                        ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub;% & data.dof == dof;
                        if strcmp(met1,'RI')
                            met1_ind = nanmean(data.(met1)(ind & data.dof == 1));
                        elseif strcmp(met1,'RI/SI')
                            met1_ind = nanmean(data.RI(ind)./data.SI_te(ind));
                        else
                            met1_ind = nanmean(data.(met1)(ind));
                        end
                        met2_ind = nanmean(data.(met2)(ind));
                        met1_all = [met1_all; met1_ind];
                        met2_all = [met2_all; met2_ind];
                        %                         end
                        datamod = [datamod; sub,train,pos,ld,met1_ind,met2_ind];
                    end
                end
                submean(sub) = nanmean(met2_all);
                plot(met1_all,met2_all,'.','Markersize',18,'color',c(sub,:))
                ylabel(met2)
                xlabel(met1)
                %                 ylim([0 100])
            end
        end
        datamod = array2table(datamod,'variablenames',{'sub','train','pos','ld','met1','met2'});
        datamod.sub = nominal(datamod.sub);
        mod = fitlme(datamod,'met2 ~ met1+(1|sub)');%,'dummyvarcoding','effects')
        [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1,'rows','complete')
        disp(train)
        disp(mod.Coefficients(2,2))
        disp(mod.Rsquared.Adjusted)
        disp('----')
        xa = xlim;
        yl = ylim;
        ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
        plot(xa,ya,'k-','linewidth',2)
        annotation('textbox',[.7 .1 .3 .1],'String',['R^2 = ' num2str(mod.Rsquared.Ordinary)],'FitBoxToText','on');
        xlim(xa);
    case 'corrall'
        %% correlation of features
        ab = data.ab;
        tr = data.tr;
        abSub = max(ab.sub);
        trSub = max(tr.sub);
        nLd = max(ab.ld);
        nPos = max(ab.pos);
        nDOF = max(ab.dof);
        
        met1 = 'RI';
        met2 = 'move';
        figure
        hold all
        met1_all = [];
        met2_all = [];
        c = linspecer(nSub);
        datamod = [];
        for train = 1:2
            %             datamod = [];
            submean = zeros(nSub,1);
            for sub = 1:nSub
                met1_all = [];
                met2_all = [];
                %                 subplot(1,nSub,sub)
                for ld = 1:nLd
                    for pos = 1:nPos
                        %                         for dof = 1:nDOF
                        ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub;% & data.dof == dof;
                        if strcmp(met1,'RI')
                            met1_ind = nanmean(data.(met1)(ind & data.dof == 1));
                        elseif strcmp(met1,'RI/SI')
                            met1_ind = nanmean(data.RI(ind)./data.SI_te(ind));
                        else
                            met1_ind = nanmean(data.(met1)(ind));
                        end
                        met2_ind = nanmean(data.(met2)(ind));
                        met1_all = [met1_all; met1_ind];
                        met2_all = [met2_all; met2_ind];
                        %                         end
                        datamod = [datamod; sub,train,pos,ld,met1_ind,met2_ind];
                    end
                end
                submean(sub) = nanmean(met2_all);
                plot(met1_all,met2_all,'.','Markersize',18,'color',c(sub,:))
                ylabel(met2)
                xlabel(met1)
                %                 ylim([0 100])
            end
        end
        datamod = array2table(datamod,'variablenames',{'sub','train','pos','ld','met1','met2'});
        datamod.sub = nominal(datamod.sub);
        mod = fitlme(datamod,'met2 ~ met1+(1|sub)');%,'dummyvarcoding','effects')
        [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1,'rows','complete')
        disp(train)
        disp(mod.Coefficients(2,2))
        disp(mod.Rsquared.Adjusted)
        disp('----')
        xa = xlim;
        ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
        plot(xa,ya,'k-','linewidth',2)
        annotation('textbox',[.7 .1 .3 .1],'String',['R^2 = ' num2str(mod.Rsquared.Ordinary)],'FitBoxToText','on');
        xlim(xa);
    case 'corrmean'
        %% correlation of features
        met1 = 'acc';
        met2 = 'move';
        figure
        [ax]= tight_subplot(2,2,[.08 .08],[.1 .1],[.09 0.03]);
        hold all
        c = linspecer(nSub);
        for met2_i = 1:4
            met2 = metNames{met2_i+6};
            axes(ax(met2_i))
            hold all
            datamod = [];
            for train = 1:2
                met1_all = [];
                met2_all = [];
                for ld = 1:nLd
                    for pos = 1:nPos
                        for dof = 1:nDOF
                            ind = data.tr == train & data.pos == pos & data.ld == ld;% & data.sub == sub;% & data.dof == dof;
                            if strcmp(met1,'RI') || strcmp(met1,'SI_te') || strcmp(met1,'acc')
                                met1_ind = nanmean(data.(met1)(ind & data.dof == 1));
                            elseif strcmp(met1,'RI/SI')
                                met1_ind = nanmean(data.RI(ind)./data.SI_te(ind));
                            else
                                met1_ind = nanmean(data.(met1)(ind));
                            end
                            met2_ind = nanmean(data.(met2)(ind));
                            met1_all = [met1_all; met1_ind];
                            met2_all = [met2_all; met2_ind];
                            datamod = [datamod; train,pos,ld,met1_ind,met2_ind];
                        end
                    end
                end
                plot(met1_all,met2_all,'.','Markersize',18,'color',c(train,:))
                ylabel(met2)
                xlabel(met1)
                if strcmp(met2,'time')
                    ylim([0 20])
                else
                    ylim([0 100])
                end
                %                 xlim([0 100])
            end
            datamod = array2table(datamod,'variablenames',{'train','pos','ld','met1','met2'});
            mod = fitlme(datamod,'met2 ~ met1');
            [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1)
            disp(mod.Coefficients(2,2))
            disp(mod.Rsquared.Adjusted)
            disp('----')
            if strcmp(met1,'acc')
                xlim([0 100])
            else
                xlim([0 25])
            end
            xa = xlim;
            ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
            plot(xa,ya,'k-','linewidth',2)
            annotation('textbox',[.7 .1 .3 .1],'String',['R^2 = ' num2str(mod.Rsquared.Adjusted,'%.2f') '\newline R = ' num2str(R(1,2),'%.2f') ' ['...
                num2str(RL(1,2),'%.2f') ', ' num2str(RU(1,2),'%.2f') ']'],'FitBoxToText','on');
            xlim(xa);
        end
    case 'corrmet'
        %% correlation of features
        met1 = 'acc';
        met2 = 'move';
        met2_label = {'Completion\newlineRate (%)','Completion\newlineTime (s)','Movement\newlineEfficacy (%)','Stopping\newlineEfficacy (%)'};
        met1_label = {'Offline Accuracy (%)', 'Repeatability'};
        figure
        [ax]= tight_subplot(4,2,[.04 .04],[.1 .05],[.15 0.03]);
        hold all
        c = linspecer(14);
        for met2_i = 1:4
            met2 = metNames{met2_i+6};
            for met1_i = 1:2
                axes(ax(met1_i + (met2_i-1)*2))
                hold all
                datamod = [];
                for train = 1:2
                    met1_all = [];
                    met2_all = [];
                    for ld = 1:nLd
                        for pos = 1:nPos
                            for dof = 1:nDOF
                                ind = data.tr == train & data.pos == pos & data.ld == ld;% & data.sub == sub;% & data.dof == dof;
                                if met1_i == 1
                                    met1_ind = nanmean(data.acc(ind));
                                    xmax = 100;
                                    xmin = 0;
                                elseif met1_i == 3
                                    met1_ind = nanmean(data.acc(ind & data.dof == 1));
                                    xmax = 100;
                                elseif met1_i == 2
                                    met1_ind = nanmean(data.SI_te(ind));
                                    xmax = 0;
                                    xmin = -12;
                                else
                                    met1_ind = nanmean(data.RI(ind & data.dof == 1));
                                    xmax = 25;
                                end
                                met2_ind = nanmean(data.(met2)(ind));
                                met1_all = [met1_all; met1_ind];
                                met2_all = [met2_all; met2_ind];
                                datamod = [datamod; train,pos,ld,met1_ind,met2_ind];
                            end
                        end
                    end
                    if met1_i == 2
                        met1_all = -met1_all;
                    end
                    plot(met1_all,met2_all,'.','Markersize',18,'color',c(train,:))
                    if met1_i == 1
                        ylabel(met2_label{met2_i})
                    else
                        set(gca,'yticklabel','')
                    end
                    
                    if strcmp(met2,'time')
                        ylim([0 20])
                    else
                        ylim([0 100])
                    end
                    %                 xlim([0 100])
                end
                datamod = array2table(datamod,'variablenames',{'train','pos','ld','met1','met2'});
                if met1_i == 2
                    datamod.met1 = -datamod.met1;
                end
                mod = fitlme(datamod,'met2 ~ met1');
                [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1)
                disp(mod.Coefficients(2,2))
                disp(mod.Rsquared.Adjusted)
                disp('----')
                xlim([xmin xmax])
                xa = xlim;
                ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
                plot(xa,ya,'k-','linewidth',2)
                %             annotation('textbox',[.7 .1 .3 .1],'String',['R^2 = ' num2str(mod.Rsquared.Adjusted,'%.2f') '\newline R = ' num2str(R(1,2),'%.2f') ' ['...
                %                 num2str(RL(1,2),'%.2f') ', ' num2str(RU(1,2),'%.2f') ']'],'FitBoxToText','on');
                annotation('textbox',[.7 .1 .3 .1],'String',['R = ' num2str(R(1,2),'%.2f')],'FitBoxToText','on');
                xlim(xa);
                if met2_i == 4
                    xlabel(met1_label{met1_i})
                else
                    set(gca,'xticklabel','')
                end
            end
        end
    case 'corrmet3'
        %% correlation of features
        met1 = 'acc';
        met2 = 'move';
        met2_label = {'Completion\newlineRate (%)','Completion\newlineTime (s)','Movement\newlineEfficacy (%)','Stopping\newlineEfficacy (%)'};
        met1_label = {'Offline Accuracy (%)', 'Repeatability', 'Separability'};
        figure
        [ax]= tight_subplot(4,4,[.03 .02],[.1 .05],[.1 0.03]);
        hold all
        c = linspecer(10);
        for met2_i = 1:4
            met2 = metNames{met2_i+6};
            ci = nan(3,3);
            for met1_i = 1:3
                axes(ax(met1_i + (met2_i-1)*4))
                hold all
                datamod = [];
                for train = 1:2
                    met1_all = [];
                    met2_all = [];
                    for ld = 1:nLd
                        for pos = 1:nPos
                            for dof = 1:nDOF
                                ind = data.tr == train & data.pos == pos & data.ld == ld;% & data.sub == sub;% & data.dof == dof;
                                if met1_i == 1
                                    met1_ind = nanmean(data.acc(ind));
                                    xmax = 100;
                                    xmin = 0;
                                elseif met1_i == 4
                                    met1_ind = nanmean(data.acc(ind & data.dof == 1));
                                    xmax = 100;
                                elseif met1_i == 2
                                    met1_ind = nanmean(data.RI(ind));
                                    xmax = 0;
                                    xmin = -12;
                                elseif met1_i == 3
                                    met1_ind = nanmean(data.SI_te(ind));
                                    xmin = 0;
                                    xmax = 14;
                                else
                                    met1_ind = nanmean(data.RI(ind & data.dof == 1));
                                    xmax = 25;
                                end
                                met2_ind = nanmean(data.(met2)(ind));
                                met1_all = [met1_all; met1_ind];
                                met2_all = [met2_all; met2_ind];
                                datamod = [datamod; train,pos,ld,met1_ind,met2_ind];
                            end
                        end
                    end
                    if met1_i == 2
                        met1_all = -met1_all;
                    end
                    plot(met1_all,met2_all,'.','Markersize',18,'color',c(met1_i,:))
                    if met1_i == 1
                        ylabel(met2_label{met2_i})
                    else
                        set(gca,'yticklabel','')
                    end
                    
                    if strcmp(met2,'time')
                        ylim([0 20])
                    else
                        ylim([0 100])
                    end
                    %                 xlim([0 100])
                end
                datamod = array2table(datamod,'variablenames',{'train','pos','ld','met1','met2'});
                if met1_i == 2
                    datamod.met1 = -datamod.met1;
                end
                mod = fitlme(datamod,'met2 ~ met1');
                [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1)
                ci(met1_i,1) = RL(1,2);
                ci(met1_i,2) = R(1,2);
                ci(met1_i,3) = RU(1,2);
                disp(mod.Coefficients(2,2))
                disp(mod.Rsquared.Adjusted)
                disp('----')
                xlim([xmin xmax])
                xa = xlim;
                ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
                plot(xa,ya,'k-','linewidth',1.5)
%                             annotation('textbox',[.7 .1 .3 .1],'String',['R^2 = ' num2str(mod.Rsquared.Adjusted,'%.2f') '\newline R = ' num2str(R(1,2),'%.2f') ' ['...
                %                 num2str(RL(1,2),'%.2f') ', ' num2str(RU(1,2),'%.2f') ']'],'FitBoxToText','on');
                annotation('textbox',[.7 .1 .3 .1],'String',['R = ' num2str(R(1,2),'%.2f')],'FitBoxToText','on','linestyle','none');
                xlim(xa);
                if met2_i == 4
                    xlabel(met1_label{met1_i})
                else
                    set(gca,'xticklabel','')
                end
            end
            axes(ax(4+(met2_i-1)*4))
            hold all
            oa = ones(1,3);
            yv = [3 2 1]
            c2 = linspecer(10);
            for p = 1:3
                minci = min(abs(ci(p,:)));
                rectangle('position',[minci,yv(p)-.3,abs(ci(p,1)-ci(p,3)),0.6],'linewidth',1,'facecolor',c(p,:),'curvature',.2)
                plot([abs(ci(p,2)) abs(ci(p,2))],[yv(p)-.3 yv(p)+.3],'k','linewidth',1)
%                 plot(abs(ci(p,:)),oa.*p,'-','color',c(p+2,:),'linewidth',1.5)
%                 plot(abs(ci(p,2)),p,'.','MarkerSize',18,'color',c(p+2,:))
            end
            set(gca,'yticklabel',[])
            if met2_i ~= 4
                set(gca,'xticklabel',[])
            else
                xlabel('|R| Confidence Intervals')
            end
            ylim([.5 3.5])
            
        end
end
