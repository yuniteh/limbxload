cblue = linspecer(5,'blue');
cblue = flipud(cblue);
cred = linspecer(7,'red');
cred = flipud(cred);
cgreen = linspecer(4,'green');
cgreen = flipud(cgreen);
c = [cblue(2,:); cred(2,:);cgreen(2,:)];

subplot(1,2,1)
hold all
for i = 1:3
    errorbar_ez('boxez',i,rngp(i,1),rngp(i,2),.4,c(i,:))
    ylim([50 100])
end

subplot(1,2,2)
hold all
for i = 1:3
    errorbar_ez('boxez',i,rngl(i,1),rngl(i,2),.4,c(i,:))
    ylim([50 100])
end

%%
[ax]=tight_subplot(2,2,[.07 .07],[.1 .1],[.09 0.03]);
for i = 1:3
    axes(ax(1))
    hold all
    min_val = min(min(ab_ave{i}))
    max_val = max(max(ab_ave{i}));
    errorbar_ez('boxez',i,min_val,max_val,.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    ylabel('Accuracy Range (%)')
    set(gca,'linewidth',1)
    
    axes(ax(2))
    hold all
    min_val = min(min(tr_ave{i}))
    max_val = max(max(tr_ave{i}));
    errorbar_ez('boxez',i,min_val,max_val,.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    set(gca,'linewidth',1)
    
    axes(ax(3))
    hold all
    errorbar_ez('bar',i,ab_all{i},ab_se{i},.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    xlabel('Intact Limb Subjects')
    ylabel('Average Accuracy (%)')
    set(gca,'linewidth',1)
    
    axes(ax(4))
    hold all
    errorbar_ez('bar',i,tr_all{i},tr_se{i},.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    xlabel('Amputee Subjects')
    set(gca,'linewidth',1)
end

%%
[ax]=tight_subplot(2,2,[.07 .07],[.1 .1],[.09 0.03]);
for i = 1:3
    axes(ax(3))
    hold all
    rng_ave = nanmean(ab_rng{i});
    rng_se = nanstd(ab_rng{i})/sqrt(sum(~isnan(ab_rng{i})));
    errorbar_ez('bar',i,rng_ave,rng_se,.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    ylabel('Accuracy Range (%)')
    set(gca,'linewidth',1)
    xlabel('Intact Limb Subjects')

    
    axes(ax(4))
    hold all
    rng_ave = nanmean(tr_rng{i});
    rng_se = nanstd(tr_rng{i})/sqrt(sum(~isnan(tr_rng{i})));
    errorbar_ez('bar',i,rng_ave,rng_se,.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    set(gca,'linewidth',1)
    xlabel('Amputee Subjects')

    
    axes(ax(1))
    hold all
    errorbar_ez('bar',i,ab_all{i},ab_se{i},.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    ylabel('Average Accuracy (%)')
    set(gca,'linewidth',1)
    
    axes(ax(2))
    hold all
    errorbar_ez('bar',i,tr_all{i},tr_se{i},.4,c(i,:))
    ylim([0 100])
    set(gca,'xtick',[])
    set(gca,'linewidth',1)
end