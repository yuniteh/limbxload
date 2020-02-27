function plotMEC(data,type)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);

%% initialize variables
nSub = max(data.sub);
nTrain = max(data.tr);
nPos = max(data.pos);
nLd = max(data.ld);
nDOF = max(data.dof);
metNames = {'acc','RI','MSA_te','MSA_tr','SI_te','SI_tr','comp','time','move','stop'};

switch type
    case 'matrix'
        %% matrix of features
        figure
        [ax]=tight_subplot(3,nLd,[.03 .02],[.1 .1],[.09 0.03]);
        
        y_ind = 1;
        for met_i = [2 1 9]
            met = metNames{met_i};
            maxMet = max(data.(met));
            fig_ind = 1;
            for train = 1
                for ld = 1:nLd
                    axes(ax(fig_ind + (y_ind-1)*nLd));
                    mat = zeros(nPos,nDOF);
                    for pos = 1:nPos
                        for dof = 1:nDOF
                            temp = nan(nSub,1);
                            for sub = 1:nSub
                                ind = data.tr == train & data.pos == pos & data.sub == sub & data.ld == ld & data.dof == dof;
                                temp(sub) = nanmean(data.(met)(ind));
                            end
                            if met_i ~= 2
                                temp = 100-temp;
                            end
                            mat(pos,dof) = nanmean(temp);
                            
                        end
                    end
                    plotMat(mat,'xticks',{'NM','HO','HC','WP','WS','WF','WE'},'yticks',...
                        {'P1','P2','P3','P4'},'colors','blue','range',[0 maxMet],'xlabel',...
                        ' ','ylabel',' ')
                    fig_ind = fig_ind + 1;
                    
                end
                
            end
            y_ind = y_ind + 1;
        end
    case 'corr'
        %% correlation of features
        %         figure
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
