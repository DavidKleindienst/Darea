function distance=dist2Clusters(poly1, poly2, Options)
%% Calculates the distance between the polygons poly1 and poly2
%Options is a struct containing the field ClusterDistanceMethod, 
%      which defines how distances between two clusters should be measured.
%ClusterDistanceMethod=1 - Distance between the outlines of the Cluster
%ClusterDistanceMethod=2 - Distance between the two nearest particles
%ClusterDistanceMethod=3 - Distance between Centers of Gravity

%Simplify the polygons into x and y coordinates
pAx=poly1(:,1);
pAy=poly1(:,2);
pBx=poly2(:,1);
pBy=poly2(:,2);
%Get all points of A inside B and vice versa
AinB=[];
BinA=[];
for p=1:size(pAx)
    if inpolygon(pAx(p),pAy(p),pBx,pBy)
        AinB=[AinB;poly1(p,:)];
    end
end
for p=1:size(pBx)
    if inpolygon(pBx(p),pBy(p),pAx,pAy)
        BinA=[BinA;poly2(p,:)];
    end
end
if Options.ClusterDistanceMethod==3      %Distance between centers of gravity
    chA=convhull(poly1(:,1), poly1(:,2));
    chB=convhull(poly2(:,1), poly2(:,2));
    sortedAx=poly1(chA,1);
    sortedAy=poly1(chA,2);
    sortedBx=poly2(chB,1);
    sortedBy=poly2(chB,2);
    
    %get Area of the polygons
    ArA=0.5*sum(sortedAx(1:end-1).*sortedAy(2:end)-sortedAx(2:end).*sortedAy(1:end-1));
    ArB=0.5*sum(sortedBx(1:end-1).*sortedBy(2:end)-sortedBx(2:end).*sortedBy(1:end-1));
    
    %calculate Centers of Gravity
    MassAx=(1/(6*ArA))*sum((sortedAx(1:end-1)+sortedAx(2:end)).*(sortedAx(1:end-1).*sortedAy(2:end)-sortedAx(2:end).*sortedAy(1:end-1)));
    MassAy=(1/(6*ArA))*sum((sortedAy(1:end-1)+sortedAy(2:end)).*(sortedAx(1:end-1).*sortedAy(2:end)-sortedAx(2:end).*sortedAy(1:end-1)));
    
    MassBx=(1/(6*ArB))*sum((sortedBx(1:end-1)+sortedBx(2:end)).*(sortedBx(1:end-1).*sortedBy(2:end)-sortedBx(2:end).*sortedBy(1:end-1)));
    MassBy=(1/(6*ArB))*sum((sortedBy(1:end-1)+sortedBy(2:end)).*(sortedBx(1:end-1).*sortedBy(2:end)-sortedBx(2:end).*sortedBy(1:end-1)));
   
    %Calculate distance between the Centers of Gravity
    distance=pdist([MassAx MassAy; MassBx MassBy], 'euclidean');
elseif size(AinB,1)>0 || size(BinA,1)>0       %if any of the points is within the other cluster, set distance to 0.
    distance=0;
else
    minpoint2point=min(distToNearestPoint2Sets(poly1,poly2));
    if Options.ClusterDistanceMethod==2     %Distance between nearest two points
        distance=minpoint2point;
        return
    end
    ch1=convhull(poly1(:,1), poly1(:,2));
    ch2=convhull(poly2(:,1), poly2(:,2));
    line2point=zeros(1, (numel(ch1)-1)*size(poly2,1));
    for l=2:numel(ch1)      %compute all distances from each line of poly1 to each point of poly1
        L=[poly1(ch1(l-1),1), poly1(ch1(l-1),2); poly1(ch1(l),1), poly1(ch1(l),2)];
        for p=1:size(poly2,1)
            P=poly2(p,:);
            line2point((l-2)*size(poly2,1)+p)=distancePointLine(P,L);            
        end
    end
    minline2point=min(line2point);
    
    point2line=zeros(1, (numel(ch2)-1)*size(poly1,1));
    for l=2:numel(ch2)      %compute all distances from each line of poly2 to each point of poly1
        L=[poly2(ch2(l-1),1), poly2(ch2(l-1),2); poly2(ch2(l),1), poly2(ch2(l),2)];
        for p=1:size(poly1,1)
            P=poly1(p,:);
            point2line((l-2)*size(poly1,1)+p)=distancePointLine(P,L);
        end
    end
    minpoint2line=min(point2line);
    
    distance=min([minline2point,minpoint2line,minpoint2point]);
   
end

    