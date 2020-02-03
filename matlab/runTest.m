[cm_all, acc_all, sub_rate, FS] = calcOffline(subType);


%%
RI = zeros(4,7);
for sub = 1:14
    for tr = 1
        for load = 1
            temp = FS{sub,tr,load};
            RI = RI + temp.RI./14;
        end
    end
end
