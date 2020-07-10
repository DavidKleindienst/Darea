function stats = sixStats(vector)
%% Generates six results from a vector of numbers:
%
%   - Maximum value
%   - Minimum value
%   - Mean
%   - Standard deviation
%   - Sum 
%   - Number of elements considered (only those which are not NaN).

%   vector:         vector of numbers.

%   stats:          values reported.

stats = zeros(6,1);

% Deletes NaN elements from the vector.
cleanVector = vector(~isnan(vector));

% Calculates the statistics.
if numel(cleanVector)>0
    stats(1) = max(cleanVector);
    stats(2) = min(cleanVector);
    stats(3) = mean(cleanVector);
    stats(4) = std(cleanVector);
    stats(5) = sum(cleanVector);
    stats(6) = numel(cleanVector);
else
    stats(1) = NaN;
    stats(2) = NaN;
    stats(3) = NaN;
    stats(4) = NaN;
    stats(5) = NaN;
    stats(6) = NaN;
end

end

