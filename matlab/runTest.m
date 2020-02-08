% [cm_all, acc_all, sub_rate, FS] = calcOffline(subType);


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
                data_ind = data_all(:,1) == sub & data_all(:,2) == ld & data_all(:,3) == tr & data_all(:,4) == test_pos;
                acc = nanmean(data_all(data_ind,end));
                for dof = 1:size(RI,2)
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
%%

nPos = 4;
nClass = 7;

f = fieldnames(FS2{1,1,1});

for tr = 1:size(FS2,2)
    for ld = 1:size(FS2,3)
        for sub = 1:size(FS2,1)
            for names = 1:length(f)
                temp.(f{names})(sub,:,:) = FS2{sub,tr,ld}.(f{names});
            end
        end
        for names = 1:length(f)
            out.(f{names}){tr,ld} = nanmean(temp.(f{names}),1);
            out.(f{names}){tr,ld} = reshape(out.(f{names}){tr,ld},size(out.(f{names}){tr,ld},2),size(out.(f{names}){tr,ld},3));
        end
    end
end

%%
% featAll = calcOffStat(subType);

%%
%1: sub
%2: training load
%3: training position
%4: testing position
%5: testing load
%6: accuracy

f = {'RI','MSA_te','MSA_tr','SI_te','SI_tr'};

nSubs = size(featAll,1);
nLoad = size(featAll,3);
nPos = size(featAll,2);

acc = cell(size(featAll));
all_met = NaN(nSubs*nLoad*nPos*nLoad,16);
ind = 1;
for ld = 1:nLoad
    for pos = 1:nPos
        for test_ld = 1:nLoad
            for sub = 1:nSubs
                if ~isempty(featAll{sub,pos,ld,test_ld})
                    acc = nanmean(featAll{sub,pos,ld,test_ld}.acc,2);
                    for names = 1:length(f)
                        temp = [featAll{sub,pos,ld,test_ld}.(f{names})(:,1) nanmean(featAll{sub,pos,ld,test_ld}.(f{names})(:,2:end),2)];
                        evalc([f{names} '= temp']);
                    end
                else
                    acc = NaN(size(featAll,2),1);
                    for names = 1:length(f)
                        evalc([f{names} '= NaN(nPos,2);']);
                    end
                end
                
                for test_pos = 1:nPos
                    if size(MSA_tr,1) < nPos
                        MSA_tr = repmat(MSA_tr,nPos,1);
                        SI_tr = repmat(SI_tr,nPos,1);
                    end
                    all_met(ind,:) = [sub, ld, pos, test_pos, test_ld, acc(test_pos), RI(test_pos,:),MSA_te(test_pos,:), MSA_tr(test_pos,:),...
                        SI_te(test_pos,:), SI_tr(test_pos,:)];
                    ind = ind + 1;
                end
            end
        end
    end
end

%% check MSA_tr and SI_tr
for sub = 1:nSubs
    for ld = 1:nLoad
        for pos = 1:nPos
            ind = all_met(:,1) == sub & all_met(:,2) == ld & all_met(:,3) == pos;
            for met = [11 12 15 16]
                all_met(ind,met) = mode(all_met(ind,met));
            end
        end
    end
end