function runBiorob(subData)
data = cell(3,1);
%%
dyn_met = subData.stat;
for sub = 1:max(dyn_met(:,1))
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == 1 & dyn_met(:,3) == 1 &dyn_met(:,4) == pos & dyn_met(:,5) == ld;
            if ~isnan(nanmean(dyn_met(ind,7)))
                data{1} = [data{1}; sub, pos, ld, nanmean(dyn_met(ind,7))];
            end
        end
    end
end

%%
dyn_met = subData.p2;
for sub = 1:max(dyn_met(:,1))
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == 2 & dyn_met(:,3) == 1 &dyn_met(:,4) == pos & dyn_met(:,5) == ld;
            if ~isnan(nanmean(dyn_met(ind,7)))
                data{2} = [data{2}; sub, pos, ld, nanmean(dyn_met(ind,7))];
            end
        end
    end
end

%%
dyn_met = subData.dyn;
trn = 2;

for sub = 1:max(dyn_met(:,1))
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == trn & dyn_met(:,3) == pos & dyn_met(:,4) == ld;
            if ~isnan(nanmean(dyn_met(ind,6)))
                data{3} = [data{3}; sub, pos, ld, nanmean(dyn_met(ind,6))];
            end
        end
    end
end
assignin('base','data',data)
%% all
for i = 1:3
    disp('-------------------------------------')
    disp(['Training Method: ' num2str(i)])
    all = array2table(data{i},'VariableNames',{'sub','pos','ld','acc'});
    
    all.sub = nominal(all.sub);
    all.pos = nominal(all.pos);
    all.ld = nominal(all.ld);
    
    disp('FULL MODEL')
    mod = fitlme(all,'acc~pos+ld+pos*ld+(1|sub)','dummyvarcoding','effects')
    out = anova(mod)
    
    %% reduced
    disp('-----------------')
    disp('REDUCED MODEL')
    mod = fitlme(all,'acc~pos+ld+(1|sub)','dummyvarcoding','effects')
    out = anova(mod)
end