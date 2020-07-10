function bool= checkColinearity(points)
% Checks whether all points lie on one line.
% If so returns true; otherwise returns false
nrPoints=size(points,1);
[k, d]=getLine(points(end-1:end,:)); %Make line through pair of points

for i=1:2:nrPoints-2
    [k2, d2]=getLine(points(i:i+1,:));          %Compare with all other pairs through pair of points
    if ~nearEnough(k,k2) || ~nearEnough(d,d2)    %If lines are ever different, points are not colinear.
        bool=false;
        return
    end
end
bool=true;
