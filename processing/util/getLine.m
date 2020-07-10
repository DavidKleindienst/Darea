function [k,d]=getLine(P)
%% Returns parameters k and d describing the line the goes through the two points specified by P
% Returns k=NaN if line is parallel to y-Axis

%Simplify coordinates of the points
x1=P(1,1);
y1=P(1,2);
x2=P(2,1);
y2=P(2,2);

if y1==y2 %Line parallel to x-Axis
    d=y1;
    k=0;
elseif x1==x2 %Line parallel to y-Axis
    k=NaN;
    d=x1;
else
    k=(y1-y2)/(x1-x2);
    d=y1-(k*x1);
end