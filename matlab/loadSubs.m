function subAll = loadSubs(subType, varargin)
disp('Loading subject data...')

if strcmp(subType,'AB')
    numLoad = 4;
else
    numLoad = 3;
end

if isempty(varargin)
    temp = readtable(['limb position x load/completed/' subType '/subs.xlsx'],'ReadVariableNames',0);
    
    subAll.subs = temp{:,1};
    subAll.testOrder = temp{:,2:3};
    subAll.loadOrder = temp{:,4:3 + 2*numLoad};
    subAll.trainOrder = temp{:,4 + 2*numLoad:end-1};
    subAll.statOrder = temp{:,end};
    save(['limb position x load/completed/' subType '/subs.mat'],'subAll')
else
    load(['limb position x load/completed/' subType '/subs.mat'])
end