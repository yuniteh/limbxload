%% All data format
% 1: subject id
% 2: load
% 3: training set
% 4: arm position
% 5: target DOF
% 6: completion flag
% 7: trial time
% 8: path efficiency
% 9: samples in target
% 10: percent movement in target
% 11: distance
% 12: maximum time in target
% 13: sliding window maximum time in target
% 14: movement efficacy

function dataOut = combineData(data_all,sub_rate)
disp('Combining data...')
dataOut = data_all;
for i = 1:size(sub_rate,1) % sub
    for j = 1:size(sub_rate,2) % training set
        for k = 1:size(sub_rate{1,1},2) % load
            for h = 1:size(sub_rate{1,1},1) % pos
                if ~isempty(sub_rate{i,j})
                    ind = data_all(:,1) == i & data_all(:,3) == j & data_all(:,2) == k & data_all(:,4) == h;
                    dataOut(ind,15) = nanmean(nanmean(sub_rate{i,j}(h,k)));
                end
            end
        end
    end
end
end