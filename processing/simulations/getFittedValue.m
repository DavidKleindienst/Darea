function value = getFittedValue(real_distances,sim_distances, boundname)
%GETFITTEDVALUE Summary of this function goes here
%   Detailed explanation goes here

switch boundname
    case 'xth Percentile'
        value = median(sim_distances);
    case 'KS'
        [~,value] = kstest2(real_distances,sim_distances);
    otherwise
        value = mean(sim_distances);
end
end

