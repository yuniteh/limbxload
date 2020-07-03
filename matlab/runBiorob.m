function [ave, ave_all,se,sub_rng]= runBiorob(subData,type)
data = cell(3,1);
ave = cell(1,3);
ave_all = ave;
se = ave;
sub_temp = ave;

%%
dyn_met = subData.stat;
sub_max = max(dyn_met(:,1));
for sub = 1:sub_max
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == 1 & dyn_met(:,3) == 1 &dyn_met(:,4) == pos & dyn_met(:,5) == ld;
            if ~isnan(nanmean(dyn_met(ind,7)))
                data{1} = [data{1}; sub, pos, ld, nanmean(dyn_met(ind,7)), nanmean(dyn_met(ind,end))];
            end
        end
    end
end

%%
dyn_met = subData.p2;
for sub = 1:sub_max
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == 2 & dyn_met(:,3) == 1 &dyn_met(:,4) == pos & dyn_met(:,5) == ld;
            if ~isnan(nanmean(dyn_met(ind,7)))
                data{2} = [data{2}; sub, pos, ld, nanmean(dyn_met(ind,7)), nanmean(dyn_met(ind,end))];
            end
        end
    end
end

%%
dyn_met = subData.dyn;
trn = 2;

for sub = 1:sub_max
    for pos = 1:4
        for ld = 1:3
            ind = dyn_met(:,1) == sub & dyn_met(:,2) == trn & dyn_met(:,3) == pos & dyn_met(:,4) == ld;
            if ~isnan(nanmean(dyn_met(ind,6)))
                data{3} = [data{3}; sub, pos, ld, nanmean(dyn_met(ind,6)), nanmean(dyn_met(ind,end))];
            end
        end
    end
end

switch type
    case 'plots'
        %% range plots
        for tr = 1:3
            for pos = 1:4
                for ld = 1:3
                    ind = data{tr}(:,2) == pos & data{tr}(:,3) == ld;
                    ave{tr}(pos,ld) = nanmean(data{tr}(ind,4));
                end
            end
            for sub = 1:max(data{tr}(:,1))
                sub_temp = data{tr}(data{tr}(:,1) == sub,4);
                sub_ave{tr}(sub) = nanmean(sub_temp);
                if ~isempty(sub_temp)
                    sub_rng{tr}(sub) = max(sub_temp) - min(sub_temp);
                else
                    sub_rng{tr}(sub) = nan;
                end
            end
            ave_all{tr} = nanmean(sub_ave{tr});
            se{tr} = nanstd(sub_ave{tr})./sqrt(max(data{tr}(:,1)));
        end
        
    case 'stats'
        %% all stats
        for i = 1:3
            disp('--------------------------------------------------------------')
            disp(['Training Method: ' num2str(i)])
            all = array2table(data{i},'VariableNames',{'sub','pos','ld','acc','type'});
            
            all.sub = nominal(all.sub);
            all.pos = categorical(all.pos,[1,2,3,4]);
            all.ld = categorical(all.ld,[1,2,3]);
            all.type = nominal(all.type);
            
            disp('FULL MODEL')
            mod = fitlme(all,'acc~pos+ld+type+pos*ld+(1|sub)','dummyvarcoding','effects')
            out = anova(mod)
            
            %% reduced
            red = array2table(data{i},'VariableNames',{'sub','pos','ld','acc','type'});
            red.sub = nominal(red.sub);
            red.pos = categorical(red.pos,[1,2,3,4]);
            red.ld = categorical(red.ld,[1,2,3]);
            red.type = nominal(red.type);
            
            disp('-----------------')
            disp(['Training Method: ' num2str(i)])
            disp('REDUCED MODEL')
            mod = fitlme(red,'acc~pos+ld+type+(1|sub)','dummyvarcoding','effects')
            out = anova(mod)
            
            %% separated
%             for ld = 1:3
%                 red = array2table(data{i}(data{i}(:,3) == ld,:),'VariableNames',{'sub','pos','ld','acc'});
%                 red.sub = nominal(red.sub);
%                 red.pos = nominal(red.pos);
%                 
%                 disp('-----------------')
%                 disp(['Training Method: ' num2str(i) ', Load: ' num2str(ld)])
%                 disp('REDUCED MODEL')
%                 mod = fitlme(red,'acc~pos+(1|sub)','dummyvarcoding','effects');
%                 out = anova(mod);
%                 
%                 %% effect ranges
%                 ave_lp = double(mod.Coefficients(1,2));
%                 lp = double(mod.Coefficients(2:4,2));
%                 lp(end+1) = -sum(lp);
%                 lp_l = min(lp) + ave_lp;
%                 lp_u = max(lp) + ave_lp;
%                 
%                 disp(['Limb position effects: (' num2str(lp_l) ', ' num2str(lp_u) ')'])
%             end
%             
%             for pos = 1:4
%                 red = array2table(data{i}(data{i}(:,2) == pos,:),'VariableNames',{'sub','pos','ld','acc'});
%                 red.sub = nominal(red.sub);
%                 red.ld = nominal(red.ld);
%                 
%                 disp('-----------------')
%                 disp(['Training Method: ' num2str(i) ', Pos: ' num2str(pos)])
%                 disp('REDUCED MODEL')
%                 mod = fitlme(red,'acc~ld+(1|sub)','dummyvarcoding','effects');
%                 out = anova(mod);
%                 
%                 ave_ld = double(mod.Coefficients(1,2));
%                 ld = double(mod.Coefficients(2:3,2));
%                 ld(end+1) = -sum(ld);
%                 ld_l = min(ld) + ave_ld;
%                 ld_u = max(ld) + ave_ld;
%                 
%                 disp(['Load effects: (' num2str(ld_l) ', ' num2str(ld_u) ')'])
%             end
        end
end
end