function poolsize = getCurrentPoolSize()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    poolsize = 0;
else
    poolsize = poolobj.NumWorkers;
end
end

