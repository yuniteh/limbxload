function plotSub(sub)

% get test info from excel file
subAll = loadSubs();
subInd = find(strcmp(subAll.subs,sub));
order = [subAll.loadOrder(subInd,1:4); subAll.loadOrder(subInd,5:end)];         % 1:4 corresponds to no load:400:500:600
testOrder = subAll.testOrder(subInd,:);     % order of testing

numTests = size(order,1);           % number of different training sets
numLoads = size(order,2);           % number of loads (including no load)
l_name = {'static', 'dynamic'};

path = ['Z:\Lab Member Folders\Yuni Teh\matlab\limb position x load\completed\' sub '\DATA\MAT'];
names = ls(path); % extract list of file names in converted MAT file (if it exists)
names(1:2,:) = [];
names(names(:,2) == 'R',:) = []; % remove training data

all_data = [];

for i = 1:size(names,1)
    x = ceil(i/numLoads);
    y = i - (x-1)*numLoads;
    load(fullfile(path,names(i,:)));
    dataOut = calcMetrics(data);
    dataOut.results.file = dataOut.file;
    dataOut.results.load = order(x,y);
    dataOut.results.train = testOrder(x);
    temp{i} = dataOut.results;
    data = dataOut;
    disp(['Running file: ' data.file]);
    %save(fullfile(path,names(i,:)), 'data');
    
    ind = data.post.cf == 1;
    o_array = ones(sum(ind),1);
    temp_all = [data.post.txt.time(ind,3), 52./data.post.path(ind), data.post.move(ind)./data.post.in(ind),...
        data.post.pos(ind), data.post.dof(ind), data.results.load.*o_array, data.results.train.*o_array];
    all_data = [all_data; temp_all];
end

f_names = fieldnames(temp{1});
for i = 1:length(f_names)
    for j = 1:length(temp)
        results.(f_names{i})(j,:) = temp{j}.(f_names{i});
    end
end

%% Individual training set plots
rate = zeros(numLoads, 5);
time = rate;
eff = rate;
move = rate;
for i = 1:numTests
    ind = results.train == i;                    % find indices that correspond to next training set
    rate(results.load(ind),:) = results.c_rate(ind,:);                  % grab results from current training set and order them based on testing load in output variable
    time(results.load(ind),:) = results.c_time_mean(ind,:);
    eff(results.load(ind),:) = results.eff_mean(ind,:);
    move(results.load(ind),:) = results.move(ind,:)./results.in(ind,:);
    figure
    subplot(221)
    plot((1:numLoads)', rate,'-o','LineWidth',1.5)
    ylim([0 1])
    ylabel('Completion Rate')
    xlabel('Load (g)')
    set(gca,'XTick',[1 2 3 4])
    set(gca,'XTickLabels',[0 400 500 600])
    legend('1','2','3','4','5')
    
    subplot(222)
    plot((1:numLoads)', time,'-o','LineWidth',1.5)
    ylim([0 ceil(max(max(time)))])
    ylabel('Completion Time (s)')
    xlabel('Load (g)')
    set(gca,'XTick',[1 2 3 4])
    set(gca,'XTickLabels',[0 400 500 600])
    
    subplot(223)
    plot((1:numLoads)', eff,'-o','LineWidth',1.5)
    ylim([0 1])
    ylabel('Path Efficiency')
    xlabel('Load (g)')
    set(gca,'XTick',[1 2 3 4])
    set(gca,'XTickLabels',[0 400 500 600])
    
    subplot(224)
    plot((1:numLoads)', move,'-o','LineWidth',1.5)
    ylim([0 1])
    ylabel('Failed Rest')
    xlabel('Load (g)')
    set(gca,'XTick',[1 2 3 4])
    set(gca,'XTickLabels',[0 400 500 600])
end

%% Plot metrics while blocking testing load
mean_rate = zeros(numTests,5);
mean_time = mean_rate;
mean_eff = mean_rate;
mean_move = mean_rate;
for i = 1:numTests
    ind = results.train == i;
    sum_rate = sum(results.c_rate(ind,:));
    mean_rate(i,:) = sum_rate./4;               % average the completion rates across testing loads
    mean_time(i,:) = sum(results.c_rate(ind,:).*results.c_time_mean(ind,:))./sum_rate;
    mean_eff(i,:) = sum(results.c_rate(ind,:).*results.eff_mean(ind,:))./sum_rate;
    mean_move(i,:) = mean(results.move(ind,:)./results.in(ind,:));
end

figure
subplot(221)
hold all
for i = 1:numTests
    plot(mean_rate(i,:),'-o','LineWidth',1.5)
end
ylim([0 1])
ylabel('Completion Rate')
xlabel('Position')
legend(l_name)
set(gca,'XTick',[1 2 3 4 5])

subplot(222)
hold all
for i = 1:numTests
    plot(mean_time(i,:),'-o','LineWidth',1.5)
end
ylim([0 max(max(mean_time))+.2])
ylabel('Completion Time (s)')
xlabel('Position')
set(gca,'XTick',[1 2 3 4 5])

subplot(223)
hold all
for i = 1:numTests
    plot(mean_eff(i,:),'-o','LineWidth',1.5)
end
ylim([0 1])
ylabel('Path Efficiency')
xlabel('Position')
set(gca,'XTick',[1 2 3 4 5])

subplot(224)
hold all
for i = 1:numTests
    plot(mean_move(i,:),'-o','LineWidth',1.5)
end
ylim([0 1])
ylabel('Failed Rest')
xlabel('Position')
set(gca,'XTick',[1 2 3 4 5])


%%
plot_rate = zeros(numTests,size(order,2));
plot_time = plot_rate;
plot_eff = plot_rate;
plot_move = plot_rate;
for i = 1:numTests
    ind = results.train == i;                   % find indices that correspond to next training set
    ind_out = results.load(ind);                % find indices that correspond to testing loads
    c_rate = results.c_rate(ind,:)';
    c_time = results.c_time_mean(ind,:)';
    eff = results.eff_mean(ind,:)';
    move = results.move(ind,:)';
    in = results.in(ind,:)';
    plot_rate(i,ind_out) = mean(c_rate);
    plot_time(i,ind_out) = sum(c_rate.*c_time)./sum(c_rate);
    plot_eff(i,ind_out) = sum(c_rate.*eff)./sum(c_rate);
    plot_move(i,ind_out) = mean(move./in);
end


figure
subplot(221)
hold all
for i = 1:numTests
    plot(plot_rate(i,:),'-o','LineWidth',1.5)
end
ylim([0 1])
ylabel('Completion Rate')
xlabel('Load (g)')
legend(l_name)
set(gca,'XTick',[1 2 3 4])
set(gca,'XTickLabels',[0 400 500 600])

subplot(222)
hold all
for i = 1:numTests
    plot(plot_time(i,:),'-o','LineWidth',1.5)
end
ylim([0 10])
ylabel('Completion Time (s)')
xlabel('Load (g)')
set(gca,'XTick',[1 2 3 4])
set(gca,'XTickLabels',[0 400 500 600])

subplot(223)
hold all
for i = 1:numTests
    plot(plot_eff(i,:),'-o','LineWidth',1.5)
end
ylim([0 1])
ylabel('Path Efficiency')
xlabel('Load (g)')
set(gca,'XTick',[1 2 3 4])
set(gca,'XTickLabels',[0 400 500 600])

subplot(224)
hold all
for i = 1:numTests
    plot(plot_move(i,:),'-o','LineWidth',1.5)
end
ylim([0 1])
ylabel('Failed Rest')
xlabel('Load (g)')
set(gca,'XTick',[1 2 3 4])
set(gca,'XTickLabels',[0 400 500 600])
end