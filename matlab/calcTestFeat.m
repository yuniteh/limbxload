function [featAll] = calcTestFeat(subType)

subAll = loadSubs(subType,1);

disp('Calculating offline accuracies')

% initialize offline accuracy matrix
featTemp = NaN(size(subAll.subs,1),7);

for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\projects\limbxload\matlab\completed\' subType '\' sub '\DATA\MAT'];
    if exist(fullfile(path,'train_data.mat'),'file')
        load(fullfile(path,'train_data.mat'))
        
        if max(params(:,1)) > 5         % remove position 5 and load = 500g
            cut_ind = params(:,1) == 5;         % cut load = 500g
            params(cut_ind,:) = [];
            params(params(:,1) == 6,1) = 5;
            feat(cut_ind,:) = [];
        end
        if max(params(:,3)) > 4
            cut_ind = params(:,3) == 5;         % cut position 5
            params(cut_ind,:) = [];
            feat(cut_ind,:) = [];
        end
        group = unique(params(:,1));
        numClass = max(params(:,2));
        
        temp = calcFeatDist([params feat],[params feat],1);
        while size(temp) < 7
            temp(end+1) = nan;
        end
        featTemp(subInd,:) = temp;
%         assignin('base','featTemp',featTemp);
    end
end

featAll = featTemp;
