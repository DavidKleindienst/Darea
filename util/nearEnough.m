function out = nearEnough(in1,in2)
%% Compares equality of two numbers, returns true or false.
% Returns true if numbers are virtually identically i.e. difference between them is less than 10^6
% This is to avoid false non-equality due to rounding errors

if isnan(in1) && isnan(in2)
    out=true;
elseif isnan(in1) || isnan(in2)
    out=false;
elseif isa(in1,'double') || isa(in2,'double')
    if in1-in2<0.000001 && in1-in2>-0.000001
        out=true;
    else
        out=false;
    end
else
    if in1==in2
        out=true;
    else
        out=false;
    end
end

