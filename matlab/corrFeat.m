function corrFeat(data)
for sub = 1:max(data.sub)
    for train = 1:max(data.tr)
        for pos = 1:max(data.pos)
            for ld = 1:max(data.ld)
                ind = data.sub == sub & data.tr == train & data.pos == pos & data.ld == ld;
                data
            end
        end
    end
end 