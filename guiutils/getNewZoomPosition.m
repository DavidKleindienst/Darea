function [zoomRectangle, imageZoom, zoomR, positionZoomPx, positionZoomNm] = getNewZoomPosition(positionZoomNm,zoomRectangleMov,imR,zoomSize,axesImage,image,scale)
%GETNEWZOOMPOSITION Summary of this function goes here
%   Detailed explanation goes here

 % No part of the rectangle can be outside the image.
positionZoomNm=keepZoomInLimits(positionZoomNm,imR.XWorldLimits,imR.YWorldLimits,zoomSize);
% Deletes the old rectangle and creates the new one.

zoomRectangle = rectangle('Position', positionZoomNm,'EdgeColor','white','LineWidth',3,'Parent',axesImage,'LineStyle','--');
positionZoomMovPx = zoomRectangleMov.Position;
if (positionZoomNm(1) ~= positionZoomMovPx(1) || positionZoomNm(2) ~= positionZoomMovPx(2))
    zoomRectangleMov.Position=positionZoomNm;
end
% It is scaled to final scale so that dot can be detected.
[xPx, yPx]=worldToIntrinsic(imR,positionZoomNm(1),positionZoomNm(2));
positionZoomPx=[xPx,yPx,positionZoomNm(3)./scale,positionZoomNm(4)./scale];

imageZoom = imcrop(image,positionZoomPx);
zoomR=imref2d(size(imageZoom),scale,scale);
%Move worldlimits so you can just draw particles in Nm without
%worrying where the zoom is.
zoomR.XWorldLimits=zoomR.XWorldLimits+positionZoomNm(1);
zoomR.YWorldLimits=zoomR.YWorldLimits+positionZoomNm(2);
end

