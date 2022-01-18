function [LowerTruth, UpperTruth] = isFittingNecessary(value, upper, lower)
%% Decides whether fitting is necessary, or whether sim_distances are different from accepted.
% Returns [1, 0] if sim_distances are too small or [0, 1] if sim_distances are too large



if isnan(upper)
    UpperTruth=0;
else
    UpperTruth = value>upper;
end

if isnan(lower)
    LowerTruth=0;
else
    LowerTruth = value<lower;
end



end

