function plotTNSRE(data)
%% set colormaps
cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);
metList = {'comp','move','stop','time'};
nLd = max(data.ld);
nPos = max(data.pos);
nSub = max(data.sub);

%% Plot static data with points
%marks = [{'o'},{'+'},{'*'},{'d'},{'s'},{'^'},{'p'}];
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


end
