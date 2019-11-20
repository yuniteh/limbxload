clear
close all
clc

%%
subType = 'TR';
%subType = 'AB';
subAll = loadSubs(subType,1);
win = 200;
fold = 10;
if strcmp(subType,'AB')
    numLoads = 4;
    numPos = 5;
    loads = [0 400 500 600];
else
    numLoads = 3;
    numPos = 4;
    loads = [0 400 600];
end

disp('------------------------------------------')

cm_temp = zeros(7,7);
cm_all = cell(numLoads + 2,1);
for i = 1:length(cm_all)
    cm_all{i} = cm_temp;
end
correct = cell(2,1);
tot = cell(2,1);
for i = 1:length(correct)
    correct{i} = zeros(numLoads, numPos);
    tot{i} = zeros(numLoads, numPos);
end

subRate = cell(size(subAll.subs,1),2);

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\matlab\limb position x load\completed\' subType '\' sub '\DATA\MAT'];
    load(fullfile(path,'train_data.mat'))
    group = unique(params(:,1));

    
    for i = group'
        ind = params(:,1) == i;
        if i < 3
            feat_temp = feat(ind,:);
            true_temp = params(ind,:);
            [train_ind, test_ind] = crossval(params(ind,2),fold);
            class_out = zeros(fold, size(test_ind,2));
            class_true = class_out;
            for j = 1:fold
                [w,c,muClass,C] = trainLDA(feat_temp(train_ind(j,:),:), true_temp(train_ind(j,:),2));
                [class_out(j,:),maxL] = classifyLDA(feat_temp(test_ind(j,:),:),w,c);
                class_true(j,:) = true_temp(test_ind(j,:),2);
            end
            class_true = reshape(class_true,1,[]);
            class_out = reshape(class_out,1,[]);
            cm = confusionmat(class_true,class_out);
            subRate{subInd,i} = NaN(numPos,numLoads);
        else
            for ii = 1:2
                train_ind = params(:,1) == ii;
                class_true = params(ind,2);
                [w,c,muClass,C] = trainLDA(feat(train_ind,:), params(train_ind,2));
                class_out = classifyLDA(feat(ind,:),w,c);
                for j = 1:max(params(:,3))
                    pos_ind = params(ind,3) == j;
                    count = sum(class_out(pos_ind) == class_true(pos_ind));
                    correct{ii}(i - 2,j) = correct{ii}(i-2,j) + count;
                    tot{ii}(i - 2,j) = tot{ii}(i-2,j) + sum(pos_ind);
                    subRate{subInd,ii}(j,i - 2) = count/sum(pos_ind);
                end
                correct{ii} = flipud(correct{ii});
                tot{ii} = flipud(tot{ii});
            end
        end
        cm_temp = cm_all{i} + cm;
        cm_all{i} = cm_temp;
    end
end

%%
figure
plotConfMat(cm_all{1},['NM'; 'HO';'HC';'WP';'WS';'WF';'WE'],'blue')
figure
plotConfMat(cm_all{2},['NM'; 'HO'; 'HC'; 'WP';'WS';'WF';'WE'],'red mat')

%%
figure
plotLimbLoadMat(correct{1},tot{1},1:numPos,flip(loads),'grey')
figure
plotLimbLoadMat(correct{2},tot{2},1:numPos,flip(loads),'grey')
%%
y = [600 500 400 0];
c = linspecer(2,'qualitative');
figure
[ax]=tight_subplot(numLoads,numPos,0.01);
for i = 1:length(ax)
    axes(ax(i));
    rate = zeros(length(ax),2);
    for j = 1:2
        temp = 100.*correct{j}./tot{j};
        rate(:,j) = reshape(temp',[],1);
    end
    hold all
    for j = 1:2
        b = bar(j,rate(i,j));
        set(b,'FaceColor', c(j,:));
    end
    ysides = 1:5:20;
    yind = find(ysides == i,1);
    if ~isempty(yind)
        ylabel(y(yind))
    end
    xsides = 16:20;
    xind = find(xsides == i,1);
    if ~isempty(xind)
        xlabel(xind)
    end
    %axis off
    xlim([.5 2.5])
    ylim([50 100])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
end