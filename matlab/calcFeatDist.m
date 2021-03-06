function out = calcFeatDist(train_data, test_data, varargin)

nPos = max(test_data(:,3));
nClass = max(train_data(:,2));
nLoad = max(train_data(:,1)) - 2;

RI = nan(nPos,nClass);
MSA_te = RI;
SI_te = RI;
MSA_tr = nan(1,nClass);
SI_tr = MSA_tr;

if nargin > 2
    type = varargin{1};
    switch type
        case 1
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
        case 2 % baseline = ld = 0
            RI = nan(nPos, nLoad, nClass);
            SI = RI;
            SI_te = RI;
            MSA = RI;
            for pos = 1:nPos
                for ld = 1:nLoad
                    for cl = 1:nClass
                        train_feat = train_data(train_data(:,1) == 3 & train_data(:,2) == cl...
                            & train_data(:,3) == pos,4:end);
                        test_feat = test_data(test_data(:,1) == ld+2 & test_data(:,2) == cl...
                            & train_data(:,3) == pos,4:end);
                        RI(pos,ld,cl) = modmahal(test_feat,train_feat);
                        test_ax = 2.*std(test_feat);
                        MSA(pos,ld,cl) = geomean(test_ax);
                        
                        for SI_cl = 1:nClass
                            SI_feat = train_data(train_data(:,1) == 3 & train_data(:,2) == SI_cl...
                                & train_data(:,3) == pos,4:end);
                            SI_te_feat = test_data(test_data(:,1) == ld+2 & test_data(:,2) == SI_cl...
                                & test_data(:,3) == pos,4:end);
                            if cl ~= SI_cl
                                SI_temp = modmahal(test_feat,SI_feat);
                                if SI_temp < SI(pos,ld,cl) || isnan(SI(pos,ld,cl))
                                    SI(pos,ld,cl) = SI_temp;
                                end
                                SI_tetemp = modmahal(test_feat,SI_te_feat);
                                if SI_tetemp < SI_te(pos,ld,cl) || isnan(SI_te(pos,ld,cl))
                                    SI_te(pos,ld,cl) = SI_tetemp;
                                end
                                
                            end
                        end
                    end
                end
            end
            out.RI = RI;
            out.SI = SI;
            out.SI_te = SI_te;
            out.MSA = MSA;
        case 3 % baseline = pos 1
            RI = nan(nPos, nLoad, nClass);
            SI = RI;
            SI_te = RI;
            MSA = RI;
            for pos = 1:nPos
                for ld = 1:nLoad
                    for cl = 1:nClass
                        train_feat = train_data(train_data(:,1) == ld+2 & train_data(:,2) == cl...
                            & train_data(:,3) == 1,4:end);
                        test_feat = test_data(test_data(:,1) == ld+2 & test_data(:,2) == cl...
                            & train_data(:,3) == pos,4:end);
                        RI(pos,ld,cl) = modmahal(test_feat,train_feat);
                        test_ax = 2.*std(test_feat);
                        MSA(pos,ld,cl) = geomean(test_ax);
                        
                        for SI_cl = 1:nClass
                            SI_feat = train_data(train_data(:,1) == ld+2 & train_data(:,2) == SI_cl...
                                & train_data(:,3) == 1,4:end);
                            SI_te_feat = test_data(test_data(:,1) == ld+2 & test_data(:,2) == SI_cl...
                                & test_data(:,3) == pos,4:end);
                            if cl ~= SI_cl
                                SI_temp = modmahal(test_feat,SI_feat);
                                if SI_temp < SI(pos,ld,cl) || isnan(SI(pos,ld,cl))
                                    SI(pos,ld,cl) = SI_temp;
                                end
                                SI_tetemp = modmahal(test_feat,SI_te_feat);
                                if SI_tetemp < SI_te(pos,ld,cl) || isnan(SI_te(pos,ld,cl))
                                    SI_te(pos,ld,cl) = SI_tetemp;
                                end
                                
                            end
                        end
                    end
                end
            end
            out.RI = RI;
            out.SI = SI;
            out.SI_te = SI_te;
            out.MSA = MSA;
        case 4 % all combos
            RI = nan(nPos,nPos, nLoad, nClass);
            SI = RI;
            SI_te = RI;
            for tr_pos = 1:4;
                for pos_i = 1:nPos
                    posMat = nchoosek(1:4, pos_i);
                    posMat(sum(posMat==tr_pos,2) ~= 1,:) = [];
                    RI_c = nan(size(posMat,1),nLoad,nClass);
                    SI_c = RI_c;
                    SI_te_c = RI_c;
                    for combo = 1:size(posMat,1)
                        temp_pos = nan(size(train_data,1),pos_i);
                        for ind_i = 1:pos_i
                            temp_pos(:,ind_i) = train_data(:,3) == posMat(combo,ind_i);
                        end
                        pos_ind = temp_pos(:,1);
                        if pos_i > 1
                            for ind_i = 2:size(temp_pos,2)
                                pos_ind = pos_ind | temp_pos(:,ind_i);
                            end
                        end
                        
                        for ld = 1:nLoad
                            for cl = 1:nClass
                                train_feat = train_data(train_data(:,1) == ld+2 & train_data(:,2) == cl...
                                    & train_data(:,3) == tr_pos,4:end);
                                test_feat = test_data(test_data(:,1) == ld+2 & test_data(:,2) == cl...
                                    & pos_ind,4:end);
                                
                                RI_c(combo,ld,cl) = modmahal(test_feat,train_feat);
                                test_ax = 2.*std(test_feat);
                                MSA_c(combo,ld,cl) = geomean(test_ax);
                                
                                for SI_cl = 1:nClass
                                    SI_feat = train_data(train_data(:,1) == ld+2 & train_data(:,2) == SI_cl...
                                        & train_data(:,3) == tr_pos,4:end);
                                    SI_te_feat = test_data(test_data(:,1) == ld+2 & test_data(:,2) == SI_cl...
                                        & test_data(:,3) == pos_ind,4:end);
                                    if cl ~= SI_cl
                                        SI_temp = modmahal(test_feat,SI_feat);
                                        if SI_temp < SI_c(combo,ld,cl) || isnan(SI_c(combo,ld,cl))
                                            SI_c(combo,ld,cl) = SI_temp;
                                        end
                                        SI_tetemp = modmahal(test_feat,SI_te_feat);
                                        if SI_tetemp < SI_te_c(combo,ld,cl) || isnan(SI_te_c(combo,ld,cl))
                                            SI_te_c(combo,ld,cl) = SI_tetemp;
                                        end
                                        
                                    end
                                end
                            end
                        end
                    end
                    RI_i(pos_i,:,:) = nanmean(RI_c,1);
                    SI_i(pos_i,:,:) = nanmean(SI_c,1);
                    SI_te_i(pos_i,:,:) = nanmean(SI_te_c,1);
                    MSA_i(pos_i,:,:) = nanmean(MSA_c,1);
                end
                RI(tr_pos,:,:,:) = RI_i;
                SI(tr_pos,:,:,:) = SI_i;
                SI_te(tr_pos,:,:,:) = SI_te_i;
                MSA(tr_pos,:,:,:) = MSA_i;
            end
            out.RI = squeeze(nanmean(RI,1));
            out.SI = squeeze(nanmean(SI,1));
            out.SI_te = squeeze(nanmean(SI_te,1));
            out.MSA = squeeze(nanmean(MSA,1));
    end
    
else
    for pos = 1:nPos
        for cl = 1:nClass
            test_feat = test_data(test_data(:,2) == cl & test_data(:,3) == pos,4:end);
            train_feat = train_data(train_data(:,2) == cl,4:end);
            
            test_cen = mean(test_feat);
            test_ax = 2.*std(test_feat);
            train_cen = mean(train_feat);
            train_ax = 2.*std(train_feat);
            
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
