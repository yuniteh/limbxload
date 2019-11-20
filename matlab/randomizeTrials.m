function randomizeTrials(sub,amp)

% training data order
if amp == 1
    load = 3;
    pos = 4;
else
    load = 4;
    pos = 5;
end

rng(sub);
randperm(2)

% testing load order
for i = 1:3
    randperm(load)
end

% feedforward order
for i = 1:load
    randperm(pos)
end
end

