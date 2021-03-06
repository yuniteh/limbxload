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
switch type
    %% append offline accuracy to data all
    case 'ave'
        dataOut = data_all;
        for sub = 1:size(sub_rate,1)                        % sub
            for tr = 1:size(sub_rate,2)                     % training set
                for ld = 1:size(sub_rate{1,1},2)            % load
                    for pos = 1:size(sub_rate{1,1},1)       % pos
                        if ~isempty(sub_rate{sub,tr})
                            ind = data_all(:,1) == sub & data_all(:,3) == tr & data_all(:,2) == ld & data_all(:,4) == pos;
                            dataOut(ind,15) = nanmean(nanmean(sub_rate{sub,tr}(pos,ld)));
                        end
                    end
                end
            end
        end
        
    %% 
    case 'dof'
        dataOut = [];
        for sub = 1:size(sub_rate,1)                                    % sub
            for tr = 1:size(sub_rate,2)                                 % training set
                for ld = 1:size(sub_rate,3)                             % load
                    for pos = 1:size(sub_rate{sub,tr,ld},1)             % pos
                        for dof = 1:size(sub_rate{sub,tr,ld},2)         % dof
                            if ~isempty(sub_rate{sub,tr,ld})
                                ind = data_all(:,1) == sub & data_all(:,3) == tr & data_all(:,2) == ld & data_all(:,4) == pos & data_all(:,5) == dof-1;
                                dataOff = nanmean(nanmean(sub_rate{sub,tr,ld}(pos,dof)));
                                if sum(ind) > 0
                                    dataOn = data_all(ind,6:14);
                                else
                                    dataOn = nan(1,9);
                                end
                                dataOut = [dataOut;sub,ld,tr,pos,dof,dataOn,dataOff];
                            end
                        end
                    end
                end
            end
        end
end
end