function [posXWindow,posYWindow,figureWidthPx,figureHeightPx,dispImageWidthPx,dispImageHeightPx,zoomImageSidePx,imsizechange,zoomsizechange,gridXPx,gridYPx] = getGuiDimensions(imSize,percentScreenUsed,imshrinkfactor,zoomshrinkfactor)
%GETGUIDIMENSIONS Summary of this function goes here
%   Detailed explanation goes here

imageHeightPx=imSize(1);
imageWidthPx=imSize(2);

 %% Gui measures and points
screenSize = get(0,'Screensize');
% Calculates ratios image/screen 
ratioImScreen = [imageHeightPx/screenSize(4)  imageWidthPx/screenSize(3)];
% Takes the size of the screen for the dimmension with the biggest ratio
if ratioImScreen(1)>ratioImScreen(2)
    dispImageHeightPx = screenSize(4) * percentScreenUsed; 
    dispImageWidthPx = dispImageHeightPx/imageHeightPx * imageWidthPx;
else
    dispImageWidthPx = screenSize(3) * percentScreenUsed; 
    dispImageHeightPx = dispImageWidthPx/imageWidthPx * imageHeightPx;
end    
% The section amplified is a square whose size is the height of the image.
zoomImageSidePx = dispImageHeightPx*zoomshrinkfactor;    
% Size of the main figure. 
figureWidthPx = dispImageWidthPx*imshrinkfactor + zoomImageSidePx + 120;
figureHeightPx = dispImageHeightPx + 120;
% Position
posXWindow = screenSize(3)/2 - figureWidthPx/2;
posYWindow = screenSize(4)/2 - figureHeightPx/2;
%Resizing of image so there's space below for control panel

imsizechange=dispImageHeightPx-(dispImageHeightPx*imshrinkfactor);
zoomsizechange=dispImageHeightPx-(dispImageHeightPx*zoomshrinkfactor);
gridYPx = [60, 60+dispImageHeightPx]; 
dispImageHeightPx=dispImageHeightPx*imshrinkfactor;
dispImageWidthPx=dispImageWidthPx*imshrinkfactor;
% Reference points used to place the components in the figure.
gridXPx = [20, 20+dispImageWidthPx, 20+dispImageWidthPx+80, 20+dispImageWidthPx+80+zoomImageSidePx];

end