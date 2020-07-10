function [LowerTruth, UpperTruth] = isFittingNecessary(real_distances, sim_distances, upper, lower, Options)
%% Decides whether fitting is necessary, or whether sim_distances are different from accepted.
% Returns [1, 0] if sim_distances are too small or [0, 1] if sim_distances are too large

%Computes parameters from Data that will be used for comparison
simMean=mean(sim_distances);
simMed=median(sim_distances);
[~,KS]=kstest2(real_distances,sim_distances);

%First set to 0.
UpperTruth=0; LowerTruth=0;

if isnan(upper)
    UpperTruth=0;
elseif Options.bounds{2,1}==4
    if simMed>upper
        UpperTruth=1;
    end
elseif Options.bounds{2,1}==6
    if KS>upper 
        UpperTruth=1; 
    end
elseif simMean>upper
    UpperTruth=1;
end

if isnan(lower)
    LowerTruth=0;
elseif Options.bounds{1,1}==4
    if simMed<lower
        LowerTruth=1;
    end
elseif Options.bounds{1,1}==6
    if KS<lower
        LowerTruth=1; 
    end
elseif simMean<lower
    LowerTruth=1;
end

end

