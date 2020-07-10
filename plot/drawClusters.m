%
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria - Klosterneuburg - Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%  
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%  
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

function handles=drawClusters(points, clusters, type, lineStyle, lineWidth, lineColor, axes)
%% This function allows marking clusters in the current figure. It does not use scale. 

% points:   (n,2) vector containing the coordinates of the points.
% clusters: (n,1) vector containing the cluster each point belongs to.
% type: Type of mark
%       - Ellipse: Ellipse.
%       - Rectangle: Rectangle.
%       - ConvexHull: Convex Hull.
% lineStyle: Style of the line surrounding the clusters.
% lineWidth: Width of the line surrounding the clusters.
% lineColor: Color of the line surrounding the clusters.

if nargin<7
    axes=gca;
end

% Marks the clusters
numClusters = max(clusters);
lowerType = lower(type);
handles=[];
% The mark is the convex hull.
if strcmp(lowerType,'convexhull')
    for idxCluster=1:numClusters
        handles=[handles, drawCHFromPoints(points(clusters==idxCluster,:),lineStyle, lineWidth,lineColor,axes)];
    end
% The mark is a rectangle.    
elseif strcmp(lowerType,'rectangle')
    for idxCluster=1:numClusters
        handles=[handles, drawRectFromPoints(points(clusters==idxCluster,:),lineStyle, lineWidth,lineColor,axes)];
    end
% The mark is an ellipse.
else
    for idxCluster=1:numClusters
        handles=[handles, drawEllipseFromPoints(points(clusters==idxCluster,:),lineStyle, lineWidth,lineColor,axes)];
    end
end
        
            

