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

function h=drawRect(rect,  LineStyle, LineWidth, Color, axes )
%% Draws a rectangle in the current (active) figure.
% Contiguous coordinates in rect must be sides of the rectangle.

% rect: (4,2) matrix with the coordinates of the corners of the rectangle.
% lineStyle: Type of line, example: 'w--'
% lineWidth: Width of the line.
% Color: Color of the line.
if nargin <5
    axes=gca;
end
h=gobjects(1,4);
h(1)=line(axes,[rect(1,1) rect(2,1)],[rect(1,2) rect(2,2)], 'LineStyle', LineStyle, 'Color', Color, 'LineWidth', LineWidth);
h(2)=line(axes,[rect(2,1) rect(3,1)],[rect(2,2) rect(3,2)], 'LineStyle', LineStyle, 'Color', Color, 'LineWidth', LineWidth);
h(3)=line(axes,[rect(3,1) rect(4,1)],[rect(3,2) rect(4,2)], 'LineStyle', LineStyle, 'Color', Color, 'LineWidth', LineWidth);
h(4)=line(axes,[rect(4,1) rect(1,1)],[rect(4,2) rect(1,2)], 'LineStyle', LineStyle, 'Color', Color, 'LineWidth', LineWidth);

end

