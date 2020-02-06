% [cm_all, acc_all, sub_rate, FS] = calcOffline(subType);


%%
f = fieldnames(FS{1,1,1});

for tr = 1:size(FS,2)
    for ld = 1:size(FS,3)
        for sub = 1:size(FS,1)
            for names = 1:length(f)
                if ~isempty(FS{sub,tr,ld})
                    FS2{sub,tr,ld}.(f{names}) = [FS{sub,tr,ld}.(f{names})(:,1) nanmean(FS{sub,tr,ld}.(f{names})(:,2:end),2)];
                else
                    FS2{sub,tr,ld}.(f{names}) = NaN(1,size(FS{1,1,1}.(f{names}),1),2);
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