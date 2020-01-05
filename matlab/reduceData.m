function data_red = reduceData(data_all)
%% averages trials from all DOFs for each treatment

nPos = max(data_all(:,4));
nTests = max(data_all(:,3));
nLoads = max(data_all(:,2));
nSubs = max(data_all(:,1));
data_red = NaN(size(data_all));
i = 1;
for sub = 1:nSubs
    for train = 1:nTests
        for load = 1:nLoads
            for pos = 1:nPos
                ind = data_all(:,3) == train & data_all(:,4) == pos & data_all(:,1) == sub & data_all(:,2) == load;
                if sum(ind)>0
                    ave = nanmean(data_all(ind,6:end),1);
                    data_red(i,:) = [sub, load, train, pos, 0, ave];
                    i = i + 1;
                end
            end
        end
    end
end
data_red(i:end,:) = [];
end