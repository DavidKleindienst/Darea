function measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom)
%DRAWMEASURELINES Summary of this function goes here
%   Detailed explanation goes here
if size(measurePoints,1)==0
    for x=1:numel(measureLines)
        mark=measureLines(x);
        delete(mark);
    end
    measureLines=[];
elseif size(measurePoints,1)==1
    coordinates=measurePoints(1,1:2);
    mark=drawCircle (coordinates(1), coordinates(2), 1.5, '-', 1, 'green', true, axesZoom);
    measureLines=[measureLines mark];
elseif size(measurePoints,1)==2
    coordinates=measurePoints(2,1:2);
    mark=drawCircle (coordinates(1), coordinates(2), 1.5, '-', 1, 'green', true, axesZoom);
    measureLines=[measureLines mark];
    coordPrev=measurePoints(1,1:2);
    mark=line([coordPrev(1) coordinates(1)],[coordPrev(2) coordinates(2)], 'LineWidth', 0.8, 'Parent', axesZoom,'color','green');
    measureLines=[measureLines mark];
    distance=round(pdist2(measurePoints(1,:),measurePoints(2,:)),2);
    textPosition=(coordPrev+coordinates)./2;
    mark=text(textPosition(1)+3,textPosition(2)+10,[num2str(distance) ' nm'],'color','green','FontWeight','bold','Parent', axesZoom);
    measureLines=[measureLines mark];
    for x=1:numel(measureLines)
        %allow clicking on the lines
        set(measureLines(x), 'ButtonDownFcn',@zoomClickCallback);
    end
    set(hMeasure,'Value',0);
end
end

