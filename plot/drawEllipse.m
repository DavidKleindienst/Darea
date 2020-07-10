%
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
%
% This method is based on the methor proposed by Trung Huy Duong in
% http://trunghuyduong.blogspot.com.es/2010/10/contents-input-parameters-of-2-d.html
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

function h=drawEllipse(x0, y0, majR, minR, angle,  LineStyle, LineWidth, Color, axes)
%% Draws an ellipse in the current (active) figure.

% x0, y0: Coordinates of the center.
% majR, minR: Major and minor radius.
% angle: Orientation of the eclipse.

% lineStyle: Type of line, example: 'w--'
% lineWidth: Width of the line.
% Color: Color of the line.
if nargin <9
    axes=gca;
end
    numPoints = 200;

    %% Generates the ellipse.
    theta = linspace(0,2*pi,numPoints);
    ptEllipse(1,:) = majR*cos(theta);
    ptEllipse(2,:) = minR*sin(theta);
    
    %% Rotates the ellipse.
    angle = angle*pi/180; % deg->rad 
    % Rotation matrix: 
    Q = [cos(angle) -sin(angle)
         sin(angle)  cos(angle)];
    ptEllipse = Q*ptEllipse;

    %% Moves it to the desired location.
    ptEllipse(1,:) = ptEllipse(1,:) + x0;
    ptEllipse(2,:) = ptEllipse(2,:) + y0;
    
    %% Plots
    h=plot(axes,ptEllipse(1,:),ptEllipse(2,:), 'LineStyle', LineStyle,'LineWidth', LineWidth, 'Color', Color);

end

