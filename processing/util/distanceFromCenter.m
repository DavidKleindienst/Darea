function distance = distanceFromCenter(points,boundary)
% Computes distance of each point from Center of Gravity of boundary
warning('off','MATLAB:polyshape:repairedBySimplify');
if size(points,1) <1
    distance = NaN;
    return
end

%Compute center of gravity
polygon=polyshape(boundary(:,1), boundary(:,2));
[x, y]=centroid(polygon);

distance=pdist2(points,[x,y]);

end

