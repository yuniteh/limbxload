n = [];
for pos = 1:5
    for met = 1:6
        n = [n;kstest(data_all(data_all(:,7) == pos & data_all(:,10) == 2,met))];
    end
end

%%
n = [];
for load = 1:4
    for met = 1:6
        n = [n;kstest(data_all(data_all(:,9) == load & data_all(:,10) == 2,met))];
    end
end