function [diff, smaller,greater] = getSignificance(sample,simulated,pval)
%% Computes whether a given sample is significantly different from a set of simulations
%Returns NaN if either sample or simulated is NaN

if isnan(sample) || all(isnan(simulated))
    diff=NaN; smaller=NaN; greater=NaN;
else
    smaller=numel(simulated(simulated<=sample))/numel(simulated)<pval;
    greater=numel(simulated(simulated>=sample))/numel(simulated)<pval;
    diff=numel(simulated(simulated<=sample))/numel(simulated)<pval || numel(simulated(simulated>=sample))/numel(simulated)<pval;
end

end

