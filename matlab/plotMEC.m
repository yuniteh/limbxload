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
        [ax]=tight_subplot(2,nLd,[.03 .02],[.1 .1],[.09 0.03]);
        
        y_ind = 1;
        for met_i = 7
            met = metNames{met_i};
            maxMet = max(data.(met));
            for train = 1:2
                fig_ind = 1;
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
                            mat(pos,dof) = nanmean(temp);
                            
                        end
                    end
                    plotMat(mat,'xticks',{'NM','HO','HC','WP','WS','WF','WE'},'yticks',...
                        {'P1','P2','P3','P4'},'colors','blue','range',[0 maxMet],'xlabel',...
                        ' ','ylabel',' ')
                    fig_ind = fig_ind + 1;
                    
                end
                y_ind = y_ind + 1;
            end
        end
end
