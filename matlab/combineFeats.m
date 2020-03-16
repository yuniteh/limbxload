%% combine features and online results for MEC
function out = combineFeats(mets,data_all)
%%
data_new = data_all(:,[1 3 4 2 5 6 7 14 10]);
% data_new(:,5) = data_new(:,5) + 1;
data_new(:,[6 8 9]) = data_new(:,[6 8 9])*100;
all_new = mets;

%%
maxall = size(all_new,2)-4;
for sub = 1:max(all_new(:,1))
    for train = 1:max(all_new(:,2))
        for pos = 1:max(all_new(:,3))
            for ld = 1:max(all_new(:,4))
                for dof = 1:max(all_new(:,5))
                    ind = all_new(:,1) == sub & all_new(:,2) == train & all_new(:,3) == pos & all_new(:,4) == ld & all_new(:,5) == dof;
                    ind2 = data_new(:,1) == sub & data_new(:,2) == train & data_new(:,3) == pos & data_new(:,4) == ld & data_new(:,5) == dof-1;
                    if dof > 1  && sum(ind2) > 0
                        all_new(ind,maxall+1:maxall+4) = data_new(ind2,end-3:end);
                    else
                        all_new(ind,maxall+1:maxall+4) = nan(sum(ind),4);
                    end
                end
            end
        end
    end
end
out  = array2table(all_new,'VariableNames',{'sub','tr','pos','ld','dof','acc','RI','MSA_te','MSA_tr','SI_te','SI_tr','comp','time','move','stop'});
end