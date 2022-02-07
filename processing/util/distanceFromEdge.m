function distanceEdge=distanceFromEdge(points, boundary)
% Computes the distance of points from Edge boundary
% distance > 0: Point within boundaries
% distance < 0: Point outside of boundaries
if size(points,1) <1
    distanceEdge = NaN;
    return
end
if iscell(boundary)
    distances = [];
    for b = 1:numel(boundary)
        try
            distances = [distances, p_poly_dist(points(:,1),points(:,2),boundary{b}(:,1),boundary{b}(:,2))];
        catch e
            points
            boundary
            b
            rethrow(e);
        end
        
        distanceEdge = max(distances,[],2);
    end
    
else
    try
        distanceEdge=p_poly_dist(points(:,1),points(:,2),boundary(:,1),boundary(:,2));
    catch e
        points
        boundary
        rethrow(e);
    end
end
distanceEdge = distanceEdge*-1;

end