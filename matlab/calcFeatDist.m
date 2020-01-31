function [RI, MSA_tr, MSA_te, SI_tr, SI_te] = calcFeatDist(train_data, test_data)

nPos = max(train_data(:,3));
nClass = max(train_data(:,2));

RI = nan(nPos,nClass);                     % repeatability index
MSA_tr = RI;                               % mean semi-principal axis
MSA_te = RI;
SI_tr = RI;
SI_te = RI;

for pos = 1:nPos
    for cl = 1:nClass
        test_feat = test_data(test_data(:,2) == cl & test_data(:,3) == pos,4:end);
        train_feat = train_data(train_data(:,2) == cl,4:end);
        
        test_cen = mean(test_feat);
        test_ax = 2.*std(test_feat);
        train_cen = mean(train_feat);
        train_ax = 2.*std(train_feat);
        
        RI(pos,cl) = modmahal(test_feat,train_feat);
        MSA_tr(pos,cl) = geomean(train_ax);
        MSA_te(pos,cl) = geomean(test_ax);
        
        for SI_cl = 1:nClass
            SI_feat = train_data(train_data(:,2) == SI_cl,4:end);
            if cl ~= SI_cl
                SI_trtemp = modmahal(train_feat,SI_feat);
                if SI_trtemp < SI_tr(pos,cl) || isnan(SI_tr(pos,cl))
                    SI_tr(pos,cl) = SI_trtemp;
                end
                
                SI_tetemp = modmahal(test_feat,SI_feat);
                if SI_tetemp < SI_te(pos,cl) || isnan(SI_te(pos,cl))
                    SI_te(pos,cl) = SI_tetemp;
                end
            end
        end
    end
end
end
