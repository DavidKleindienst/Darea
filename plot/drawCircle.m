%% drawCircle
% Draws a circle in the current (active) figure.
%    
%       drawCircle(x, y, radius, style, width, color, filled, axes)
%
% Example
%
%       drawCircle ( 0, 0, 5, '-', 3, 'red', true)

%% Parameters
%
% *x, y*: Coordinates of the center.
%
% *radius*: Radius of the circle.
%
% *style*: Type of line. Example: '--'. (see rectangle - LineStyle)
% 
% *width*: Width of the line.
%
% *color*: Color of the line. Example: 'red'. 
%
% *filled*: If true, the circle is filled with the specified color.
%
% *axes*: Axes where the circle is drawn into (optional)

%% Returns
%
% *ref*: A reference to the graphical object.

%% Errors
%
% * Unknown line styles or colors.
%
% * Unexisting axes.

%% Implementation
function ref = drawCircle(x, y, radius, style, width, color, filled, axes)

% Determines the axes the circle must be drawn into
if nargin<8
    axes = gca;
end

% Uses the rectangle to draw the circle.
ref = rectangle('Position',[x-radius, y-radius, radius*2, radius*2], ...
                'Curvature',[1 1],'LineStyle', style, 'LineWidth', width, 'EdgeColor', color, 'Parent', axes);
 
% If filled is true, fills the circle.            
if (filled)
    ref.FaceColor = color;
end

