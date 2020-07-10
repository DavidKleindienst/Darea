function fusedComponent = fuse2components(component1,component2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


bothComponents=zeros(size(component1));
bothComponents(:)=max(component1(:),component2(:));

%Distance of each pixel from the object
dist1 = bwdist(component1);
dist2= bwdist(component2);

mindist1=zeros(size(dist1));
mindist2=zeros(size(dist1));

%Get how far each point of component1 is from component2 and vice versa
mindist1(component2==1)=dist1(component2==1);
mindist2(component1==1)=dist2(component1==1);
%NaN is needed so that the minimum will not be a point that is not part of component
mindist1(mindist1==0)=NaN;
mindist2(mindist2==0)=NaN;
%get coordinates of point closest to the other object

[x1, y1]=find(mindist1==nanmin(mindist1(:)));
[x2, y2]=find(mindist2==nanmin(mindist2(:)));

if numel(x1)>1 || numel(x2)>1
    %somehow choose 1 point where to connect
    distances=pdist2([x1 y1], [x2 y2]);
    
    [i, j]=find(distances==min(distances(:)));
    x1=x1(i(1)); y1=y1(i(1));
    x2=x2(j(1)); y2=y2(j(1));
end

mask=createLineMask(size(component1),x1,y1,x2,y2);
fusedComponent=bothComponents+mask;
fusedComponent(fusedComponent==2)=1;

end

