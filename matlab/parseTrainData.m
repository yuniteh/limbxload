function parseTrainData(subType)
subAll = loadSubs(subType,1);
win = 200;

disp('------------------------------------------')
for subInd = 1:size(subAll.subs,1)
    sub = subAll.subs{subInd};
    path = ['Z:\Lab Member Folders\Yuni Teh\matlab\limb position x load\completed\' subType '\' sub '\DATA\MAT'];
    names = ls(path);                   % extract list of file names in converted MAT file (if it exists)
    names(1:2,:) = [];
    names(names(:,2) ~= 'R',:) = [];    % remove testing data
    if (subAll.testOrder(subInd,1) == 1 && subAll.statOrder(subInd) == 1) || (subAll.testOrder(subInd,1) == 2 && subAll.statOrder(subInd) == 0)
        order = [subAll.testOrder(subInd,1) subAll.trainOrder(subInd,:)+2 subAll.testOrder(subInd,2)];
    elseif subAll.statOrder(subInd) ~= 2
        order = [subAll.testOrder(subInd,:) subAll.trainOrder(subInd,:)+2];
    else
        order = [subAll.trainOrder(subInd,:)+2 subAll.testOrder(subInd,:)];
    end
    
    feat = [];
    params = [];
    for i = 1:size(names,1)
        if order(i) < 7                 % skip broken files
            load(fullfile(path,names(i,:)));
            ind = data.pvd.COLLECTING == 1;
            dof = data.pvd.TRAIN_FLAG + 1;
            arm = data.pvd.TARGET_ARM + 1;
            numPos = max(arm);
            
            % augment train flag at the end of collection period (python
            % bug)
            end_ind = find(diff(dof) < 0) + 1;
            dof(end_ind) = dof(end_ind - 1);
            ind(end_ind) = 1;
            
            if strcmp(subType,'AB')
                % calculate channel MAV
                temp = zeros(size(dof));
                for ii = 1:length(data.pvd.t)
                    t_ind = find(data.daq.t == data.pvd.t(ii));
                    if t_ind+win-1 <= length(data.daq.DAQ_DATA) && ii + 7 <= size(temp,1)
                        temp(ii+7,:) = mean(FeatExtractmex(16,data.daq.daqUINT16(t_ind:t_ind+win-1,:)'));
                    end
                end
                temp = (temp./(2^16 - 1)).*10;
                
                % find good training data
                new_ind = temp > 1.1.*data.pvd.THRESH_VAL & data.pvd.ARM_FLAG == 1 & dof > 1 & ind;
                rest_ind = data.pvd.ARM_FLAG == 1 & dof == 1 & ind;
                off.ind = new_ind | rest_ind;
                off.dof = dof(off.ind);
                off.arm = arm(off.ind);
            else
                off.ind = ind;
                off.dof = dof(off.ind);
                off.arm = arm(off.ind);
            end
            % check counts for each condition
            count = zeros(7,numPos);
            for ii = 1:7
                for j = 1:numPos
                    count(ii,j) = sum(off.arm == j & off.dof == ii);
                    if mod(count(ii,j), 100) ~= 0
                        % add if missing
                        if (count(ii,j) < 100 && count(ii,j) > 0) || (count(ii,j) < 500 && count(ii,j) > 400)
                            skip_ind = off.ind & dof == ii & arm == j;
                            add_ind = temp > 1.1.*data.pvd.THRESH_VAL & data.pvd.ARM_FLAG == 1 & dof == ii & arm == j;
                            add_n = ceil(count(ii,j)/100)*100 - count(ii,j);
                            disp(['adding ' num2str(add_n)])
                            add_ind = xor(skip_ind,add_ind);
                            add_ind = find(add_ind);
                            if add_n > length(add_ind)
                                add_ind = zeros(add_n,1);
                                end_ind = find(arm(1:end-1) == j & diff(dof) == -ii);
                                for k = 1:add_n
                                    add_ind(k) = end_ind + k;
                                    dof(end_ind + k) = dof(end_ind);
                                end
                            end
                            add_i = randperm(length(add_ind),add_n);
                            off.ind(add_ind(add_i)) = 1;
                            % remove if too many
                        else
                            rem_n = count(ii,j) - floor(count(ii,j)/100)*100;
                            disp(['removing ' num2str(rem_n)])
                            skip_ind = find(off.ind & data.pvd.TRAIN_FLAG + 1 == ii & data.pvd.TARGET_ARM + 1 == j);
                            rem_i = randperm(length(skip_ind),rem_n);
                            off.ind(skip_ind(rem_i)) = 0;
                        end
                        off.dof = dof(off.ind);
                        off.arm = arm(off.ind);
                        count(ii,j) = sum(off.arm == j & off.dof == ii);
                    end
                end
            end
            disp([sub ' ' names(i,:)])
            
            off.ind = find(off.ind);
            for ii = 1:length(off.ind)
                off.ind(ii) = find(data.daq.t == data.pvd.t(off.ind(ii)));
            end
            
            off.feat = zeros(length(off.ind),60);
            for ii = 1:length(off.ind)
                off.feat(ii,:) = FeatExtractmex(47,data.daq.daqUINT16(off.ind(ii):off.ind(ii)+win-1,:)');
            end
            
            off.group = order(i).*ones(size(off.ind));
            data.off = off;
            
            matfile = fullfile(path,names(i,:));
            save(matfile, 'data');
            
            feat = [feat; off.feat];
            params = [params; off.group off.dof off.arm];
        end
        save([path '\train_data.mat'],'feat','params');
    end
end
end