function [zoomSize, positionZoom] = calcZoom(oldZoomSize,hZoom,hZoomText,zoomRectangle,maxZoom)
%CALCZOOM Summary of this function goes here
%   Detailed explanation goes here
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

