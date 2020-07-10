function rect = rectFromPoints(points)
%% Given a set of 2D points, gets a rectangle which surrounds them.

% It first finds the segment between the two points separated by a 
% greater distance. Then calculates the rectangle containing all the
% points such that the major side is parallel to this segment. 

% *------X---------------------*
% |                            |
% X----------------------------X
% |    X                       | 
% *----------------------X-----*  

% points: (n,2) matrix with the coordinates of the n points.

% rect: (4,2) matrix with the coordinates of the corners of the rectangle.
%        Points are listed clockwise. 1-2 is always a short side.

num_points = size(points,1);

%% Finds the points which are farest from each other and the line between them.
%   pointR: point in the right side (if there are difference).
%   pointL: point in the left side (if there are difference).
%   lenMajS: Distance between the two points. Lenght of the major side of the rectangle.

lenMajS = 0;
for i=1:num_points-1,
    for j=i+1:num_points,
        dist = sqrt( (points(i,1)-points(j,1))^2 + (points(i,2)-points(j,2))^2 );
        if (dist>lenMajS),
            pointR = points(i,:);
            pointL = points(j,:);
            lenMajS = dist;
        end
    end    
end

% pointR must be the one in the right (for clearliness).
if (pointR(1)<pointL(1)),
    pointAux = pointL;
    pointL = pointR;
    pointR = pointAux;
end

% Finds the line between the two points.
% Y = slope * X + intercept.
slope = (pointL(2)-pointR(2))/(pointL(1)-pointR(1));
intercept = pointL(2)-(pointL(1)*slope);


%% Calculates the rectangle containing the points.
rect = zeros(4,2);

% Is slope is infinity
if isinf(slope),
    if pointL(2)>pointR(2)
        top = pointL(2);
        bottom = pointR(2);
    else
        top = pointR(2);
        bottom = pointL(2);
    end
    
    minX = Inf;
    maxX = -Inf;
    for indP=1:num_points,
        if (points(indP,1)<minX)
            minX = points(indP,1);
        end
        if (points(indP,1)>maxX)
            maxX = points(indP,1);
        end        
    end
    rect = [minX bottom; maxX bottom; maxX top; minX top];
    
% If slope is 0
elseif (slope==0),
    minX = pointL(1);
    maxX = pointR(1);        

    top = -Inf; 
    bottom = Inf;
    for indP=1:num_points,
        if (points(indP,2)<bottom),
            bottom = points(indP,2);
        end
        if points(indP,2)>top,
            top = points(indP,2);
        end
    end
    rect = [minX bottom; minX top; maxX top; maxX bottom];
 
% Any other case  (slope!=0) && (slope !=Inf)   
else
    distAbove=0;
    distBelow=0;
    for i=1:num_points,
        % Does not consider the points in the diagonal.
        if ((points(i,1)==pointR(1) && points(i,2)==pointR(2)) || (points(i,1)==pointL(1) && points(i,2)==pointL(2)))
            continue
        end    
        % Determines the relativa position of the point.
        point = points(i,:);
        yline = slope * point(1) + intercept;
        if (yline<point(2)),
            up=true;
        elseif (yline>point(2)),
            up=false;
        end  
        % Calculates the distance with the main line.
        x0 = point(1); y0 = point(2);
        term1 = (x0 + slope*y0 - slope*intercept) / (slope^2 + 1) - x0;
        term2 = slope * (x0 + slope*y0 - slope*intercept) / (slope^2 + 1) + (intercept-y0);
        dist = sqrt(term1^2 + term2^2);
        % Updates the distances.
        if ((up==true)&&(dist>distAbove)),
            distAbove = dist;
        elseif ((up==false)&&(dist>distBelow)),
            distBelow = dist;
        end
    end       
 
    % Calculates the rectangle
	perp_slope = -(1/slope);
    if (perp_slope<0)
        sign = -1;
    else
        sign = 1;
    end
    % First line (pointL) 
    perp_inter =  pointL(2)-(pointL(1)*perp_slope);
    rect(1,1) = pointL(1)+sign*sqrt(distAbove^2/(1+(perp_slope)^2));
    rect(1,2) = perp_slope*rect(1,1)+perp_inter;
    rect(2,1) = pointL(1)+sign*-1*sqrt(distBelow^2/(1+(perp_slope)^2));
    rect(2,2) = perp_slope*rect(2,1)+perp_inter;
    % Second line (pointR) 
    perp_inter =  pointR(2)-(pointR(1)*perp_slope);
    rect(4,1) = pointR(1)+sign*sqrt(distAbove^2/(1+(perp_slope)^2));
    rect(4,2) = perp_slope*rect(4,1)+perp_inter;
    rect(3,1) = pointR(1)+sign*-1*sqrt(distBelow^2/(1+(perp_slope)^2));
    rect(3,2) = perp_slope*rect(3,1)+perp_inter;  
end    

end

