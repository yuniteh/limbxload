off = [];
on = [];
params = [];

for i = 1:max(data_all(:,1))
    for j = 1:max(data_all(:,4))
        ind = data_all(:,1) == i & data_all(:,3) == 1 & data_all(:,2) == 1 & data_all(:,4) == j;
        off = [off;nanmean(data_all(ind,15),1)];
        on = [on;nanmean(data_all(ind,[6 7 10 14]),1)];
        params = [params;nanmean(data_all(ind,[1 4]),1)];
    end
end

%%
ind1 = find(isnan(off));
off(ind1) = [];
on(ind1,:) = [];
params(ind1,:)= [];

%%
for i = 1:4
    [r,p]=corrcoef(off,on(:,i))
end