function plotMEC(data,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

%% initialize variables
if isfield(data,'sub')
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
            
            for train = 1
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
    case 'corr'
        %% correlation of features
        met1 = 2;
        met2 = 10;
        met1 = metNames{met1};
        met2 = metNames{met2};
        figure
        hold all
        met1_all = [];
        met2_all = [];
        c = linspecer(nSub);
        for train = 1
            for sub = 1:nSub
                met1_all = [];
                met2_all = [];
                %                 subplot(1,nSub,sub)
                for ld = 1:nLd
                    for pos = 1:nPos
                        
                        ind = data.tr == train & data.pos == pos & data.ld == ld & data.sub == sub ;
                        met1_all = [met1_all; nanmean(data.(met1)(ind & data.dof == 1))];
                        met2_all = [met2_all; nanmean(data.(met2)(ind))];
                        
                    end
                end
                plot(met1_all,met2_all-nanmean(met2_all),'.','Markersize',18,'color',c(sub,:))
                %                 ylim([0 100])
            end
        end
        
end
