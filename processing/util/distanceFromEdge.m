function distanceEdge=distanceFromEdge(points, boundary)
% Computes the distance of points from Edge boundary
% distance > 0: Point within boundaries
% distance < 0: Point outside of boundaries
if size(points,1) <1
    distanceEdge = NaN;
    return
end
try
    distanceEdge=p_poly_dist(points(:,1),points(:,2),boundary(:,1),boundary(:,2));
catch
    points
    boundary
    distanceEdge=p_poly_dist(points(:,1),points(:,2),boundary(:,1),boundary(:,2));
end
distanceEdge=distanceEdge*-1;
end