function [mainFigure, axesImage,axesZoom, hZoomText, hZoom, gridXPx, gridYPx,hX,hY] = make2PanelWindow(title, image,imageName,scale,percentScreenUsed,imshrinkfactor,zoomshrinkfactor, defaults,createZoomFcn,moveZoomFcn,visible)
% Creates a main Figure with 2 Panels
% One panel for original Image, one for Zoom

[posXWindow,posYWindow,figureWidthPx,figureHeightPx,dispImageWidthPx,dispImageHeightPx,zoomImageSidePx,imsizechange,zoomsizechange,gridXPx,gridYPx] ...
        = getGuiDimensions(size(image),percentScreenUsed,imshrinkfactor,zoomshrinkfactor); 

[imageHeightPx, imageWidthPx] = size(image);
imageHeightNm = imageHeightPx .* scale;
imageWidthNm = imageWidthPx .* scale;
if nargin>=11
    mainFigure = figure('NumberTitle','off','Units', 'pixels', 'Position',[posXWindow posYWindow figureWidthPx, figureHeightPx], 'Visible',visible);
else
    mainFigure = figure('NumberTitle','off','Units', 'pixels', 'Position',[posXWindow posYWindow figureWidthPx, figureHeightPx]);
end
% Title.
if ~isempty(imageName)
    set(mainFigure, 'Name', [title ': ' imageName]); 
else
    set(mainFigure, 'Name', title);
end
set(mainFigure, 'menubar', 'none'); % No menu bar.

% Image
panelImage = uipanel('Units','pixels','Position',[gridXPx(1) gridYPx(1)+imsizechange dispImageWidthPx dispImageHeightPx]);
axesImage = axes('parent', panelImage, 'Position', [0 0 1 1]);
titleImageText = ['Image:  ' int2str(imageHeightNm) 'x' int2str(imageWidthNm) ' Nanometers.       Zoom Position:    X:'];
uicontrol('Style','text','String', titleImageText,'FontSize',11, 'FontWeight','bold','Unit','pixels', 'Position', [gridXPx(1) gridYPx(2)+15 dispImageWidthPx*2/3 20]);
hX=uicontrol('Style', 'Edit','Position', [gridXPx(1)+dispImageWidthPx*2/3 gridYPx(2)+15 45 20], 'Callback',moveZoomFcn);
uicontrol('Style','Text', 'FontSize',11, 'FontWeight','bold','String', 'Y:', 'Position', [gridXPx(1)+dispImageWidthPx*2/3+50 gridYPx(2)+15 20 20]);
hY=uicontrol('Style', 'Edit','Position', [gridXPx(1)+dispImageWidthPx*2/3+70 gridYPx(2)+15 45 20], 'Callback', moveZoomFcn);

% Zoom
panelZoom = uipanel('Units','pixels','Position',[gridXPx(3) gridYPx(1)+zoomsizechange zoomImageSidePx zoomImageSidePx]);
axesZoom = axes('parent', panelZoom,'Position', [0 0 1 1]);    

titleZoomText = ['Zoom: ' int2str(defaults.zoomImageSizeNm) 'x' int2str(defaults.zoomImageSizeNm) ' Nanometers.'];
hZoomText=uicontrol('Style','text','String', titleZoomText,'FontSize',11, 'FontWeight','bold','Unit','pixels', 'Position', [gridXPx(3) gridYPx(2)+15 zoomImageSidePx/2 20]);
uicontrol('Style','text','String','Set Zoom', 'FontWeight','bold', 'Position', [gridXPx(3)+zoomImageSidePx/2 gridYPx(2)+15 55 20]);
hZoom=uicontrol('Style','edit','String',int2str(defaults.zoomImageSizeNm),'Position',[gridXPx(3)+zoomImageSidePx/2+57 gridYPx(2)+18 33 20], 'Callback', createZoomFcn);
uicontrol('Style','text', 'String', 'nm', 'FontWeight','bold', 'Position', [gridXPx(3)+zoomImageSidePx/2+90 gridYPx(2)+15 20 20]);

end

