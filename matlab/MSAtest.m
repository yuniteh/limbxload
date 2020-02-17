clearvars out out2 p p2 xtemp xsub ytemp ysub
disp('-----')
xtemp = [];
ytemp = [];
for tr_i = 3
    if tr_i == 1
        data = tr.stat;
        acci = 7;
        ldmet = 1;
    elseif tr_i == 2
        data = tr.dyn;
        acci = 6;
    elseif tr_i == 3
        data = tr.p2;
        acci = 7;
        ldmet = 2;
    end
%  xtemp = [];
% ytemp = [];
    for sub = 1:max(data(:,1))
        clearvars xtemp ytemp
%         xtemp = [];
%         ytemp = [];
        for pos = 1:4
            for ld = 1:3
                if tr_i~=2
                ind = data(:,1) == sub & data(:,2) == ldmet & data(:,3) == 1 & data(:,4) == pos & data(:,5) == ld;
                else
                ind = data(:,1) == sub & data(:,2) == 2 & data(:,3) == pos & data(:,4) == ld;
                end
                xtemp(pos,ld) = nanmean(data(ind,acci+3));
                ytemp(pos,ld) = nanmean(data(ind,acci+1));
%                 xtemp = [xtemp; nanmean(data(ind,acci))];
%                 ytemp = [ytemp; nanmean(data(ind,acci+1)./data(ind,acci+4))];
            end
        end
        xsub(sub,:) = xtemp(:);
        ysub(sub,:) = ytemp(:);
    end
        %     x = ab.stat(ind,7);
        %     y = ab.stat(ind,8);
%         xtemp = xsub(:);
%         ytemp = ysub(:);
        if ~isempty(xtemp) & ~isempty(ytemp)
%             [out(tr_i),p] = corr(xtemp,ytemp,'type','spearman','rows','complete');
%             [out2(tr_i),p2] = corr(xtemp,ytemp,'rows','complete');
%             disp([num2str(out) ', ' num2str(p)])
%             disp([num2str(out2) ', ' num2str(p2)])
        end

end