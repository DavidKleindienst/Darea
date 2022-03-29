function [zoomSize, positionZoom] = calcZoom(oldZoomSize,hZoom,hZoomText,zoomRectangle,maxZoom)
%% Calculates the new size and position of the zoom rectangle
% Ensures that the rectangle is not larger than allowed
% Input arguments
% oldZoomSize - The current size of the zoom (in nm)
% hZoom - The uicontrol handle for the Edit showing the zoom size
% hZoomText - The uicontrol handle for the Text showing info about the zoom
% zoomRectangle - the handle of the rectangle shown on the image
% maxZoom - The maximum size of the zoom rectangle in nm
% Output arguments:
% zoomSize - the new size of the zoom (in nm)
% positionZoom - the new position of the zoom rectangle

zoomSize=round(str2double(get(hZoom,'String')));
if isnan(zoomSize)
    positionZoom = zoomRectangle.Position;
    zoomSize = oldZoomSize;
    return
end
if zoomSize>maxZoom
    zoomSize=maxZoom;
end

titleZoomText = ['Zoom: ' int2str(zoomSize) 'x' int2str(zoomSize) ' Nanometers.'];
set(hZoomText, 'String', titleZoomText);
positionZoomMovNm = zoomRectangle.Position;
positionZoom=[positionZoomMovNm(1)+oldZoomSize/2-zoomSize/2,positionZoomMovNm(2)+oldZoomSize/2-zoomSize/2, zoomSize, zoomSize];
end

