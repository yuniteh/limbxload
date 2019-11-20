function vars = loadTxt(txtname)

testdata = dlmread(txtname);

%% correct time
vars.t = testdata(:,1) - testdata(1,1);
skip = find(diff(vars.t) >= 4000) + 1;
for i = 1:length(skip)
    vars.t(skip(i):end) = vars.t(skip(i):end) - 4000;
end
skip = find(diff(vars.t) >= 40) + 1;
for i = 1:length(skip)
    vars.t(skip(i):end) = vars.t(skip(i):end) - 40;
end

%% load variables
vars.pos = testdata(:,2);
vars.class = testdata(:,3);
vars.tf = testdata(:,4);
vars.af = testdata(:,5);
vars.cout = testdata(:,6);
vars.prop = testdata(:,7);
vars.OC = testdata(:,8);
vars.FE = testdata(:,9);
vars.PS = testdata(:,10);