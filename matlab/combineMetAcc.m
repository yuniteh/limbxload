function all_met = combineMetAcc(FS,data_all)
%%
nSubs = size(FS,1);
nPos = 4;
nTr = size(FS,2);
nLoad = size(FS,3);
nClass = 7;

f = fieldnames(FS{1,1,1});
all_met = NaN(nSubs*nLoad*2,11);
ind = 1;

for tr = 1:nTr
    for ld = 1:nLoad
        for sub = 1:nSubs
            for names = 1:length(f)
                if ~isempty(FS{sub,tr,ld})
                    temp = [FS{sub,tr,ld}.(f{names})(:,1) nanmean(FS{sub,tr,ld}.(f{names})(:,2:end),2)];
                    evalc([f{names} '= FS{sub,tr,ld}.(f{names});']);
                else
                    evalc([f{names} '= NaN(nPos,7);']);
                end
            end
            for test_pos = 1:nPos
                if size(MSA_tr,1) < nPos
                    MSA_tr = repmat(MSA_tr,nPos,1);
                    SI_tr = repmat(SI_tr,nPos,1);
                end
                
                for dof = 1:size(RI,2)
                    data_ind = data_all(:,1) == sub & data_all(:,2) == ld & data_all(:,3) == tr & data_all(:,4) == test_pos & data_all(:,5) == dof;
                    acc = nanmean(data_all(data_ind,end));
                    all_met(ind,:) = [sub, tr, test_pos, ld, dof, acc, RI(test_pos,dof),MSA_te(test_pos,dof), MSA_tr(test_pos,dof),...
                        SI_te(test_pos,dof), SI_tr(test_pos,dof)];
                    ind = ind + 1;
                end
            end
        end
    end
end

%% check MSA_tr and SI_tr
for sub = 1:nSubs
    for tr = 1:nTr
        for dof = 1:nClass
            ind = all_met(:,1) == sub & all_met(:,2) == tr & all_met(:,5) == dof;
            if sum(ind) > 0
                for met = [9 11]
                    all_met(ind,met) = mode(all_met(ind,met));
                end
            end
        end
    end
end


end