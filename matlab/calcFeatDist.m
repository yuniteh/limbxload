function out = calcFeatDist(train_data, test_data, varargin)

nPos = max(test_data(:,3));
nClass = max(train_data(:,2));

RI = nan(nPos,nClass);
MSA_te = RI;
SI_te = RI;
MSA_tr = nan(1,nClass);
SI_tr = MSA_tr;

if nargin > 2
    train_ax = 2.*std(train_data(:,4:end));
    MSA_tr = geomean(train_ax);
    test_ax = 2.*std(test_data(:,4:end));
%     out = geomean(test_ax);
    for cl = 1:nClass
        test_feat =  test_data(test_data(:,2) == cl,4:end);
        test_cen = mean(test_feat);
        test_ax = 2.*std(test_feat);
        out(cl) = geomean(test_ax);
    end
else
    for pos = 1:nPos
        for cl = 1:nClass
            test_feat = test_data(test_data(:,2) == cl & test_data(:,3) == pos,4:end);
            train_feat = train_data(train_data(:,2) == cl,4:end);
            
            test_cen = mean(test_feat);
            test_ax = 2.*std(test_data(test_data(:,3) == pos,4:end));
            train_cen = mean(train_feat);
            train_ax = 2.*std(train_data(:,4:end));
            
            RI(pos,cl) = modmahal(test_feat,train_feat);
            MSA_tr(cl) = geomean(train_ax);
            MSA_te(pos,cl) = geomean(test_ax);
            
            for SI_cl = 1:nClass
                SI_feat = train_data(train_data(:,2) == SI_cl,4:end);
                if cl ~= SI_cl
                    SI_trtemp = modmahal(train_feat,SI_feat);
                    if SI_trtemp < SI_tr(cl) || isnan(SI_tr(cl))
                        SI_tr(cl) = SI_trtemp;
                    end
                    
                    SI_tetemp = modmahal(test_feat,SI_feat);
                    if SI_tetemp < SI_te(pos,cl) || isnan(SI_te(pos,cl))
                        SI_te(pos,cl) = SI_tetemp;
                    end
                end
            end
        end
    end
    
    out.RI = RI;
    out.MSA_tr = MSA_tr;
    out.SI_tr = SI_tr;
    out.MSA_te = MSA_te;
    out.SI_te = SI_te;
end

end
