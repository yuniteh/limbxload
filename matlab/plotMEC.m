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
        for met_i = [2 1 7]
            met = metNames{met_i};
            for train = 1
                mat_ab = nan(nLd,nPos,abSub);
                mat_tr = nan(nLd,nPos,trSub);
                for ld = 1:nLd
                    for pos = 1:nPos
                        for sub = 1:abSub
                            
                            ind_ab = ab.tr == train & ab.pos == pos & ab.sub == sub & ab.ld == ld;
                            mat_ab(ld,pos,sub) = nanmean(ab.(met)(ind_ab));
                            %                             if strcmp(met,'RI')
                            %                                 mat_ab(ld,pos,sub) = 1./nanmean(ab.(met)(ind_ab & ab.dof == 1));
                            %                                 mat_ab(ld,pos,sub) = 1./mat_ab(ld,pos,sub);
                            %                             end
                        end
                        for sub = 1:trSub
                            ind_tr = tr.tr == train & tr.pos == pos & tr.sub == sub & tr.ld == ld;
                            mat_tr(ld,pos,sub) = nanmean(tr.(met)(ind_tr));
                            %                             if strcmp(met,'RI')
                            %                                 mat_tr(ld,pos,sub) = 1./nanmean(tr.(met)(ind_tr & tr.dof == 1));
                            %                                 mat_tr(ld,pos,sub) = 1./mat_tr(ld,pos,sub);
                            %                             end
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
                        errorbar_ez('bar',pos, nanmean(matabLd(pos,:)),nanstd(matabLd(pos,:))./sum(~isnan(matabLd(pos,:))),.4,cblue(pos,:))
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
                        axes(ax_tr(fig_ind + (y_ind-1)*nLd));
                        hold all
                        errorbar_ez('bar',pos, nanmean(mattrLd(pos,:)),nanstd(mattrLd(pos,:))./sum(~isnan(mattrLd(pos,:))),.4,cblue(pos,:))
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
        disp(train)
        disp(mod.Coefficients(2,2))
        disp(mod.Rsquared.Adjusted)
        disp('----')
        xa = xlim;
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
        met1 = 'RI';
        met2 = 'move';
        figure
        hold all
        met1_all = [];
        met2_all = [];
        c = linspecer(nSub);
        datamod = [];
        for train = 1:2
            met1_all = [];
            met2_all = [];
            for ld = 1:nLd
                for pos = 1:nPos
                    for dof = 1:nDOF
                        ind = data.tr == train & data.pos == pos & data.ld == ld;% & data.sub == sub;% & data.dof == dof;
                        if strcmp(met1,'RI') || strcmp(met1,'SI_te')
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
            ylim([0 100])
            %                 xlim([0 100])
        end
        datamod = array2table(datamod,'variablenames',{'train','pos','ld','met1','met2'});
        mod = fitlme(datamod,'met2 ~ met1');
        disp(mod.Coefficients(2,2))
        disp(mod.Rsquared.Adjusted)
        disp('----')
        xa = xlim;
        ya = mod.Coefficients(2,2).Estimate.*xa+mod.Coefficients(1,2).Estimate;
        plot(xa,ya,'k-','linewidth',2)
        annotation('textbox',[.7 .1 .3 .1],'String',['R^2 = ' num2str(mod.Rsquared.Adjusted)],'FitBoxToText','on');
        xlim(xa);
end
