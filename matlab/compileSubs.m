function [data_all, data_dof, subs_all] = compileSubs(subType, varargin)

subAll = loadSubs(subType,1);
start = 1;

if strcmp(subType,'AB')
    numTrials = 30;
    numLoads = 4;
    numPos = 5;
else
    numTrials = 24;
    numLoads = 3;
    numPos = 4;
end

% if there is an input, recompile all subjects, if not, just add new
% subjects
if length(varargin) == 1
    new_data = ones(size(subAll.subs,1),1);
    data_all_new = NaN(size(subAll.subs,1)*size(subAll.loadOrder,2)*numTrials,14);
    data_dof_new = NaN(size(subAll.subs,1)*size(subAll.loadOrder,2)*numTrials,11);
    data_dof = [];
    data_all = [];
else
    load(['limbxload\matlab\completed\' subType '\alldata.mat'])
    new_data = zeros(size(subAll.subs,1),1);
    for i = 1:size(subAll.subs,1)
        temp = strfind(subs_all,subAll.subs{i});
        new_data(i) = sum(cellfun('isempty',temp)) == size(temp,1);
    end
    data_all_new = NaN(sum(new_data)*size(subAll.loadOrder,2)*numTrials,14);
end

%%
for subInd = 1:size(subAll.subs,1)
    if new_data(subInd) == 1
        sub = subAll.subs{subInd};
        disp(sub)
        order = [subAll.loadOrder(subInd,1:numLoads); subAll.loadOrder(subInd,numLoads + 1:end)];
        testOrder = subAll.testOrder(subInd,:);
        
        path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
        names = ls(path);                   % extract list of file names in converted MAT file (if it exists)
        names(1:2,:) = [];
        names(names(:,2) == 'R',:) = [];    % remove training data
        names(names(:,2) == 'r',:) = [];    % remove training data
        
        for i = 1:size(names,1)
            x = ceil(i/numLoads);
            y = i - (x-1)*numLoads;
            load(fullfile(path,names(i,:)));
            
            numDOF = max(data.txt.class);
            numTrials = numPos * numDOF;
            dataOut = calcMetrics(data,subType);
            dataOut.results.file = dataOut.file;
            dataOut.results.train = testOrder(x);
            dataOut.results.load = order(dataOut.results.train,y);
            temp{i} = dataOut.results;
            data = dataOut;
            disp(['Running file: ' data.file]);
            
            o_all = ones(numTrials,1);
            temp_all = [subInd.*o_all, data.results.load.*o_all, data.results.train.*o_all, data.post.pos + 1, data.post.dof,...
                data.post.cf, data.post.txt.time(:,3), 52./data.post.path, data.post.in, 1 - (data.post.move./data.post.in),...
                data.post.dist, data.post.max_in, data.post.best_in, data.post.move_eff];
            data_all_new(start:start+numTrials - 1,:) = temp_all;
            temp_all = [subInd.*o_all, data.results.load.*o_all, data.results.train.*o_all, data.post.pos + 1, data.post.dof,...
                data.post.moveDOF];
            data_dof_new(start:start+numTrials - 1,:) = temp_all;
            start = start+numTrials;
        end
    end
end
data_all_new(start:end,:) = [];
data_dof_new(start:end,:) = [];
data_all = [data_all; data_all_new];
data_dof = [data_dof; data_dof_new];
subs_all = subAll.subs;
end