function distance=distancePointLine(P,L)
%% Calculates the distance between a Point P[x,y] and a line given by two points L[x1,y1;x2,y2]
% Returns NaN if the shortest distance would be to a point that does not lie between the two points specified by L.

[k,d]=getLine(L);  %get k and d parameters describing the line

Px=P(1,1);
Py=P(1,2);

if isnan(k)       %Line parallel to y-Axis
    distance=abs(L(1,1)-Px);            
elseif k==0       %Line parallel to x-Axis
    distance=abs(L(1,2)-Py);
else
    k2=-k;          %gets k and d of the line perpendicular to L that goes through P
    d2=Py-(k2*Px);
    Sx=(d2-d)/(k-k2);   %computes Intersection
    Sy=k*Sx+d;
    
    if Sx>L(1,1) && Sx>L(2,1) || Sx<L(1,1) && Sx<L(2,1) || Sy>L(1,2) && Sy>L(2,2) || Sy<L(1,2) && Sy<L(2,2)
        %if Intersection is not within the two points of L, return NaN
        distance=NaN;
    else
        distance=pdist([P;Sx,Sy]); %Otherwise compute the distance between P and the Intersection point
    end
    
end