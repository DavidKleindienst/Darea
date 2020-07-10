function defaults=preEmb(pathImage, seriesName, scale, defaults, ~)
    %% For debugging only
    showGhosts=0;

    %% First get list of all images in that series
    filelist=dir([pathImage,seriesName]);
    imageNames={};
    for f=1:size(filelist,1)
        fname=filelist(f).name;
        if numel(fname)>=5 && strcmp(fname(end-3:end),'.tif')==1
            imageNames{end+1}=[pathImage '/' seriesName fname];
        end
    end
    %Load all the images
    images=cell(1,numel(imageNames));
    imR=cell(1,numel(imageNames));
    for i=1:numel(imageNames)
        images{i}=imread(imageNames{i});
        imR{i}=imref2d(size(images{i}),scale,scale);
    end
    if exist([pathImage,seriesName, 'alignment.mat'],'file')==2
        load([pathImage,seriesName, 'alignment.mat']);
        applyAlignments();
    else
        alignments=cell(1,numel(imageNames));
    end
    alignPoints=cell(1,numel(imageNames));
    [globalXLim,globalYLim]=getGlobalLimits(imR);
    
    zoomR=NaN;
    
    currentImage=1;
    %% Image measures 
    % Main image
    [imageHeightPx, imageWidthPx] = size(images{currentImage});
    imageHeightNm = imageHeightPx .* scale;
    imageWidthNm = imageWidthPx .* scale;
     %% Gui measures and points
    [posXWindow,posYWindow,figureWidthPx,figureHeightPx,dispImageWidthPx,dispImageHeightPx,zoomImageSidePx,imsizechange,gridXPx,gridYPx] = getGuiDimensions(size(images{currentImage}),0.74,0.8,1); 
    
    %% GUI
    mainFigure = figure('NumberTitle','off','Units', 'pixels', 'Position',[posXWindow posYWindow figureWidthPx, figureHeightPx]);
    % Title.

    set(mainFigure, 'Name', 'Preembedding');
    set(mainFigure, 'menubar', 'none'); % No menu bar.
    set(mainFigure,'resize','off'); % Prevents the figure from resizing (it is almost maximized).
    set(mainFigure, 'CloseRequestFcn', @closeCallBack);% Manages figure closing.
    set(mainFigure, 'windowbuttonupfcn',@imageMouseReleased);
    % Image
    panelImage = uipanel('Units','pixels','Position',[gridXPx(1) gridYPx(1)+imsizechange dispImageWidthPx dispImageHeightPx]);
    axesImage = axes('parent', panelImage, 'Position', [0 0 1 1],'Color',[0 0 0]);
	titleImageText = ['Image:  ' int2str(imageHeightNm) 'x' int2str(imageWidthNm) ' Nanometers. (Drag rectangle to zoom)'];
	uicontrol('Style','text','String', titleImageText,'FontSize',11, 'FontWeight','bold','Unit','pixels', 'Position', [gridXPx(1) gridYPx(2)+15 dispImageWidthPx 20]);
    % Zoom
    panelZoom = uipanel('Units','pixels','Position',[gridXPx(3) gridYPx(1) zoomImageSidePx zoomImageSidePx]);
	axesZoom = axes('parent', panelZoom,'Position', [0 0 1 1],'Color',[0 0 0]);    

    titleZoomText = ['Zoom: ' int2str(defaults.zoomImageSizeNm) 'x' int2str(defaults.zoomImageSizeNm) ' Nanometers.'];
	hZoomText=uicontrol('Style','text','String', titleZoomText,'FontSize',11, 'FontWeight','bold','Unit','pixels', 'Position', [gridXPx(3) gridYPx(2)+15 zoomImageSidePx/2 20]);
    uicontrol('Style','text','String','Set Zoom', 'FontWeight','bold', 'Position', [gridXPx(3)+zoomImageSidePx/2 gridYPx(2)+15 55 20]);
    hZoom=uicontrol('Style','edit','String',int2str(defaults.zoomImageSizeNm),'Position',[gridXPx(3)+zoomImageSidePx/2+57 gridYPx(2)+18 33 20], 'Callback', @createZoom);
    uicontrol('Style','text', 'String', 'nm', 'FontWeight','bold', 'Position', [gridXPx(3)+zoomImageSidePx/2+90 gridYPx(2)+15 20 20]);
    
    %% Create buttons
    hImLeft=uicontrol('Style','pushbutton','String','<','Position', [round((gridXPx(1)+gridXPx(2))/2)-13 140 26 25],'Callback',@(~,~)changeImage(-1), 'Enable','Off');
    hImRight=uicontrol('Style','pushbutton','String','>','Position', [round((gridXPx(1)+gridXPx(2))/2)+13 140 26 25],'Callback',@(~,~)changeImage(1));

    hMeasure=uicontrol('Style','togglebutton','String','Measure Distance', 'Position', [gridXPx(1)+5 80 100 25]);
    
    hManual=uicontrol('Style','togglebutton','String','Manual Alignment', 'Position', [gridXPx(2)-90 100 90 25], 'Callback', @buttonActivation);
    
    uicontrol('Style', 'pushbutton', 'String', 'Undo Alignments','Units','pixels','Position', [gridXPx(2)-210 20 100 25],'Tooltipstring','Undo All Alignments','Callback',@undoAlignments);   
    uicontrol('Style', 'pushbutton', 'String', 'Clear All','Units','pixels','Position', [gridXPx(2)-105 20 100 25],'Tooltipstring','Delete all marks and points','Callback',@clearAll);   
    uicontrol('Style', 'pushbutton', 'String', 'Clear Image','Units','pixels','Position', [gridXPx(2) 20 100 25],'Tooltipstring','Delete marks and points from this image','Callback',@clear);   
    uicontrol('Style', 'pushbutton', 'String', 'Remove last Point','Units','pixels','Position', [gridXPx(2)+105 20 100 25],'Tooltipstring','Delete last Point','Callback',@deleteLastPoint);   
    
    uicontrol('Style', 'pushbutton', 'String', 'Close','Units','pixels','Position',[gridXPx(4)-80 20 80 25],'Tooltipstring','Closes the application','Callback',@closeCallBack); 
    saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save','Units','pixels','Position',[gridXPx(4)-170 20 80 25],'Tooltipstring','Save particle locations in a file','Callback',@saveResults); 

    
    updated = true;
    
    measurePoints=[]; measureLines=[]; alignMarks=[];
    
    
    %% Loads the main image
    handleImage = imshow(images{currentImage}, imR{currentImage}, 'Parent', axesImage);  
    set(handleImage,'ButtonDownFcn',@imageClickCallBack);
    set(axesImage,'XLim',globalXLim);
    set(axesImage,'YLim',globalYLim);
    set(axesImage,'Color',[0 0 0]);
    %% Creates the zoom 
    positionZoomNm = [imR{currentImage}.ImageExtentInWorldX/2-defaults.zoomImageSizeNm/2 imR{currentImage}.ImageExtentInWorldY/2-defaults.zoomImageSizeNm/2 defaults.zoomImageSizeNm defaults.zoomImageSizeNm];
    % Declares these elements so that they can be accesed in the whole function
    zoomRectangle = [];
    zoomRectangleMov = imrect(axesImage, positionZoomNm);
    fcn = makeConstrainToRectFcn('imrect',get(axesImage,'XLim'),get(axesImage,'YLim'));
    setPositionConstraintFcn(zoomRectangleMov,fcn);   
    setResizable(zoomRectangleMov,false);
    imageZoom = [];
    handleZoom = [];

    setZoom();
    %% Waits for the main figure to return results.
    waitfor(mainFigure);  
    function createZoom(~,~)
        oldZoomSize=defaults.zoomImageSizeNm;
        defaults.zoomImageSizeNm=round(str2double(get(hZoom,'String')));
        titleZoomText = ['Zoom: ' int2str(defaults.zoomImageSizeNm) 'x' int2str(defaults.zoomImageSizeNm) ' Nanometers.'];
        set(hZoomText, 'String', titleZoomText);
        positionZoomMovNm = getPosition(zoomRectangleMov);
        positionZoomNm=[positionZoomMovNm(1)+oldZoomSize/2-defaults.zoomImageSizeNm/2,positionZoomMovNm(2)+oldZoomSize/2-defaults.zoomImageSizeNm/2, defaults.zoomImageSizeNm, defaults.zoomImageSizeNm];

        redrawImage();
    end
%% Click on the image.
    function imageClickCallBack(~ , ~)
       coordinates = get(axesImage,'CurrentPoint');
       positionZoomNm(1) = coordinates(1,1)-defaults.zoomImageSizeNm/2;
       positionZoomNm(2) = coordinates(1,2)-defaults.zoomImageSizeNm/2; 
       setZoom();    
    end

    %% Mouse released callback
    function imageMouseReleased(~ , ~)
        % If the current object is the main image.
        if (gca==axesImage)
            % If the coordinates of the rectangle have changed, changes the zoom
            positionZoomMovNm = getPosition(zoomRectangleMov);
            if (positionZoomNm(1) ~= positionZoomMovNm(1) || positionZoomNm(2) ~= positionZoomMovNm(2))
                positionZoomNm(1) = positionZoomMovNm(1);
                positionZoomNm(2) = positionZoomMovNm(2);
                setZoom();  
            end
        end
    end
    
    function buttonActivation(hOb,~)
        if get(hOb,'Value')==0 && strcmp(get(hOb,'String'),'Manual Alignment')
            manualAlignment();
        end
    end
    
    function manualAlignment()
        %% Carries out alignment of images based on manually drawn points
        for img=2:numel(images)
           minimum=min(size(alignPoints{img-1},1),size(alignPoints{img},1));
           if minimum>=2
              tMatrix=findRigidTransform(alignPoints{img-1}(1:minimum,:),alignPoints{img}(1:minimum,:));
              tform=affine2d(tMatrix);
              [images{img},imR{img}]=imwarp(images{img},imR{img},tform);
              alignPoints{img}=transformPointsForward(tform,alignPoints{img});
              %Store alignment Matrix in variable, so it can be saved
              if isempty(alignments{currentImage})
                  alignments{currentImage}=tMatrix;
              else
                  alignments{currentImage}=alignments{currentImage}*tMatrix;
              end
           end
        end
        [globalXLim,globalYLim]=getGlobalLimits(imR);
        redrawImage();
        updated=true;
    end

    %Change to next or previous image of series
    function changeImage(int)
       set(hImLeft,'Enable','On');
       set(hImRight,'Enable','On');
       currentImage=currentImage+int;
       if currentImage<=1
           currentImage=1;
           set(hImLeft,'Enable','Off');
       elseif currentImage>=numel(images)
           currentImage=numel(images);
           set(hImRight,'Enable','Off');
       end
       redrawImage();      
    end


    %% Click event over the right image. Marks a dot.
    function zoomClickCallback(~ , ~)
        if size(measurePoints,1)>1
           %If measurement is shown, clear it
           measurePoints=[];
           drawMeasure();
        end
        
        % Gets the coordinates
        coordinates = get(axesZoom,'CurrentPoint');
        coordinates = coordinates(1,1:2);
        
        if get(hMeasure, 'Value')==1
            measurePoints=[measurePoints; coordinates];
            drawMeasure();
        elseif get(hManual,'Value')==1
            alignPoints{currentImage}=[alignPoints{currentImage};coordinates];
            drawAlignPoints();
        else
            %Try automatic synapse detection
            synMaxX=1500;
            synMaxY=1500;
            synMaxZ=10;
            zMin=currentImage-synMaxZ;
            zMax=currentImage+synMaxZ;
            if zMin<1;zMin=1;end
            if zMax>numel(images);zMax=numel(images);end
            [x, y]=worldToIntrinsic(imR{currentImage},coordinates(1)-synMaxX,coordinates(2)-synMaxY);
            positionCrop=[x,y,2*synMaxX/scale, 2*synMaxY/scale];
                     
            imagesForDetection=cell(1,1+zMax-zMin);
            for i=1:numel(imagesForDetection)
                imagesForDetection{i}=addMissingPixels(imR{i},positionCrop,imcrop(images{i},positionCrop));
            end
            save([pathImage,seriesName, 'test.mat'], 'imagesForDetection');
        end
    end
    
    %% Sets the zoom
    function setZoom()
        % No part of the rectangle can be outside the image.
        positionZoomNm=keepZoomInLimits(positionZoomNm,globalXLim,globalYLim,defaults.zoomImageSizeNm);
        % Deletes the old rectangle and creates the new one.
        delete(zoomRectangle);
        zoomRectangle = rectangle('Position', positionZoomNm,'EdgeColor','white','LineWidth',3,'Parent',axesImage,'LineStyle','--');
        positionZoomMovNm = getPosition(zoomRectangleMov);
        if (positionZoomNm(1) ~= positionZoomMovNm(1) || positionZoomNm(2) ~= positionZoomMovNm(2))
            setPosition(zoomRectangleMov,positionZoomNm);
        end
        [xPx, yPx]=worldToIntrinsic(imR{currentImage},positionZoomNm(1),positionZoomNm(2));
        positionZoomPx=[xPx,yPx,positionZoomNm(3)./scale,positionZoomNm(4)./scale];
        imageZoom = imcrop(images{currentImage},positionZoomPx);
        % If zoomPosition is partially outside of image, add black pixels
        imageZoom=addMissingPixels(imR{currentImage},positionZoomPx,imageZoom);
        
        zoomR=imref2d(size(imageZoom),scale,scale);
        zoomR.XWorldLimits=zoomR.XWorldLimits+positionZoomNm(1);
        zoomR.YWorldLimits=zoomR.YWorldLimits+positionZoomNm(2);
        axes(axesZoom);
        handleZoom = imshow(imageZoom,zoomR);
        set(handleZoom,'ButtonDownFcn',@zoomClickCallback);
        set(axesZoom,'Color',[0 0 0]);
        drawMeasure();
        drawAlignPoints();
    end

    function croppedImage=addMissingPixels(imRef,cropPosition,croppedImage)
        %% If cropPosition is partially outside of image, add black pixels to make it correct size
        if imRef.XIntrinsicLimits(1)>cropPosition(1) 
           px=imRef.XIntrinsicLimits(1)-cropPosition(1);
           missing=zeros(size(croppedImage,1),round(px));
           croppedImage=[missing croppedImage];
        end
        if imRef.XIntrinsicLimits(2)<cropPosition(1)+cropPosition(3)
           px=cropPosition(1)+cropPosition(3)-imRef.XIntrinsicLimits(2);
           missing=zeros(size(croppedImage,1),round(px));
           croppedImage=[croppedImage missing];
        end
        if imRef.YIntrinsicLimits(1)>cropPosition(2)
           px=imRef.YIntrinsicLimits(1)-cropPosition(2);
           missing=zeros(round(px),size(croppedImage,2));
           croppedImage=[missing; croppedImage];
        end
        if imRef.YIntrinsicLimits(2)<cropPosition(2)+cropPosition(4)
           px=cropPosition(2)+cropPosition(4)-imRef.YIntrinsicLimits(2);
           missing=zeros(round(px),size(croppedImage,2));
           croppedImage=[croppedImage;missing];
        end
    end

    function undoAlignments(~,~)
        for i=1:numel(imageNames)
            images{i}=imread(imageNames{i});
            imR{i}=imref2d(size(images{i}),scale,scale);
        end
        alignments=cell(1,numel(imageNames));
        redrawImage();
        updated=true;
    end
    
    function redrawImage()
        handleImage = imshow(images{currentImage},imR{currentImage}, 'Parent', axesImage);
        set(axesImage,'XLim',globalXLim);
        set(axesImage,'YLim',globalYLim);
        set(handleImage,'ButtonDownFcn',@imageClickCallBack);
        zoomRectangleMov = imrect(axesImage, positionZoomNm);
        fcn = makeConstrainToRectFcn('imrect',get(axesImage,'XLim'),get(axesImage,'YLim'));
        setPositionConstraintFcn(zoomRectangleMov,fcn);   
        setResizable(zoomRectangleMov,false);
        setPosition(zoomRectangleMov,positionZoomNm);
        set(axesImage,'Color',[0 0 0]);
        setZoom();
    end

    function drawMeasure()
        if size(measurePoints,1)==0
            for x=1:numel(measureLines)
                mark=measureLines(x);
                delete(mark);
            end
            measureLines=[];
        elseif size(measurePoints,1)==1
            coordinates=measurePoints(1,1:2);
            mark=drawCircle (coordinates(1), coordinates(2), 8, '-', 1, 'green', true, axesZoom);
            measureLines=[measureLines mark];
        elseif size(measurePoints,1)==2
            coordinates=measurePoints(2,1:2);
            mark=drawCircle (coordinates(1), coordinates(2), 8, '-', 1, 'green', true, axesZoom);
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

    function drawAlignPoints()
        %Delete previously drawn Points from Figure
        for x=1:numel(alignMarks)
            mark=alignMarks(x);
            delete(mark);
        end
        alignMarks=[];
        if ~isempty(alignPoints{currentImage})
            
            colors=defaults.particleColor;
            for i=1:size(alignPoints{currentImage},1)
                coordinates=alignPoints{currentImage}(i,:);
                c=mod(i,numel(colors))+1;
                alignMarks=[alignMarks drawCircle(coordinates(1),coordinates(2),15,'-',1,colors{c},true,axesZoom)];
                %,
            end
            
            if showGhosts && currentImage>1 && ~isempty(alignPoints{currentImage-1})
                for i=1:size(alignPoints{currentImage-1},1)
                    coordinates=alignPoints{currentImage-1}(i,:);
                    c=mod(i,numel(colors))+1;
                    alignMarks=[alignMarks drawCircle(coordinates(1),coordinates(2),15,'-',1,colors{c},false,axesZoom)];
                end
            end
        end
        
    end

    function deleteLastPoint(~,~)
        if ~isempty(alignPoints{currentImage})
           alignPoints{currentImage}=alignPoints{currentImage}(1:end-1,:);
           drawAlignPoints();
        end
    end

    function clearAll(~,~)
        measurePoints=[];
        drawMeasure();
        alignPoints=cell(1,numel(imageNames));
        drawAlignPoints();
    end

    function clear(~,~)
        measurePoints=[];
        drawMeasure();
        alignPoints{currentImage}=[];
        drawAlignPoints();
    end

    function [XLim, YLim]=getGlobalLimits(imRefs)
        n=numel(imRefs);
        X1=zeros(n,1);X2=zeros(n,1);Y1=zeros(n,1);Y2=zeros(n,1);
        for i=1:numel(imRefs)
           X1(i)=imRefs{i}.XWorldLimits(1); X2(i)=imRefs{i}.XWorldLimits(2);
           Y1(i)=imRefs{i}.YWorldLimits(1); Y2(i)=imRefs{i}.YWorldLimits(2);
        end
        XLim=[min(X1),max(X2)];
        YLim=[min(Y1),max(Y2)];
    end

    function applyAlignments()
        for i=1:numel(alignments)
            if ~isempty(alignments{i})
                [images{i},imR{i}]=imwarp(images{i},imR{i},affine2d(alignments{i}));
            end
        end
        
    end

    function saveResults(~, ~)
        if updated
            save([pathImage,seriesName, 'alignment.mat'],'alignments');
        end
        updated=false;
    end % save
        
    %% Closes the figure.
    function closeCallBack ( ~ , ~)
        % If everything is updated does not show the dialog.
        if true || updated
            delete(gcf);
            return
        end
        % Construct a questdlg with three options
        choice = questdlg('Do you want to close the figure without saving?', ' Warning', 'Cancel', 'Close without saving','Save and close','Save and close');
        % Handle response
        switch choice
            case 'Cancel' % Do not close.
                return;
            case 'Close without saving' % Closes without saving.
                delete(gcf);
            case 'Save and close' % Saves and closes.
                save();
                delete(gcf);
        end
    end % closeCallback
        
end
