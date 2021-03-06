%% Append modified real-time movement efficacy to data table
%% data_dof format
% 1: subject ID
% 2: load
% 3: training method
% 4: position
% 5: task DOF
% 6-11: movements in wrong direction (moveDOF)
% 12-17: total movements when not in target (totDOF)
% 18: movements while in target
% 19: total time in target

function data = appendMove(data,met)
data.qual = nan(size(data.sub,1),1);
for sub = 1:max(data.sub)
    for ld = 1:max(data.ld)
        for tr = 1:max(data.tr)
            for pos = 1:max(data.pos)
                ind = met(:,1) == sub & met(:,2) == ld & met(:,3) == tr & met(:,4) == pos;
                for dof = 1:max(data.dof)
                    data_ind = data.sub == sub & data.ld == ld & data.tr == tr & data.pos == pos & data.dof == dof;
                    if dof == 1
                        move = sum(met(ind,18));
                        in = sum(met(ind,19));
                        qual = 1-(move/in);
                    else
                        moveTemp = met(ind,6:11);
                        totTemp = met(ind,12:17);
                        moveDOF = sum(moveTemp(:,dof - 1));
                        totDOF = sum(totTemp(:,dof - 1));
                        qual = moveDOF/totDOF;
                    end
                    data.qual(data_ind,:) = qual;
                end
            end
        end
    end
end
end
