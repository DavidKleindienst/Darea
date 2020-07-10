function mask = createLineMask(sizeMask,x1,y1,x2,y2 )
%CREATELINEMASK Summary of this function goes here
%   Detailed explanation goes here
mask=zeros(sizeMask);
% Distance (in pixels) between the two endpoints
nPoints = ceil(sqrt((x2 - x1).^2 + (y2 - y1).^2)) +1;

% Determine x and y locations along the line
xvalues = round(linspace(x1, x2, nPoints));
yvalues = round(linspace(y1, y2, nPoints));

% Replace the relevant values within the mask
mask(sub2ind(size(mask), xvalues, yvalues)) = 1;
%broaden line to 3px width
mask=imdilate(mask,strel('disk',1));

end

