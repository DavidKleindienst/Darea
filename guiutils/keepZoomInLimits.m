function positionZoom= keepZoomInLimits(positionZoom,XLimits,YLimits,zoomSize)

if positionZoom(1)<XLimits(1), positionZoom(1) = XLimits(1); end
if positionZoom(1)>XLimits(2)-zoomSize, positionZoom(1) = XLimits(2)-zoomSize; end
if positionZoom(2)<YLimits(1), positionZoom(2) = YLimits(1); end
if positionZoom(2)>YLimits(2)-zoomSize, positionZoom(2) = YLimits(2)-zoomSize; end    

end

