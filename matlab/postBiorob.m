data = [];
for sub = 1:size(acc,1)
    for pos = 1:4
        for ld = 1:3
            if ~isnan(acc(sub,pos+4*(ld-1)))
                data = [data;sub, pos, ld, acc(sub,pos + 4*(ld-1))];
            end
        end
    end
end
olddata= data;
%%
dyn_met = tr.dyn;
data = [];
for sub = 1:max(dyn_met(:,1))
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == 2 & dyn_met(:,3) == pos & dyn_met(:,4) == ld;
            if ~isnan(nanmean(dyn_met(ind,6)))
                data = [data; sub, pos, ld, nanmean(dyn_met(ind,6))];
            end
        end
    end
end
olddata=data;
%%
disp('-----')
for i = 1
% data = olddata(olddata(:,2) == i,:);
all = array2table(data,'VariableNames',{'sub','pos','ld','acc'});

all.sub = nominal(all.sub);
all.pos = nominal(all.pos);
all.ld = nominal(all.ld);


mod = fitlme(all,'acc~pos+ld+pos*ld+(1|sub)','dummyvarcoding','effects')
% mod = fitlme(all,'acc~pos+(1|sub)','dummyvarcoding','effects')

% out = anova(mod,'components')
% mod = fitlm(all,'acc~pos+ld+pos*ld+sub','dummyvarcoding','effects');
out = anova(mod)
end
%%
[p,tbl,stats,terms] = anovan(all.acc,{all.pos all.ld all.sub},...
    'varnames',{'Pos','Load','Sub'},'random',3,'model',[1 0 0; 0 1 0; 1 1 0; 0 0 1]);

%%
mod = fitlme(all,'Eff~Pos+Load+Pos*Load+(1|Sub)','dummyvarcoding','effects')
out = anova(mod)

%% plotting
figure
hold all
for subtype = 1:2
    subplot(1,2,subtype)
    hold all
    if subtype == 1
        stat = ab.stat;
        p2 = ab.p2;
        dyn = ab.dyn;
    else
        stat = tr.stat;
        p2 = tr.p2;
        dyn = tr.dyn;
    end
    nSub = max(stat(:,1));
    ave = nan(nSub,3);
    
    min1 = nan;
    min2 = nan;
    min3 = nan;
    for pos = 1:4
        for ld = 1:3
            clearvars temp1 temp2 temp3
            for sub = 1:nSub
                stat_i = stat(:,1) == sub & stat(:,2) == 1 & stat(:,3) == 1 & stat(:,4) == pos & stat(:,5) == ld;
                p2_i = p2(:,1) == sub & p2(:,2) == 2 & p2(:,3) == 1 & p2(:,4) == pos & stat(:,5) == ld;
                dyn_i = dyn(:,1) == sub & dyn(:,2) == 2 & dyn (:,3) == pos & dyn(:,4) == ld;
                temp1(sub) = nanmean(stat(stat_i,7));
                temp2(sub) = nanmean(p2(p2_i,7));
                temp3(sub) = nanmean(dyn(dyn_i,6));
            end
            if isnan(min1) || min1 > nanmean(temp1)
                min1 = nanmean(temp1);
                ave(:,1) = temp1;
            end
            if isnan(min2) || min2 > nanmean(temp2)
                min2 = nanmean(temp2);
                ave(:,2) = temp2;
            end
            if isnan(min3) || min3 > nanmean(temp3)
                min3 = nanmean(temp3);
                ave(:,3) = temp3;
            end
        end
    end
        
%     for sub = 1:nSub
%         stat_i = stat(:,1) == sub & stat(:,2) == 1 & stat(:,3) == 1;
%         p2_i = p2(:,1) == sub & p2(:,2) == 2 & p2(:,3) == 1;
%         dyn_i = dyn(:,1) == sub & dyn(:,2) == 2;
%         ave(sub,1) = nanmean(stat(stat_i,7));
%         ave(sub,2) = nanmean(p2(p2_i,7));
%         ave(sub,3) = nanmean(dyn(dyn_i,6));
%     end
    
    c = linspecer(3);
    for i = 1:3
%         errorbar_ez('bar',i,nanmean(ave(:,i)),nanstd(ave(:,i))/sqrt(nSub),.4,c(i,:))
        errorbar_ez('boxwhisk',i,ave(:,i),nanstd(ave(:,i)),.4,c(i,:))
    end
    ylim([0 100])
end

%%
data = [];
for sub = 1:size(ave,1)
    for test = 1:3
        data = [data; sub test ave(sub,test)];
    end
end

all = array2table(data,'VariableNames',{'sub','test','acc'});

all.sub = nominal(all.sub);
all.test = nominal(all.test);

mod = fitlm(all,'acc~test','dummyvarcoding','effects')
out = anova(mod)

[p,tbl,stats] = anovan(all.acc,{all.test, all.sub},...
    'varnames',{'test','Sub'},'model',[1 0],'random',2);

%%
figure
[ax]=tight_subplot(1,3,[.03 .03],[.3 .1],[.09 0.03]);
for subtype = 2
    
    if subtype == 1
        stat = ab.stat;
        p2 = ab.p2_new;
        dyn = ab.dyn;
    else
        stat = tr.stat;
        p2 = tr.p2;
        dyn = tr.dyn;
    end
    nSub = max(stat(:,1));
    met = [8 12 10];
    met = 8;
    for met_i = 1%:3
        ave1 = nan(nSub,4,3);
        ave2 = ave1;
        ave3 = ave1;
        si1 = ave1;
        si2 = ave1;
        si3 = ave1;
        for sub = 1:nSub
            for pos = 1:4
                for ld = 1:3
                    stat_i = stat(:,1) == sub & stat(:,2) == 1 & stat(:,3) == 1 & stat(:,4) == pos & stat(:,5) == ld;
                    p2_i = p2(:,1) == sub & p2(:,2) == 2 & p2(:,3) == 1 & p2(:,4) == pos & p2(:,5) == ld;
                    dyn_i = dyn(:,1) == sub & dyn(:,2) == 2 & dyn(:,3) == pos & dyn(:,4) == ld;
                    ave1(sub,pos,ld) = nanmean(stat(stat_i,met(met_i))./stat(stat_i,met(met_i)+3));
                    ave2(sub,pos,ld) = nanmean(p2(p2_i,met(met_i))./p2(p2_i,met(met_i)+3));
                    ave3(sub,pos,ld) = nanmean(dyn(dyn_i,met(met_i) - 1)./dyn(dyn_i,met(met_i) - 1+3));
                    
                    si1(sub,pos,ld) = nanmean(stat(stat_i,met(met_i)+3));
                    si2(sub,pos,ld) = nanmean(p2(p2_i,met(met_i)+3));
                    si3(sub,pos,ld) = nanmean(dyn(dyn_i,met(met_i) - 1+3));
                end
            end
            
        end
        ri1 = ave1;
        ri2 = ave2;
        ri3 = ave3;
%         ave1 = ri1./si1;
%         ave2 = ri2./si2;
%         ave3 = ri3./si3;
% ave1 = si1;
% ave2 = si2;
% ave3 = si3;

        
        mat(1,:,:) = reshape(nanmean(ave1,1),4,3);
        mat(2,:,:) = reshape(nanmean(ave2,1),4,3);
        mat(3,:,:) = reshape(nanmean(ave3,1),4,3);
        for pos = 1:4
            for ld = 1:3
                count = sum(~isnan(ave1(:,pos,ld)));
                se(1,pos,ld) = nanstd(ave1(:,pos,ld))/sqrt(count);
                se(2,pos,ld) = nanstd(ave2(:,pos,ld))/sqrt(count);
                se(3,pos,ld) = nanstd(ave3(:,pos,ld))/sqrt(count);
            end
        end
        clist = {'blue','red','green'};
        titl = {'0g','400g','600g'};
        for i = 1:3
            axes(ax(i + (met_i-1)*3));% = subplot(1,3,i + (met_i - 1)*3);
            hold all
            %colormap(ax,linspecer('grey'))
            %plotMat(reshape(mat(i,:,:),4,3),'yticks',{'P1','P2','P3','P4'},'xticks',...
            %                 {'0g','400g','600g'},'ylabel','','xlabel','',...
            %                 'range',[0 2])
            c = linspecer(3);
            for ld = 1:3
                sh = [-.1 0 -.2];
                x = 1:4;
                stdshade(reshape(mat(ld,:,i),1,4), reshape(se(ld,:,i),1,4),.3,c(ld,:))
                %plot(x,reshape(mat(ld,:,i),4,1),'.-','markersize',20,'linewidth',2,'color',c(ld,:))
            end
            title(titl{i})
           
            set(gca,'XTickLabel',{'P1','P2','P3','P4'})
            if i == 1
                ylabel('Separability Index')
            else
                %set(gca,'YTick',[])
            end
            xlabel('Limb Position')
            xlim([.8 4.2])
            ylim([0 1.3])
        end
        c = linspecer(3);
        %         plot(1:3,[nanmean(ave1(:,1,1),1); nanmean(ave2(:,1,1),1);nanmean(ave3(:,1,1),1)]
        %         subplot(
        %         n = sum(~isnan(ave1(:,1,1)));
        %         errorbar_ez('bar',1,nanmean(ave1(:,1,1),1),nanstd(ave1(:,1,1))/sqrt(n),.4,c(1,:))
        %         n = sum(~isnan(ave2(:,1,1)));
        %         errorbar_ez('bar',1,nanmean(ave2(:,1,1),1),nanstd(ave2(:,1,1))/sqrt(n),.4,c(2,:))
        %         n = sum(~isnan(ave3(:,1,1)));
        %         errorbar_ez('bar',1,nanmean(ave3(:,1,1),1),nanstd(ave3(:,1,1))/sqrt(n),.4,c(3,:))
        
    end
end

%%
clearvars out out2 p p2 xtemp xsub ytemp ysub
disp('-----')
xtemp = [];
ytemp = [];
wtemp = [];
ztemp = [];
for tr_i = 1:3
    if tr_i == 1
        data = ab.stat;
        acci = 7;
        ldmet = 1;
    elseif tr_i == 2
        data = ab.dyn;
        acci = 6;
    elseif tr_i == 3
        data = ab.p2_new;
        acci = 7;
        ldmet = 2;
    end
%  xtemp = [];
% ytemp = [];
    for sub = 1:max(data(:,1))
%         clearvars xtemp ytemp
%         xtemp = [];
%         ytemp = [];
        for pos = 1:4
            for ld = 1:3
                if tr_i~=2
                ind = data(:,1) == sub & data(:,2) == ldmet & data(:,3) == 1 & data(:,4) == pos & data(:,5) == ld;
                else
                ind = data(:,1) == sub & data(:,2) == 2 & data(:,3) == pos & data(:,4) == ld;
                end
%                 xtemp(pos,ld) = nanmean(data(ind,acci+3));
%                 ytemp(pos,ld) = nanmean(data(ind,acci+1));
                xtemp = [xtemp; nanmean(data(ind,acci))];
                ytemp = [ytemp; nanmean(data(ind,acci+1)./data(ind,acci+4))];
                ztemp = [ztemp; nanmean(data(ind,acci+1))];
                wtemp = [wtemp; nanmean(data(ind,acci+4))];
            end
        end
%         xsub(sub,:) = xtemp(:);
%         ysub(sub,:) = ytemp(:);
    end
        %     x = ab.stat(ind,7);
        %     y = ab.stat(ind,8);
%         xtemp = xsub(:);
%         ytemp = ysub(:);
end
        if ~isempty(xtemp) & ~isempty(ytemp)
            [out,p] = corr(xtemp,ytemp,'type','spearman','rows','complete');
            [out2,p2] = corr(xtemp,ztemp,'type','spearman','rows','complete');
            [out3,p3] = corr(xtemp,wtemp,'type','spearman','rows','complete');
            
            disp([num2str(out) ', ' num2str(p)]);
            disp([num2str(out2) ', ' num2str(p2)]);
disp([num2str(out3) ', ' num2str(p3)]);            
        end

figure
plot(ytemp,xtemp,'o','markerfacecolor',[.5 .5 .5],'markeredgecolor',[.5 .5 .5],'markersize',5)
ylim([0 100])
ylabel('Offline Accuracy (%)')
xlabel('SI/RI')
figure
plot(wtemp,xtemp,'o','markerfacecolor',[.5 .5 .5],'markeredgecolor',[.5 .5 .5],'markersize',5)
ylim([0 100])
ylabel('Offline Accuracy (%)')
xlabel('Separability Index')
figure
plot(ztemp,xtemp,'o','markerfacecolor',[.5 .5 .5],'markeredgecolor',[.5 .5 .5],'markersize',5)
ylim([0 100])
ylabel('Offline Accuracy (%)')
xlabel('Repeatability Index')

%% MSA
c = linspecer(3);
c = [0.5 0.5 0.5;c];
msap = msa_tr;
figure
hold all
for i= 1:4
errorbar_ez('bar',i,nanmean(msap(:,i)),nanstd(msap(:,i))/sqrt(sum(~isnan(msap(:,i)))),.4,c(i,:))
end
set(gca,'xtick',[])
set(gca,'linewidth',1)
xlim([0 5])
ylabel('MSA')