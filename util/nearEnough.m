function out = nearEnough(in1,in2,maxDifference)
%% Compares equality of two numbers, returns true or false.
% Returns true if numbers are virtually identically i.e. difference between
% them is less max Difference (default 10^-6)
% This is to avoid false non-equality due to rounding errors

if nargin<3
    maxDifference = 1e-6;
end

if isnan(in1) & isnan(in2)
    out=true;
elseif isnan(in1) | isnan(in2)
    out=false;
elseif isa(in1,'double') | isa(in2,'double')
    out = (in1-in2)<maxDifference & (in1-in2)>-maxDifference;
else
    out = in1==in2;
end

end