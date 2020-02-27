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

function dataOut = combineData(data_all,sub_rate,type)
disp('Combining data...')
dataOut = data_all;
switch type
    case 1
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
    case 2
        dataOut = [];
        for i = 1:size(sub_rate,1) % sub
            for j = 1:size(sub_rate,2) % training set
                for k = 1:size(sub_rate,3) % load
                    for h = 1:size(sub_rate{i,j,k},1) % pos
                        for l = 1:size(sub_rate{i,j,k},2) % dof
                            if ~isempty(sub_rate{i,j,k})
                                ind = data_all(:,1) == i & data_all(:,3) == j & data_all(:,2) == k & data_all(:,4) == h & data_all(:,5) == l-1;
                                dataOff = nanmean(nanmean(sub_rate{i,j,k}(h,l)));
                                if sum(ind) > 0
                                    dataOn = data_all(ind,6:14);
                                else
                                    dataOn = nan(1,9);
                                end
                                dataOut = [dataOut;i,k,j,h,l,dataOn,dataOff];
                            end
                        end
                    end
                end
            end
        end
end
end