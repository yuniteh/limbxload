out = data.tr;
tr_type = 2;
metList = {'comp','move','stop','time'};
out = out(out.tr == tr_type,:);

out.sub = categorical(out.sub);
out.pos = categorical(out.pos,[1,2,3,4]);
out.ld = categorical(out.ld,[1,2,3]);

%%
posp = zeros(nchoosek(4,2),4);
ldp = zeros(nchoosek(3,2),4);

for metI = 1:4
    met = metList{metI};
    [p, ~, stat] = anovan(out.(met),{out.pos,out.ld,out.sub},...
        'varnames',{'pos','load','sub'},'model',[1 0 0; 0 1 0;1 1 0; 0 0 1],...
        'random',3,'display','on');
    temp = multcompare(stat);
    posp(:,metI) = temp(:,end);
    temp = multcompare(stat,'dimension',2);
    ldp(:,metI) = temp(:,end);
end
