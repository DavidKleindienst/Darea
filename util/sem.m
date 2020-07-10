function error = sem(input)
%% Computes Standard error of the mean
% ignores NaNs present in input
% Returns NaN if input is empty

if isempty(input) 
    error=NaN;
else
    error=nanstd(input)./sqrt(length(input)-sum(isnan(input)));
end

end

