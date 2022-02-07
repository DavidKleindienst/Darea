function distance = distanceFromCenter(points,boundary)
% Computes distance of each point from Center of Gravity of boundary
warning('off','MATLAB:polyshape:repairedBySimplify');
if size(points,1) <1
    distance = NaN;
    return
end
if iscell(boundary)
    %get list of centroids c
    % distance = min(pdist2(points,centroids),[],2))
    distances = zeros(numel(points),1);
    for b = 1:numel(boundary)
        polygon=polyshape(boundary{b}(:,1), boundary{b}(:,2));
        % ToDo: Decide whether this boundary sourrounds a demarcated region
        % If Donut shaped demarcated region, only outer boundary should be further processed
        [x, y]=centroid(polygon);
        distance=pdist2(points,[x,y]);
        pointsContained=isinterior(polygon,points(:,1), points(:,2));
        distances(pointsContained) = distance(pointsContained);
    end
else
    %Compute center of gravity
    polygon=polyshape(boundary(:,1), boundary(:,2));
    [x, y]=centroid(polygon);

    distance=pdist2(points,[x,y]);
end


end

