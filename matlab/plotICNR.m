function plotICNR(data,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

%% initialize variables
if ~isfield(data,'ab')      % if data does not include ab and tr subs
    nSub = max(data.sub);
    nTrain = max(data.tr);
    nPos = max(data.pos);
    nLd = max(data.ld);
    nDOF = max(data.dof);
end
metNames = {'acc','RI','MSA_te','MSA_tr','SI_te','SI_tr','comp','time','move','stop','qual'};
posNames = {'P1','P2','P3','P4'};
dofNames = {'NM','HO','HC','WP','WS','WF','WE'};
switch type
    %% plot confusion matrices for feature space metrics, input = data
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
        % loop through metrics
        for met_i = [2 5 3]
            met = metNames{met_i};
            
            % loop through training method
            for train = 1:2
                mat_ab = nan(nLd,nPos,nDOF);
                mat_tr = mat_ab;
                for ld = 1:nLd
                    for pos = 1:nPos
                        for dof = 1:nDOF
                            temp_ab = nan(abSub,1);
                            temp_tr = nan(trSub,1);
                            for sub = 1:abSub
                                % indices for current training method, position, subject, load, and DOF
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
                    % get max values for color gradient scale
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
        %% plot feature metrics as bars for each condition, input = data
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
                                % get repeatability of only no movement
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
        %% plot correlation b/w two features w/o averaging, input = data.ab or data.tr
    case 'corr'
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
        %% input = data.ab or data.tr
    case 'corrall'
        %% correlation of features
        %         ab = data.ab;
        %         tr = data.tr;
        %         abSub = max(ab.sub);
        %         trSub = max(tr.sub);
        %         nLd = max(ab.ld);
        %         nPos = max(ab.pos);
        %         nDOF = max(ab.dof);
        %         nSub = abSub;
        
        met1 = 'RI';
        metNames = {'comp','time','move','stop'};
        for met2_i = 1:4
            met2 = metNames{met2_i};
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
                    pos = 1;
                    ld = 1;
                    %for ld = 1:nLd
                    %for pos = 1:nPos
                    %                         for dof = 1:nDOF
                    ind = data.tr == train & data.sub == sub;% & data.pos == pos & data.ld == ld;% & data.dof == dof;
                    if strcmp(met1,'RI')
                        met1_ind = nanmean(data.(met1)(ind & data.pos == 1 & data.ld == 1));
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
                    %end
                    %end
                    submean(sub) = nanmean(met2_all);
                    if sub < 15
                        subtype = 1;
                    else
                        subtype = 2;
                    end
                    plot(met1_all,met2_all,'.','Markersize',18,'color',c(subtype,:))
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
            annotation('textbox',[.7 .1 .3 .1],'String',['R = ' num2str(R(1,2))],'FitBoxToText','on');
            xlim(xa);
        end
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
        %% nice plots with correlation coeff and CIs, averaged across dofs & subs
    case 'corrmet3'
        met2_label = {'CR (%)','CT (s)','ME (%)','SE (%)'};
        met1_label = {'OA (%)', 'RI', 'SI'};
        marks = {'o','.'};
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
                            met1 = nan(nSub,1);
                            met2_sub = met1;
                            for sub = 1:nSub
                                ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub;
                                if met1_i == 1
                                    met1(sub) = nanmean(data.acc(ind));
                                    xmax = 100;
                                    xmin = 0;
                                elseif met1_i == 4
                                    met1(sub) = nanmean(data.acc(ind & data.dof == 1));
                                    xmin = 0;
                                    xmax = 100;
                                elseif met1_i == 2
                                    met1(sub) = -nanmean(data.RI(ind));
                                    xmax = 0;
                                    xmin = -12;
                                elseif met1_i == 3
                                    met1(sub) = nanmean(data.SI_te(ind));%./(data.RI(ind).*data.MSA_te(ind)));
                                    xmin = 0;
                                    xmax = 14;
                                else
                                    met1(sub) = nanmean(data.RI(ind & data.dof == 1));
                                    xmax = 25;
                                end
                                if met2_i == 2
                                    met2_sub(sub) = 20 - nanmean(data.(met2)(ind));
                                else
                                    met2_sub(sub) = nanmean(data.(met2)(ind));
                                end
                            end
                            met1_all = [met1_all; nanmean(met1)];
                            met2_all = [met2_all; nanmean(met2_sub)];
                            datamod = [datamod; train,pos,ld,nanmean(met1),nanmean(met2_sub)];
                            %datamod = [datamod; train,pos,ld,met1_ind,met2_ind];
                            %                                 plot(met1_ind,met2_ind,'.','Markersize',18,'color',c(dof,:))
                        end
                    end
                    %plot(met1_all,met2_all,'.','Markersize',18,'color',c(train,:))
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
                    plot(datamod(datamod(:,1) == train,4),datamod(datamod(:,1) == train,5),marks{train},'Markersize'...
                        ,6+(train-1)*16,'color',c(met1_i,:),'linewidth',1)%-(train-1).*[.2,.2,.2])
                end
                
                datamod = array2table(datamod,'variablenames',{'train','pos','ld','met1','met2'});
                mod = fitlme(datamod,'met2 ~ met1');
                [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1,'rows','complete');
                ci(met1_i,1) = RL(1,2);
                ci(met1_i,2) = R(1,2);
                ci(met1_i,3) = RU(1,2);
                disp([met2_label{met2_i} ', ' met1_label{met1_i} ' = [' num2str(RL(1,2)) ', ' ...
                    num2str(R(1,2)) ', ' num2str(RU(1,2)) ']'])
                disp('----')
                %xlim([xmin xmax])
                xa = xlim;
                ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
                plot(xa,ya,'k-','linewidth',1)
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
            yv = [3 2 1];
            assignin('base','ci',ci)
            for p = 1:3
                minci = min(ci(p,:));
                rectangle('position',[minci,yv(p)-.3,abs(ci(p,1)-ci(p,3)),0.6],'linewidth',1,'facecolor',c(p,:),'curvature',.2)
                plot([ci(p,2) ci(p,2)],[yv(p)-.3 yv(p)+.3],'k','linewidth',1)
            end
            set(gca,'yticklabel',[])
            if met2_i ~= 4
                set(gca,'xticklabel',[])
            else
                xlabel('R Confidence Intervals')
            end
            xlim([-1 1])
            ylim([.5 3.5])
            
        end
    case 'corrmet5'
        met2_label = {'CR (%)','CT (s)','ME (%)','SE (%)'};
        met1_label = {'OA (%)', 'RI', 'SI', 'MSA', 'DS'};
        marks = {'o','.'};
        met1_names = {'acc','RI','SI_te','MSA_tr','DS'};
        data.DS = data.SI_te./(data.RI.*data.MSA_tr);
        data.RI = -data.RI;
        figure
        [ax]= tight_subplot(4,5,[.03 .02],[.1 .05],[.1 0.03]);
        hold all
        c = linspecer(15);
        for met2_i = 1:4
            met2 = metNames{met2_i+6};
            ci = nan(3,3);
            for met1_i = 1:5
                axes(ax(met1_i + (met2_i-1)*5))
                hold all
                datamod = [];
                for train = 1:2
                    met1_all = [];
                    met2_all = [];
                    for ld = 1:nLd
                        for pos = 1:nPos
                            met1 = nan(nSub,1);
                            met2_sub = met1;
                            for sub = 1:nSub
                                ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub;
                                met1(sub) = nanmean(data.(met1_names{met1_i})(ind));
                                if met2_i == 2
                                    met2_sub(sub) = 20 - nanmean(data.(met2)(ind));
                                else
                                    met2_sub(sub) = nanmean(data.(met2)(ind));
                                end
                                met1_all = [met1_all; met1(sub)];
                                met2_all = [met2_all; met2_sub(sub)];
                                datamod = [datamod; train,pos,ld,sub,met1(sub),met2_sub(sub)];
                            end
%                             met1_all = [met1_all; met1];
%                             met2_all = [met2_all; met2_sub];
%                             datamod = [datamod; train,pos,ld,nanmean(met1),nanmean(met2_sub)];
                            %datamod = [datamod; train,pos,ld,met1_ind,met2_ind];
                            %                                 plot(met1_ind,met2_ind,'.','Markersize',18,'color',c(dof,:))
                        end
                    end
                    %plot(met1_all,met2_all,'.','Markersize',18,'color',c(train,:))
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
                    plot(datamod(datamod(:,1) == train,end-1),datamod(datamod(:,1) == train,end),marks{train},'Markersize'...
                        ,6+(train-1)*16,'color',c(met1_i,:),'linewidth',1)%-(train-1).*[.2,.2,.2])
                end
                
                datamod = array2table(datamod,'variablenames',{'train','pos','ld','sub','met1','met2'});
                mod = fitlme(datamod,'met2 ~ met1');
                [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1,'rows','complete');
                ci(met1_i,1) = RL(1,2);
                ci(met1_i,2) = R(1,2);
                ci(met1_i,3) = RU(1,2);
                disp([met2_label{met2_i} ', ' met1_label{met1_i} ' = [' num2str(RL(1,2)) ', ' ...
                    num2str(R(1,2)) ', ' num2str(RU(1,2)) ']'])
                disp('----')
                %xlim([xmin xmax])
                xa = xlim;
                ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
                plot(xa,ya,'k-','linewidth',1)
                annotation('textbox',[.7 .1 .3 .1],'String',['R = ' num2str(R(1,2),'%.2f')],'FitBoxToText','on','linestyle','none');
                xlim(xa);
                if met2_i == 4
                    xlabel(met1_label{met1_i})
                else
                    set(gca,'xticklabel','')
                end
            end            
        end
    case 'corrdof'
        data.time = 20 - data.time;
        met2_label = {'CR (%)','CT (s)','ME (%)','SE (%)'};
        met1_label = {'OA (%)', 'RI', 'SI'};
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
                            met1 = nan(nSub,1);
                            met2_sub = met1;
                            for dof = 1:nDOF
                                for sub = 1:nSub
                                    ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub & data.dof == dof;
                                    if met1_i == 1
                                        met1(sub) = nanmean(data.acc(ind));
                                        xmax = 100;
                                        xmin = 0;
                                    elseif met1_i == 4
                                        met1(sub) = nanmean(data.acc(ind & data.dof == 1));
                                        xmin = 0;
                                        xmax = 100;
                                    elseif met1_i == 2
                                        met1(sub) = -nanmean(data.RI(ind));
                                        xmax = 0;
                                        xmin = -12;
                                    elseif met1_i == 3
                                        met1(sub) = nanmean(data.SI_te(ind));
                                        xmin = 0;
                                        xmax = 14;
                                    else
                                        met1(sub) = nanmean(data.RI(ind & data.dof == 1));
                                        xmax = 25;
                                    end
                                    met2_sub(sub) = nanmean(data.(met2)(ind));
                                end
                                met1_all = [met1_all; nanmean(met1)];
                                met2_all = [met2_all; nanmean(met2_sub)];
                                datamod = [datamod; train,pos,ld,dof,nanmean(met1),nanmean(met2_sub)];
                            end
                            %datamod = [datamod; train,pos,ld,met1_ind,met2_ind];
                            %                                 plot(met1_ind,met2_ind,'.','Markersize',18,'color',c(dof,:))
                        end
                    end
                    %plot(met1_all,met2_all,'.','Markersize',18,'color',c(train,:))
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
                end
                plot(datamod(:,end-1),datamod(:,end),'.','Markersize',18,'color',c(met1_i,:))
                
                datamod = array2table(datamod,'variablenames',{'train','pos','ld','dof','met1','met2'});
                mod = fitlme(datamod,'met2 ~ met1');
                [R,p,RL,RU] = corrcoef(datamod.met2,datamod.met1,'rows','complete');
                ci(met1_i,1) = RL(1,2);
                ci(met1_i,2) = R(1,2);
                ci(met1_i,3) = RU(1,2);
                disp([met2_label{met2_i} ', ' met1_label{met1_i} ' = [' num2str(RL(1,2)) ', ' ...
                    num2str(R(1,2)) ', ' num2str(RU(1,2)) ']'])
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
            yv = [3 2 1];
            for p = 1:3
                minci = min(ci(p,:));
                rectangle('position',[minci,yv(p)-.3,abs(ci(p,1)-ci(p,3)),0.6],'linewidth',1,'facecolor',c(p,:),'curvature',.2)
                plot([ci(p,2) ci(p,2)],[yv(p)-.3 yv(p)+.3],'k','linewidth',1)
            end
            set(gca,'yticklabel',[])
            if met2_i ~= 4
                set(gca,'xticklabel',[])
            else
                xlabel('|R| Confidence Intervals')
            end
            xlim([-1 1])
            ylim([.5 3.5])
            
        end
    case 'corrsplit'
        met2_label = {'Completion\newlineRate (%)','Completion\newlineTime (s)','Movement\newlineEfficacy (%)','Stopping\newlineEfficacy (%)'};
        met1_label = {'Offline Accuracy (%)', 'Repeatability', 'Separability'};
        figure
        [ax]= tight_subplot(4,3,[.03 .02],[.1 .05],[.1 0.03]);
        hold all
        c = linspecer(10);
        for met2_i = 1:4
            met2 = metNames{met2_i+6};
            ci = nan(3,3);
            for met1_i = 1:3
                axes(ax(met1_i + (met2_i-1)*3))
                hold all
                datamod = [];
                for train = 1:2
                    met1_all = [];
                    met2_all = [];
                    for ld = 1:nLd
                        for pos = 1:nPos
                            met1 = nan(nSub,1);
                            met2_sub = met1;
                            for sub = 1:nSub
                                ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub;
                                if met1_i == 1
                                    met1(sub) = nanmean(data.acc(ind));
                                    xmax = 100;
                                    xmin = 0;
                                elseif met1_i == 4
                                    met1(sub) = nanmean(data.acc(ind & data.dof == 1));
                                    xmin = 0;
                                    xmax = 100;
                                elseif met1_i == 2
                                    met1(sub) = -nanmean(data.RI(ind));
                                    xmax = 0;
                                    xmin = -12;
                                elseif met1_i == 3
                                    met1(sub) = nanmean(data.SI_te(ind));
                                    xmin = 0;
                                    xmax = 14;
                                else
                                    met1(sub) = nanmean(data.RI(ind & data.dof == 1));
                                    xmax = 25;
                                end
                                met2_sub(sub) = nanmean(data.(met2)(ind));
                            end
                            met1_all = [met1_all; nanmean(met1)];
                            met2_all = [met2_all; nanmean(met2_sub)];
                            datamod = [datamod; train,pos,ld,nanmean(met1),nanmean(met2_sub)];
                        end
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
                end
                
                i_true = [2,1,3];
                for i = 1:3
                    datatab = array2table(datamod(datamod(:,1) ~= i,:),'variablenames',{'train','pos','ld','met1','met2'});
                    mod{i_true(i)} = fitlme(datatab,'met2 ~ met1');
                    R{i_true(i)} = corrcoef(datatab.met2,datatab.met1,'rows','complete');
                end
                xlim([xmin xmax])
                xa = xlim;
                c(3,:) = [0,0,0];
                for mod_i = 1:3
                    ya = mod{mod_i}.Coefficients(2,2).Estimate.*xa+mod{mod_i}.Coefficients(1,2).Estimate;
                    plot(xa,ya,'-','linewidth',1.5,'color',c(mod_i,:))
                    annotation('textbox',[.7 .1 .3 .1],'String',[num2str(R{mod_i}(1,2),'%.2f')],'FitBoxToText','on','linestyle','none','color',c(mod_i,:));
                end
                xlim(xa);
                if met2_i == 4
                    xlabel(met1_label{met1_i})
                else
                    set(gca,'xticklabel','')
                end
            end
        end
    case 'dof'
        figure
        [ax] = tight_subplot(nPos,nLd,[.02 .02],[.1 .1],[.1 .1]);
        fig_ind = 1;
        for pos = 1:nPos
            for ld = 1:nLd
                axes(ax(fig_ind));
                hold all
                for dof = 1:nDOF
                    for train = 1%:nTrain
                        ind = data.pos == pos & data.ld == ld & data.dof == dof & data.tr == train;
                        for sub = 1:nSub
                            plot(dof,nanmean(data.qual(ind)),'.','markersize',15)
                        end
                    end
                end
                ylim([0 100])
                set(gca,'XTick',[])
                set(gca,'LineWidth',1)
                if ld > 1
                    set(gca,'YTick',[])
                end
                fig_ind = fig_ind + 1;
            end
        end
end