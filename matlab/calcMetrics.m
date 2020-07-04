function [dataOut] = calcMetrics(data,subType)
dataOut = data;
if strcmp(subType,'AB')
    numPos = 5;
else
    numPos = 4;
end
numDOF = max(data.txt.class);
numTrials = numPos * numDOF;
%% FIND TRIAL BEGINNINGS AND ENDS
first_start = [0; diff(data.txt.tf) == -3];

% completed trials
complete = data.txt.tf == 2;
comp_end = diff(complete) == 1;
comp_start = diff(complete) == -1;
comp_padded = [0; comp_end];
comp_t = data.txt.t(comp_padded == 1);

% failed trials
fail = data.txt.tf == -1;
fail_end = diff(fail) == 1;
fail_start = diff(fail) == -1;
fail_padded = [0; fail_end];
fail_t = data.txt.t(fail_padded == 1);

% find trial start and end points
start = comp_start | fail_start;
start_full = [0; start];
post.txt.time = [data.txt.t(first_start==1); data.txt.t(start_full==1)];
t_end = [comp_t ones(size(comp_t)); fail_t zeros(size(fail_t))];
[post.txt.time(:,2), ind] = sort(t_end(:,1));
post.txt.ind(:,1) = [find(first_start); find(start_full)];
post.txt.ind(:,2) = sort([find(comp_padded); find(fail_padded)]);

% find arm position and task DOF
post.pos = data.txt.pos(post.txt.ind(:,1) + 5);
post.dof = data.txt.class(post.txt.ind(:,1) + 5);
%% CALCULATE METRICS
% completion time
post.txt.time(:,3) = post.txt.time(:,2) - post.txt.time(:,1);

% completion flag
post.cf = t_end(ind,2);

% path efficiency
post.path = zeros(size(post.txt.time,1),1);
for i = 1:size(post.txt.time,1)
    post.path(i,1) = sum(sqrt(diff(data.txt.OC(post.txt.ind(i,1):post.txt.ind(i,2))).^2 + diff(data.txt.FE(post.txt.ind(i,1):post.txt.ind(i,2))).^2 + diff(data.txt.PS(post.txt.ind(i,1):post.txt.ind(i,2))).^2));
end

% mean error and movement efficacy
post.dist = zeros(size(post.txt.time,1),1);
targets = zeros(6,3);
targets(:,1) = 15;
targets(1,1) = 22.5;
targets(2,1) = 52.5;
targets(4,2) = 52.5;
targets(5,3) = 52.5;
targets(3,2) = -52.5;
targets(6,3) = -52.5;
coord = [data.txt.OC data.txt.PS data.txt.FE];
coordloc = [1;1;2;2;3;3];
dir = [-1;1;-1;1;1;-1];

% loop through each trial
for i = 1:size(post.txt.time,1)
    dof = post.dof(i);          % current task DOF
    tf = data.txt.tf(post.txt.ind(i,1):post.txt.ind(i,2));      % trial completion flags
    af = data.txt.af(post.txt.ind(i,1):post.txt.ind(i,2));      % arm position flags
    coord_t = coord(post.txt.ind(i,1):post.txt.ind(i,2),:);     % xyz coordinates
    targ_array = repmat(targets(dof,:),size(coord_t,1),1);      % target coordinates array
    dist = sqrt(sum((coord_t-targ_array).^2,2));                % distance between controller and target
    post.dist(i,1) = mean(dist);                                % average distance
    
    cout = data.txt.cout(post.txt.ind(i,1):post.txt.ind(i,2));      % classifier output
    prop = data.txt.prop(post.txt.ind(i,1):post.txt.ind(i,2));      % proportional control output
    targ_diff = sign(targ_array - coord_t);                         % target direction
    trial_dir = 3.*ones(size(targ_diff));
    
    % loop through all classifier outputs in trial
    for j = 1:length(cout)
        class = cout(j);        % current classifier output
        if class > 0            % if not resting
            trial_dir(j,coordloc(class)) = dir(class);      % current controller xyz direction
        else
            trial_dir(j,:) = targ_diff(j,:);                
        end
    end
    prop = prop(tf == 0 & af == 1 & cout ~= 0);                                                                 % proportional output when arm is in the right position but not in target, not resting
    bool = sum(trial_dir(tf == 0 & af == 1 & cout ~= 0,:) == targ_diff(tf == 0 & af == 1 & cout ~= 0,:),2);     % >0 if in the right direction, ==0 if not
    true_dir = bool > 0;                                                                                        % indices of movements in the target direction
    post.move_eff(i,1) = sum(prop(true_dir))./sum(prop);                                                        % movement efficacy
    cout_temp = cout(tf == 0 & af == 1);                                                                        % classifier outputs when not in target but in arm position
    for j = 1:numDOF
        post.moveDOF(i,j) = sum(cout_temp(bool == 0) == j);                                                     % total #samples moving in the wrong direction
        post.totDOF(i,j) = sum(cout_temp == j);                                                                 % total #samples of current class out
    end
end

%%
% unintended movement time
for i = 1:size(post.txt.time,1)
    tf = data.txt.tf(post.txt.ind(i,1):post.txt.ind(i,2));
    tf = tf == 1;           % when in target
    % max time in target
    tf_diff = [0; diff(tf)];            % index going in and out of trial target
    tf_start = find(tf_diff == 1);      % going into target
    tf_end = find(tf_diff == -1);       % leaving target
    if tf(end)                          % if trial ends with hand in target
        tf_end = [tf_end; length(tf)];          % append last index
    end
    tf_length = tf_end - tf_start;              % length of each target in period
    if length(tf_length > 0)                    % if hand was in target during trial
        post.max_in(i,1) = max(tf_length);      % max time in target
    else
        post.max_in(i,1) = 0;                   % no time spent in target
    end
    % sliding window in
    best_in = 0;
    for j = 1:length(tf) - 19
        next_in = sum(tf(j:j+19) == 1);
        best_in = max([next_in; best_in]);          % max time in target in 2s window
    end
    post.best_in(i,1) = best_in;
    % unintended movement time
    class = data.txt.cout(post.txt.ind(i,1):post.txt.ind(i,2));         % classifier output
    prop = data.txt.prop(post.txt.ind(i,1):post.txt.ind(i,2));          % proportional output
    move = sum(tf == 1 & class ~= 0 & prop > 0);                        % when not resting
    post.move(i,1) = sum(move);                                         % total time spent moving
    post.in(i,1) = sum(tf == 1);                                        % total time spent in target
    
    % unintended movements
    for j = 1:numDOF
        temp = sum(tf == 1 & class == j);                               % when in target and moving in current class
        %post.moveDOF(i,j) = post.moveDOF(i,j) + sum(temp);             % add to movements in wrong direction
        post.restDOF(i,j) = sum(temp);                                  % unintended movements when in target
    end
end

% add nan entries for unused DOFs
add = 6 - size(post.moveDOF,2);
new_mat = NaN(size(post.moveDOF,1),add);                                
post.moveDOF = [post.moveDOF new_mat];
post.totDOF = [post.totDOF new_mat];

%% AVERAGE/COMPILE RESULTS
for i = 0:numPos - 1
    results.c_rate(1,i+1) = sum(post.cf(post.pos == i))/size(post.cf(post.pos == i),1);
    results.c_time_mean(1,i+1) = mean(post.txt.time(post.cf == 1 & post.pos == i,3));
    results.eff_mean(1,i+1) = mean(52./post.path(post.cf == 1 & post.pos == i));
    results.in(1,i+1) = sum(post.in(post.pos == i));
    results.move(1,i+1) = sum(post.move(post.pos == i));
end

%% clear all variables except data and results
clearvars -except data dataOut results post numTrials numPos subType

%% adjust delay from unity to embedded
t = data.daq.t(1:25:end);
temp = diff(data.pvd.TARGET_DOF);
pvd_marks = temp ~= 0;
temp = diff(data.txt.class);
txt_marks = temp ~= 0;
pvd_t = t(pvd_marks == 1);
txt_t = data.txt.t(txt_marks == 1);
delay = mean(pvd_t(end-(numTrials-2)) - txt_t(end-(numTrials-2)));
t = t - delay;

for i = 1:size(post.txt.time,1)
    diff_t = abs(post.txt.time(i,1) - t);
    [temp, post.pvd.ind(i,1)] = min(diff_t);
    post.pvd.time(i,1) = t(post.pvd.ind(i,1));
    diff_t = abs(post.txt.time(i,2) - t);
    [temp, post.pvd.ind(i,2)] = min(diff_t);
    post.pvd.time(i,2) = t(post.pvd.ind(i,2));
    post.pvd.time(i,3) = post.pvd.time(i,2) - post.pvd.time(i,1);
end

%% truncate end
names = fieldnames(data.pvd);
while data.pvd.TRIAL_FLAG(end) ~= 2 && data.pvd.TRIAL_FLAG(end) ~= -1
    for i = 1:length(names)
        data.pvd.(names{i})(end,:) = [];
    end
end
post.dof = data.pvd.TARGET_DOF(post.pvd.ind(:,1) + 5);

%% ASSIGN OUTPUTS
dataOut.post = post;
dataOut.results = results;

end