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

function h=drawCHFromPoints( points, LineStyle, LineWidth, Color, ax)

%% Given a set of 2D points, draws the convex hull.

% points: (n,2) matrix with the coordinates of the n points.
% lineStyle: Type of line, example: 'w--'
% lineWidth: Width of the line.
% Color: Color of the line.
if nargin <5
    ax=gca;
end
prev_axes=gca;
axes(ax);
ch = convhull(points(:,1), points(:,2));
hold on
h=plot(points(ch,1),points(ch,2),'LineStyle', LineStyle, 'LineWidth', LineWidth, 'Color',Color);
hold off
axes(prev_axes);
end

