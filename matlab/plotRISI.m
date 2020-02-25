figure
hold all

%%
subRI = nan(max(out(:,1)),1);
RI = nan(4,3);
SE = RI;
for pos = 1:4
    for ld = 1:3
        for sub = 1:max(out(:,1))
            ind = out(:,2) == pos & out(:,3) == ld & out(:,1) == sub;
            subRI(sub) = nanmean(out(ind,5));
        end
        RI(pos,ld) = nanmean(subRI);
        SE(pos,ld) = nanstd(subRI)./sum(~isnan(subRI));
    end
    
end

%%
figure
hold all
c = flipud(linspecer(5,'blue'));
c = linspecer(3);
for ld = 1:3
    stdshade(RI(:,ld)', SE(:,ld)',.3,c(ld,:))
end

xlabel('Position')
set(gca,'XTick',1:4);
set(gca,'XTickLabels',{'P1', 'P2','P3','P4'})
ylabel('RI')

%%
figure
hold all
c = flipud(linspecer(6,'blue mat'));
c = linspecer(4);
for pos = 1:4
    stdshade(RI(pos,:), SE(pos,:),.3,c(pos,:))
end

xlabel('Load')
set(gca,'XTick',1:3);
set(gca,'XTickLabels',{'0g', '400g','600g'})
ylabel('MSA')