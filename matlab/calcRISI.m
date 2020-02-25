function [featAll] = calcRISI(subType)

subAll = loadSubs(subType,1);

disp('Calculating offline accuracies')

% initialize offline accuracy matrix
featTemp = NaN(size(subAll.subs,1),7);
featAll = [];

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
        
        temp = calcFeatDist([params feat],[params feat],4);
        for pos = 1:size(temp.RI,1)
            for ld = 1:size(temp.RI,2)
                for cl = 1:size(temp.RI,3)
                    featAll = [featAll; subInd pos ld cl temp.RI(pos,ld,cl) temp.SI(pos,ld,cl) temp.SI_te(pos,ld,cl) temp.MSA(pos,ld,cl)];
                end
            end
        end
        
%         assignin('base','featTemp',featTemp);
    end
end

