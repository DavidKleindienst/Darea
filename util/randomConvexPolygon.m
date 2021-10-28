function polygon = randomConvexPolygon(nrPoints,distribution,plotPoly)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin<3
    plotPoly=0;
end
assert(nrPoints>=3);
if strcmp(distribution, 'normal')
    x=randn(nrPoints,1);
    y=randn(nrPoints,1);
elseif strcmp(distribution, 'uniform')
    x=rand(nrPoints,1);
    y=rand(nrPoints,1);
else
    fprintf('distribution %s not known',distribution);
    return;
end
x=sort(x);
y=sort(y);

xI=x(2:end-1);
yI=y(2:end-1);

idx=logical(round(rand(nrPoints-2,1)));
idy=logical(round(rand(nrPoints-2,1)));

xSet1=[x(1); xI(idx); x(end)];
xSet2=[x(end); flip(xI(~idx)); x(1)];

ySet1=[y(1); yI(idy); y(end)];
ySet2=[y(end); flip(yI(~idy)); y(1)];

xVectors=[diff(xSet1);diff(xSet2)];
yVectors=[diff(ySet1);diff(ySet2)];

xVectors=xVectors(randperm(numel(xVectors)));
yVectors=yVectors(randperm(numel(yVectors)));
try
    Vectors=[xVectors yVectors];
catch 
    
    return;
end
angles=rad2deg(angle(Vectors(:,1)+1i*Vectors(:,2)));
[~,sortIdx]=sort(angles);
Vectors=Vectors(sortIdx,:);

polygon=[0,0; cumsum(Vectors)];

if plotPoly
    figure;
    plot(polygon(:,1),polygon(:,2));
end

end

