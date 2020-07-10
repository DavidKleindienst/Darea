function rect = minRectFromPoints(points)

num_points = size(points,1);

scatter(points(:,1), points(:,2));
hold on;
pointR = points(1,:);
pointL = points(2,:);
            
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

% Is slope is infinity or cero
if isinf(slope) || (slope==0),
    maxX = max(points(:,1));
    minX = min(points(:,1));
    maxY = max(points(:,2));
    minY = min(points(:,2));
    rect = [minX minY; minX maxY; maxX maxY; maxX minY];
    

% Any other case  (slope!=0) && (slope !=Inf)   
else
    disp(slope)
     maxDistAbove=0;
     maxDistBelow=0;
     maxDistLeft = 0;
     maxDistRight = 0;
    for i=1:num_points,
         % Does not consider the reference points.
         if ((points(i,1)==pointR(1) && points(i,2)==pointR(2)) || (points(i,1)==pointL(1) && points(i,2)==pointL(2)))
             continue
         end    
         % Determines the relative position of the point up/down (the line)
         point = points(i,:);
         yline = slope * point(1) + intercept;
         if (yline<point(2)),
             up=true;
         elseif (yline>point(2)),
             up=false;
         end  
         
         % Calculates the distance with the main line.
         x0 = point(1); % Coordinates of the point.
         y0 = point(2);
%         term1 = (x0 + slope*y0 - slope*intercept) / (slope^2 + 1) - x0;
%         term2 = slope * (x0 + slope*y0 - slope*intercept) / (slope^2 + 1) + (intercept-y0);
%         dist = sqrt(term1^2 + term2^2);
%         % Updates the distances.
%         if ((up==true)&&(dist>distAbove)),
%             distAbove = dist;
%         elseif ((up==false)&&(dist>distBelow)),
%             distBelow = dist;
%         end
	 end       
%  
%     % Calculates the rectangle
% 	perp_slope = -(1/slope);
%     if (perp_slope<0)
%         sign = -1;
%     else
%         sign = 1;
%     end
%     % First line (pointL) 
%     perp_inter =  pointL(2)-(pointL(1)*perp_slope);
%     rect(1,1) = pointL(1)+sign*sqrt(distAbove^2/(1+(perp_slope)^2));
%     rect(1,2) = perp_slope*rect(1,1)+perp_inter;
%     rect(2,1) = pointL(1)+sign*-1*sqrt(distBelow^2/(1+(perp_slope)^2));
%     rect(2,2) = perp_slope*rect(2,1)+perp_inter;
%     % Second line (pointR) 
%     perp_inter =  pointR(2)-(pointR(1)*perp_slope);
%     rect(4,1) = pointR(1)+sign*sqrt(distAbove^2/(1+(perp_slope)^2));
%     rect(4,2) = perp_slope*rect(4,1)+perp_inter;
%     rect(3,1) = pointR(1)+sign*-1*sqrt(distBelow^2/(1+(perp_slope)^2));
%     rect(3,2) = perp_slope*rect(3,1)+perp_inter;  
end    

end

