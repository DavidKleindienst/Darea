
function [defaults,useless,position,selAngle]=demarcate(pathImage, imageName, scale, selAngle, ~, autocontrast, defaults, ~, useless, position)
%% Menu for manual demarcation of the region of interest

    %Automatically taken images with serialEM can be from multiple angles
    if ~isnan(selAngle)
        [~,angles]=readMdoc([fullfile(pathImage,imageName) '.mdoc']);
        fullimageName=fullfile(pathImage,imageName);
        
        if selAngle
            angle = selAngle;
            image = readAndConvertImage(fullimageName,angle);
        else
            % selAngle is 0, indicating that no angle has yet been selected
            % so pick a middle one for display
            angle = round(numel(angles)/2);
            image = readAndConvertImage(fullimageName,angle);
        end
    else
        fullimageName=[fullfile(pathImage,imageName) '.tif'];
        image = readAndConvertImage(fullimageName);
    end
    modImageName=[fullfile(pathImage,imageName) '_mod.tif'];
    modImage=NaN;
    
    
    if ~isa(image, 'uint16')
        msgbox('This image is not 16 bit and cannot be processed');
        return
    end
    if autocontrast
        image=imadjust(image);
    end
    imR=imref2d(size(image),scale,scale);
    if isfile(modImageName)
        modImage=readAndConvertImage(modImageName);
    end
    [filteredImages, compCenter] = loadSavedImage(image,modImage);
    if ~isnan(compCenter)
        currentImage=2;
        compCenter=compCenter.*scale;
    else
        currentImage=1;
    end
    %% Image measures 
    % Main image
    

    %% Variables to store Results
    polygonPoints=[];
    polygonMarks=[]; polygonZoomMarks=[];
    polygonLines=[]; polygonZoomLines=[];
    modifyPoly=[];
    selectedComponent=NaN; componentOverlay=[]; componentZoomOverlay=[];
    measurePoints=[]; measureLines=[];
    handdraw=NaN;

    %% Gui measures and points
    title='Darea - Area demarcation';
    [mainFigure, axesImage,axesZoom, hZoomText, hZoom, gridXPx, gridYPx,hPosX,hPosY] = make2PanelWindow(title,image,imageName,scale,0.72,0.8,1, defaults, @createZoom, @moveZoomToPos,'off');
    hRotate=uicontrol('Style','pushbutton', 'String', 'Rotate', 'Callback', @rotateImg, 'Position', [gridXPx(3)-70 gridYPx(2)+15 60 25], ...
                    'Tooltipstring', 'Rotate image 90° clockwise');
       
    set(mainFigure, 'CloseRequestFcn', @closeCallBack);% Manages figure closing.
    set(mainFigure, 'windowbuttonupfcn',@imageMouseReleased);
    set(mainFigure, 'KeyReleaseFcn', @keyRelease);
    

    %% Create buttons
    
    filterTT=sprintf('Select displayed component\nYou can also use up and down arrow keys');
    uicontrol('Style','text','String', 'Select Component', 'FontWeight', 'bold', 'Position', [gridXPx(1)+5 125 80 25],'Tooltipstring', filterTT);
    
    hFilterDropdown=uicontrol('Style', 'popup', 'Callback', @selectFilter, 'Position', [gridXPx(1)+90 118 140 35], 'Tooltipstring', filterTT);
    updateFilterDropdown();
    
    hChangeOriginal=uicontrol('Style','Checkbox', 'String', 'Change left Image', 'Position', [gridXPx(1)+240 132 180 25], 'Value', defaults.changeLeftImage, 'Callback', @changeLeftValue);
    
    hMeasure=uicontrol('Style','togglebutton','String','Measure Distance', 'Position', [gridXPx(1)+5 80 100 25],'Callback',@buttonActivation);
    
    hFreehand=uicontrol('Style','togglebutton','String', 'Freehand [f]', 'Position', [gridXPx(1)+110 80 100 25], 'Callback', @freehand, 'Tooltipstring', 'Demarcate using free hand drawing');
    ver=version('-release');
    if str2double(ver(1:end-1))<2019 && ~strcmp(ver, '2018b')
        set(hFreehand, 'Tooltipstring','Requires Matlab 2018b or later');
        jButton= findjobj(hFreehand);
        set(jButton,'Enabled',false);
    end
    hAdd=uicontrol('Style','togglebutton', 'String', 'Add [a]', 'Tooltipstring', 'Activate this to draw a polygon to add to component', 'Position', [gridXPx(2)-100 105 40 25], 'Callback', @buttonActivation);
    hRemove=uicontrol('Style','togglebutton', 'String', 'Remove [r]', 'Tooltipstring', 'Activate this to draw a polygon to remove from the component', 'Position', [gridXPx(2)-55 105 60 25], 'Callback', @buttonActivation);
    hTrim=uicontrol('Style','togglebutton', 'String', 'Trim [t]', 'Tooltipstring', 'Activate this to Trim away unneccessary parts of the connected components', 'Position', [gridXPx(2)-100 80 40 25], 'Callback', @buttonActivation);
    hConnect=uicontrol('Style','togglebutton', 'String', 'Connect', 'Tooltipstring', 'Activate this to connect several connected components', 'Position', [gridXPx(2)-55 80 60 25], 'Callback', @buttonActivation);
    
    hNewComponent=uicontrol('Style', 'pushbutton', 'String', 'New Component from Selection [n]', 'Position', [gridXPx(2)-310 20 190 25], ...
                        'Callback', @makeNewComp, 'Tooltipstring', sprintf('Makes a new component from current selection\nThis is equivalent to saving, closing and reopening image'));
                    
    
    
    hClose=uicontrol('Style','pushbutton','String','Close Structure', 'Position', [gridXPx(2)-150 105 90 25], 'Callback', @closeStructure);
    hHoles=uicontrol('Style','pushbutton','String','Fill Holes', 'Position', [gridXPx(2)-55 105 60 25], 'Callback', @fillHoles,...
        'Tooltipstring',sprintf('Close holes in the structure'));
    
    hBrightnessText=uicontrol('Style','text','String','BackgroundBrightness','Position' ,[gridXPx(1)+5 40 105 25]);
    hBrightness=uicontrol('Style','slider','Min',0,'Max',1,'Value',defaults.BackgroundBrightness,'Position',[gridXPx(1)+125 40 150 25],'Callback',@changeBgBrightness);
    uicontrol('Style', 'pushbutton', 'String', 'Clear','Units','pixels','Position', [gridXPx(2)-80 20 80 25],'Tooltipstring','Delete all marks and points','Callback',@clear);   
    hdelLastPoint=uicontrol('Style', 'pushbutton', 'String', 'Remove last Point','Units','pixels','Position', [gridXPx(2)+5 20 100 25],'Tooltipstring','Delete last Point','Callback',@deleteLastPoint);   
    uicontrol('Style', 'pushbutton', 'String', 'Close [c]','Units','pixels','Position',[gridXPx(4)-80 20 80 25],'Tooltipstring','Closes the application','Callback',@closeCallBack); 
    saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save [s]','Units','pixels','Position',[gridXPx(4)-170 20 80 25],'Tooltipstring','Save particle locations in a file','Callback',@save); 
    
    if ~isnan(selAngle)
        angleString = compose('%g',angles); %Convert to cell array of strings
        angleTT = sprintf('Select the stage angle at which the Image was taken\nYou can also use left and right arrow keys.');
        uicontrol('Style', 'text', 'String','Angle', 'Tooltipstring', angleTT, 'Position', [gridXPx(2)+140 30 60 15]);
        hSelectAngle = uicontrol('Style', 'popup', 'Callback', @changeAngle, 'Tooltipstring', angleTT, ...
            'String', angleString, 'Position', [gridXPx(2)+200 20 80 25], 'Value', angle);

    end
    %%Visibility of things depending on displayed Filter
    visibleOnPolygon=[hdelLastPoint, hNewComponent,hFreehand];
    visibleOnSelect=[hTrim,hConnect,hAdd,hRemove,hdelLastPoint,hBrightnessText,hBrightness,hFreehand];
    visibleOnFinalize=[hHoles,hClose,hBrightnessText,hBrightness, hNewComponent];
    allowHotkeys=[hFilterDropdown,hHoles,hClose,hdelLastPoint,hNewComponent,hBrightness,hTrim,hConnect,hAdd,hRemove,saveButton,hFreehand,hMeasure,hChangeOriginal];
    for i=1:numel(allowHotkeys)
        set(allowHotkeys(i),'KeyReleaseFcn', @keyRelease);
    end
    
    
    % Whether the information in the file has been updated.
    updated = true;
    rotated=0;


    %% Loads the main image
    handleImage = imshow(filteredImages{currentImage}.image, imR, 'Parent', axesImage);    
    set(handleImage,'ButtonDownFcn',@imageClickCallBack);

    %% Creates the zoom 
    positionZoomNm = [imR.ImageExtentInWorldX/2-defaults.zoomImageSizeNm/2 imR.ImageExtentInWorldY/2-defaults.zoomImageSizeNm/2 defaults.zoomImageSizeNm defaults.zoomImageSizeNm];

    % Declares these elements so that they can be accesed in the whole function
    zoomRectangleDashed=[];
    zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                'Deletable', false, 'FixedAspectRatio',true);
    xl=get(axesImage,'XLim');
    yl=get(axesImage,'YLim');
    set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);

    imageZoom = [];
    handleZoom = [];

    createZoom(NaN,NaN); %If default Zoom is larger than image, this will take care of it
    changeUI();
    set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable
    if ~isnan(position)
        %Put figure to the position the user had with the image before
        set(mainFigure, 'Position', position);
    end
    
    if ~isnan(compCenter)
        positionZoomNm(1) = compCenter(1,1)-defaults.zoomImageSizeNm/2;
        positionZoomNm(2) = compCenter(1,2)-defaults.zoomImageSizeNm/2; 
        setZoom();
    end
    if currentImage~=1
        hFilterDropdown.Value=currentImage;
    end
        
    %% Waits for the main figure to return results.
    set(mainFigure, 'Visible', 'on');
    waitfor(mainFigure);  
    
    function makeNewComp(~,~)
        idx=numel(filteredImages)+1;
        filteredImages{idx}.name='New Component';
        filteredImages{idx}.fct='select';
        if strcmp(filteredImages{currentImage}.fct,'polygon') && numel(polygonPoints)>=3
            compIm=poly2mask(polygonPoints(:,1)./scale,polygonPoints(:,2)./scale,size(image,1),size(image,2));
            polygonPoints=[];
        elseif strcmp(filteredImages{currentImage}.fct,'finalize')
            compIm=filteredImages{currentImage}.compImage;
        end
        filteredImages{idx}.compImage=compIm;
        filteredImages{idx}.image=image;
        filteredImages{idx}.image(compIm==0)=image(compIm==0)*defaults.BackgroundBrightness;
        updateFilterDropdown();
        set(hFilterDropdown,'Value', idx)
        selectFilter();
        updated=false;
    end
    function [filteredImages, componentCenter] = loadSavedImage(image,modImage)
        %componentCenter shows the center of the demarcated component
        %or is NaN if no component or more than one component have been saved

        filteredImages={};

        filteredImages{1}.image=image;
        filteredImages{1}.name='Original Image';
        filteredImages{1}.fct='polygon';
        %image=rgb2gray(image);
        if ~isnan(modImage)
            modComponents=zeros(size(modImage));
            modComponents(modImage==65535)=1;
            modComponents = bwareaopen(modComponents,20);
            modComponents = imopen(modComponents, strel('diamond',2));
            modComponents = abs(modComponents-1); %Invert binary image
        %     modComponents=imbinarize(modImage,0.97); 
        %     modComponents=abs(bwareaopen(modComponents,100)-1); %Abs -1 because of dark foreground
            demarc=image;
            demarc(modComponents==0)=image(modComponents==0)*defaults.BackgroundBrightness;

            filteredImages{2}.image=demarc;
            filteredImages{2}.name='saved Component';
            filteredImages{2}.fct='select';
            filteredImages{2}.compImage=modComponents;
            
            [~, n]=bwlabel(modComponents);
            if n ~= 1
                %More than 1 selection, set to NaN
                componentCenter=NaN;
            else
                %Get component center
                props=regionprops(modComponents);
                componentCenter=props.Centroid;
            end
        else
            componentCenter=NaN;
        end
    end
    function closeStructure(~,~)
        close_radius=round(defaults.closeRadius/scale);
        filteredImages{currentImage}.compImage=imclose(filteredImages{currentImage}.compImage,strel('disk',close_radius));
        filteredImages{currentImage}.image=image;
        filteredImages{currentImage}.image(filteredImages{currentImage}.compImage==0)=filteredImages{currentImage}.image(filteredImages{currentImage}.compImage==0)*defaults.BackgroundBrightness;
        redrawImage();
    end

    function fillHoles(~,~)
        filteredImages{currentImage}.compImage=imfill(filteredImages{currentImage}.compImage,'holes');
        filteredImages{currentImage}.image=image;
        filteredImages{currentImage}.image(filteredImages{currentImage}.compImage==0)=filteredImages{currentImage}.image(filteredImages{currentImage}.compImage==0)*defaults.BackgroundBrightness;
        redrawImage();
    end
    
    function buttonActivation(hOb,~)
        %Ensures only one Button is activated at the same time
        if get(hOb,'Value')==1
            buttongrp=[hTrim,hConnect,hAdd,hRemove];
            buttongrp(buttongrp==hOb)=[];
            for b=1:numel(buttongrp)
                set(buttongrp(b), 'Value', 0);
            end
        end
        %Wenn button is deactivated, save changes
        if get(hOb,'Value')==0
            if hOb==hConnect && ~any(any(isnan(selectedComponent)))
                filteredImages{currentImage}=getConnect(filteredImages{currentImage},image,selectedComponent,defaults);
                selectedComponent=NaN;
                redrawImage();
                updated=false;
            elseif hOb==hTrim && size(modifyPoly,1)>1
                filteredImages{currentImage}=getTrimming(filteredImages{currentImage},image,round(modifyPoly./scale),defaults);
                emptyModifyPoly();
                updated=false;
            elseif (hOb==hAdd || hOb==hRemove) && size(modifyPoly,1)>2
                if hOb==hAdd; action='add'; else; action='remove'; end
                filteredImages{currentImage}=changeComponent(filteredImages{currentImage},image,round(modifyPoly./scale),action,defaults);
                emptyModifyPoly();
                updated=false;
            elseif hOb==hMeasure && size(measurePoints,1)>0
                measurePoints=[];
                measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
            end
        end
    end

    function emptyModifyPoly()
        if ~isempty(polygonPoints) & size(modifyPoly)==size(polygonPoints) & modifyPoly==polygonPoints
            polygonPoints=[];
        end
        modifyPoly=[];
        redrawImage();
    end

    function moveZoomToPos(hOb,~)
        number=str2double(hOb.String);
        if isnan(number)
            %Illegal Entry, will be reset to previous number by setZoom
            setZoom();
            return;
        end
        if hOb==hPosX
            positionZoomNm(1)=number;
        elseif hOb==hPosY
            positionZoomNm(2)=number;
        end
        setZoom();
    end

    function createZoom(~,~)
        [defaults.zoomImageSizeNm, positionZoomNm] = calcZoom(defaults.zoomImageSizeNm,hZoom,hZoomText,zoomRectangleMov,min(size(image))*scale);
        set(hZoom, 'String', int2str(defaults.zoomImageSizeNm))
        redrawImage();
    end
        
    
    function selectFilter(~,~)
        if currentImage==hFilterDropdown.Value
            return;
        end
        
        if strcmp(filteredImages{currentImage}.fct,'polygon') && ...
                strcmp(filteredImages{hFilterDropdown.Value}.fct,'select') && ...
                isempty(modifyPoly) && ~isempty(polygonPoints)
            %Transfer polygonselction to new filter, if it may be useful
            modifyPoly=polygonPoints;
        end
                
        
        currentImage=hFilterDropdown.Value;
        redrawImage();
        changeUI();
    end

    function changeAngle(~,~)
        if angle == hSelectAngle.Value
            return
        end
        angle=hSelectAngle.Value;
        image = readAndConvertImage(fullimageName,angle);
        if autocontrast
            image=imadjust(image);
        end
        filteredImages{1}.image=image;
        for fil=2:numel(filteredImages)
            if isfield(filteredImages{fil}, 'compImage')
                filteredImages{fil}.image=image;
                c=filteredImages{fil}.compImage;
                filteredImages{fil}.image(c==0)=filteredImages{fil}.image(c==0)*defaults.BackgroundBrightness;
            end
        end
        redrawImage();
    end

    function changeUI()
        %Change UI visibility based on allowed operations on imageType
        if strcmp(filteredImages{currentImage}.fct,'polygon')
            set(visibleOnSelect,'Visible', 'Off');
            set(visibleOnFinalize,'Visible', 'Off');
            set(visibleOnPolygon,'Visible', 'On');
        elseif strcmp(filteredImages{currentImage}.fct,'select')
            set(visibleOnFinalize,'Visible', 'Off');
            set(visibleOnPolygon,'Visible', 'Off');
            set(visibleOnSelect,'Visible', 'On');

        elseif strcmp(filteredImages{currentImage}.fct,'finalize')
            set(visibleOnSelect,'Visible', 'Off');
            set(visibleOnPolygon,'Visible', 'Off');
            set(visibleOnFinalize,'Visible', 'On');
        end
    end
    

    function redrawImage()
        if get(hChangeOriginal,'Value')
            if ~isempty(componentOverlay);delete(componentOverlay(1));componentOverlay=[];end
            handleImage = imshow(filteredImages{currentImage}.image, imR, 'Parent', axesImage);    
            set(handleImage,'ButtonDownFcn',@imageClickCallBack);
            if ~isnan(selectedComponent)
                redImg=cat(3,ones(size(image)),zeros(size(image)),zeros(size(image)));
                visibility=zeros(size(selectedComponent));
                visibility(selectedComponent==1)=0.4;
                hold(axesImage, 'on');
                componentOverlay(1)=imshow(redImg,'parent',axesImage);
                set(componentOverlay(1),'AlphaData',visibility,'ButtonDownFcn',@imageClickCallBack);
                hold(axesImage, 'off');
            end
            zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                         'Deletable', false, 'FixedAspectRatio',true);
            xl=get(axesImage,'XLim');
            yl=get(axesImage,'YLim');
            set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);
        end
        setZoom();
    end
    
    %% Mouse released callback
    function imageMouseReleased(~ , ~)
        % If the current object is the main image.
        if (gca==axesImage)
            % If the coordinates of the rectangle have changed, changes the zoom
            positionZoomMovNm = zoomRectangleMov.Position;
            
            if positionZoomNm(1) ~= positionZoomMovNm(1) || positionZoomNm(2) ~= positionZoomMovNm(2) || positionZoomMovNm(3) ~= defaults.zoomImageSizeNm
                positionZoomNm(1) = positionZoomMovNm(1);
                positionZoomNm(2) = positionZoomMovNm(2);
                if positionZoomMovNm(3) ~= defaults.zoomImageSizeNm
                    defaults.zoomImageSizeNm=positionZoomMovNm(3);
                    set(hZoom, 'String', int2str(defaults.zoomImageSizeNm))
                    createZoom();
                    return;
                end
                setZoom();  
            end
        end
    end
    
    %% Click on the image.
    function imageClickCallBack(~ , ~)
       coordinates = get(axesImage,'CurrentPoint');
       positionZoomNm(1) = coordinates(1,1)-defaults.zoomImageSizeNm/2;
       positionZoomNm(2) = coordinates(1,2)-defaults.zoomImageSizeNm/2; 
       setZoom();    
    end


    function rotateImg(~, ~)
        %% rotate image 90° clockwise
        
        P=[1+imR.ImageExtentInWorldX/2, 1+imR.ImageExtentInWorldY/2];    %center point of image
        positionZoomNm(1:2)=rotatePoints(P,zoomRectangleMov.Vertices(2,:));
        image=imrotate(image,-90);
        imR=imref2d(size(image),scale,scale);
       
        for im=1:numel(filteredImages)
            if isfield(filteredImages{im}, 'image')
                filteredImages{im}.image=imrotate(filteredImages{im}.image,-90);
            end
            if isfield(filteredImages{im}, 'compImage')
                filteredImages{im}.compImage=imrotate(filteredImages{im}.compImage,-90);
            end
        end
        polygonPoints=rotatePoints(P,polygonPoints);
        measurePoints=[];
        delete(zoomRectangleMov);
        zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                'Deletable', false, 'FixedAspectRatio',true);
        xl=get(axesImage,'XLim');
        yl=get(axesImage,'YLim');
        set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);
        
        rotated=rotated+90;
        chngOrig=hChangeOriginal.Value;
        hChangeOriginal.Value=1;
        redrawImage();
        hChangeOriginal.Value=chngOrig;
        %createZoom(0,0);
    end

    function freehand(~,~)
        if get(hFreehand, 'Value')==1
            %Draw freehand polygon
            
            %First delete any drawn polygons
            if get(hMeasure, 'Value')==1
                set(hMeasure, 'Value', 0);
            end
            if strcmp(filteredImages{currentImage}.fct,'polygon')
                polygonPoints=[];
            elseif strcmp(filteredImages{currentImage}.fct,'select') ...
                        && (get(hTrim,'Value')==1 || get(hAdd,'Value')==1 || get(hRemove,'Value')==1)
                modifyPoly=[];
            end
            drawPolygon();
            %Let user do freehand draw
            handdraw=drawfreehand(axesZoom);
        elseif isa(handdraw, 'images.roi.Freehand')
            
            handdraw.Visible='off';
            if strcmp(filteredImages{currentImage}.fct,'polygon')
                polygonPoints=DouglasPeucker(handdraw.Position,scale);
            elseif strcmp(filteredImages{currentImage}.fct,'select')                     
                modifyPoly=DouglasPeucker(handdraw.Position,scale);
            end
            %Now accept polygon selection
            
            drawPolygon();
            delete(handdraw);
            handdraw=NaN;
            updated=false;
        end   
    end

    %% Click event over the right image. Marks a dot.
    function zoomClickCallback(~ , ~)
        if size(measurePoints,1)>1
           %If measurement is shown, clear it
           measurePoints=[];
           measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        end
        
        % Gets the coordinates
        coordinates = get(axesZoom,'CurrentPoint');
        coordinates = coordinates(1,1:2);
        
        if get(hMeasure, 'Value')==1
            measurePoints=[measurePoints; coordinates];
            measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        elseif strcmp(filteredImages{currentImage}.fct,'polygon')
            polygonPoints=[polygonPoints; coordinates];
            drawPolygon();
            updated=false;
        elseif strcmp(filteredImages{currentImage}.fct,'select')
            if get(hTrim,'Value')==1 || get(hAdd,'Value')==1 || get(hRemove,'Value')==1
                modifyPoly=[modifyPoly; coordinates];
                drawPolygon();
            elseif get(hConnect, 'Value')==1
                if isnan(selectedComponent)
                    selectedComponent=getComponent(filteredImages{currentImage}.compImage, round(coordinates./scale));
                    redrawImage();
                else
                    c=getComponent(filteredImages{currentImage}.compImage, round(coordinates./scale));
                    if isnan(c); return; end
                    selectedComponent=fuse2components(selectedComponent,c);
                    redrawImage();
                end
            else
                selectComponent(coordinates);
                updated=false;
            end
        end
        updated=false;
    end % zoomClickCallback
    
    function selectComponent(coordinates)        
        allNames=cell(1,numel(filteredImages));
        for i=1:numel(filteredImages)
            allNames{i}=filteredImages{i}.name;
        end
        idx=find(ismember(allNames,'Single Component'));
        if isempty(idx)
            idx=numel(filteredImages)+1;
            filteredImages{idx}.name='Single Component';
            filteredImages{idx}.fct='finalize';
        end
        c=getComponent(filteredImages{currentImage}.compImage, round(coordinates./scale));
        if isnan(c)
            %If user did not click on component, don't do anything
            return
        end
        filteredImages{idx}.compImage=c;
        filteredImages{idx}.image=image;
        filteredImages{idx}.image(c==0)=filteredImages{idx}.image(c==0)*defaults.BackgroundBrightness;
        
        updateFilterDropdown();
        set(hFilterDropdown, 'Value',idx);
        selectFilter();
        
    end
    
    function updateFilterDropdown()
        filterddList=cell(1,numel(filteredImages));
        for i=1:numel(filteredImages)
            filterddList{i}=filteredImages{i}.name;
        end
        set(hFilterDropdown, 'String', filterddList);
    end

    function drawPolygon()
        %First remove already drawn polygons
        drawtypes=[polygonMarks,polygonZoomMarks,polygonLines, polygonZoomLines];
        for drawtype=1:numel(drawtypes)
            drawing=drawtypes(drawtype);
            for x=1:numel(drawing)
               mark=drawing(x);
               delete(mark)
            end 
        end
        if strcmp(filteredImages{currentImage}.fct,'polygon')
            polygon=polygonPoints;
            color='blue';
        elseif strcmp(filteredImages{currentImage}.fct,'select') %&& (get(hTrim,'Value')==1 || get(hAdd,'Value')==1 || get(hRemove,'Value')==1)
            polygon=modifyPoly;
            color='white';
        else
            polygonZoomMarks=[]; polygonMarks=[]; polygonLines=[]; polygonZoomLines=[];
            return
        end
        polysize=size(polygon,1);
        polygonZoomMarks=gobjects(1,polysize); polygonMarks=gobjects(1,polysize);
        if polysize<2
            polygonLines=[]; polygonZoomLines=[];
        else
            polygonLines=gobjects(1,polysize-1); polygonZoomLines=gobjects(1,polysize-1);
        end
        for x=1:polysize
            coordX=polygon(x,1);
            coordY=polygon(x,2);
            polygonMarks(x) =  drawCircle (coordX, coordY, 6, '-', 1, color, true, axesImage);
            polygonZoomMarks(x) = drawCircle (coordX, coordY, 2, '-', 2, color, true, axesZoom);
            
            if x>1
                coordPrevX=polygon(x-1,1);
                coordPrevY=polygon(x-1,2);
                
                polygonLines(x-1)=line([coordPrevX coordX],[coordPrevY coordY], 'LineWidth', 1.2, 'Parent', axesImage,'color',color);
                polygonZoomLines(x-1)=line([coordPrevX coordX],[coordPrevY coordY], 'LineWidth', 1.2, 'Parent', axesZoom,'color',color);
            end
        end
        cond1=strcmp(filteredImages{currentImage}.fct,'polygon');
        cond2=strcmp(filteredImages{currentImage}.fct,'select') && (get(hAdd,'Value')==1 || get(hRemove,'Value')==1);
        if  (cond1 || cond2) && size(polygon,1)>2
            coordPrevX=polygon(1,1);
            coordPrevY=polygon(1,2);

            mark=line([coordPrevX coordX],[coordPrevY coordY],'LineStyle','--', 'LineWidth', 1.2, 'Parent', axesImage,'color',color);
            polygonLines=[polygonLines mark];
            mark=line([coordPrevX coordX],[coordPrevY coordY],'LineStyle','--', 'LineWidth', 1, 'Parent', axesZoom,'color',color);
            set(mark,'ButtonDownFcn',@zoomClickCallback);
            polygonZoomLines=[polygonZoomLines mark];
        end
    end

    %% Sets the zoom
    function setZoom()
        if ~isempty(componentZoomOverlay);delete(componentZoomOverlay(1));componentZoomOverlay=[];end
        if hFreehand.Value==1
            if isa(handdraw, 'images.roi.Freehand')
                delete(handdraw);
            end
            clear('handdraw');
            handdraw=NaN;
            hFreehand.Value=0;
        end
        % Deletes the old rectangle and creates the new one.
        delete(zoomRectangleDashed);
        [zoomRectangleDashed, imageZoom, zoomR, positionZoomPx, positionZoomNm]=getNewZoomPosition(positionZoomNm,zoomRectangleMov,imR,defaults.zoomImageSizeNm,axesImage,filteredImages{currentImage}.image,scale);
        hPosX.String=num2str(positionZoomNm(1));
        hPosY.String=num2str(positionZoomNm(2));
        set(mainFigure,'CurrentAxes',axesZoom);
        handleZoom = imshow(imageZoom,zoomR);
        set(handleZoom,'ButtonDownFcn',@zoomClickCallback);
        drawPolygon();
        measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        if ~isnan(selectedComponent)
                redImg=cat(3,ones(size(imageZoom)),zeros(size(imageZoom)),zeros(size(imageZoom)));
                visibility=imcrop(selectedComponent,positionZoomPx);
                vis=zeros(size(visibility));
                vis(visibility==1)=0.4;
                hold(axesZoom, 'on');
                componentZoomOverlay(1)=imshow(redImg, zoomR, 'parent',axesZoom);
                set(componentZoomOverlay(1),'AlphaData',vis,'ButtonDownFcn',@zoomClickCallback);
                hold(axesZoom, 'off');
        end        
    end
    
    function keyRelease(~,key)
        switch key.Key
            case 'backspace'
                deleteLastPoint();
            case 'f'
                if strcmp(filteredImages{currentImage}.fct, 'select') || strcmp(filteredImages{currentImage}.fct, 'polygon')
                    hFreehand.Value=abs(hFreehand.Value-1);
                    freehand();
                end
            case 's'
                save();
            case 'c'
                closeCallBack();
            case 'r'
                if strcmp(filteredImages{currentImage}.fct, 'select')
                    hRemove.Value=abs(hRemove.Value-1);
                    buttonActivation(hRemove,0)
                end
            case 'n'
                if strcmp(filteredImages{currentImage}.fct, 'finalize') || strcmp(filteredImages{currentImage}.fct, 'polygon')
                    makeNewComp(0,0);
                end
            case 'a'
                if strcmp(filteredImages{currentImage}.fct, 'select')
                    hAdd.Value=abs(hAdd.Value-1);
                    buttonActivation(hAdd,0)
                end
            case 't'
                if strcmp(filteredImages{currentImage}.fct, 'select')
                    hTrim.Value=abs(hTrim.Value-1);
                    buttonActivation(hTrim,0)
                end
            case 'rightarrow'   %change angle
                if ~isnan(selAngle) %Only if image has angles
                    hSelectAngle.Value = min(hSelectAngle.Value + 1, numel(hSelectAngle.String));
                    changeAngle(0,0);
                end
            case 'leftarrow'    %change angle
                if ~isnan(selAngle) %Only if image has angles
                    hSelectAngle.Value = max(hSelectAngle.Value - 1, 1);
                    changeAngle(0,0);
                end
            case 'downarrow'
                hFilterDropdown.Value = min(hFilterDropdown.Value + 1, numel(hFilterDropdown.String));
                selectFilter();
            case 'uparrow'
                hFilterDropdown.Value = max(hFilterDropdown.Value - 1, 1);
                selectFilter();
        end
    end

    function deleteLastPoint(~,~)
        
        if strcmp(filteredImages{currentImage}.fct,'polygon') && numel(polygonPoints)>0
            polygonPoints=polygonPoints(1:end-1,:);
            drawPolygon();
            updated=false;
        elseif strcmp(filteredImages{currentImage}.fct,'select')  && ~isempty(modifyPoly)
            modifyPoly=modifyPoly(1:end-1,:);
            drawPolygon();
        end
      
    end

    function clear(~,~)
        
        if strcmp(filteredImages{currentImage}.fct,'polygon') && numel(polygonPoints)>0
            polygonPoints=[];
            drawPolygon();
        elseif strcmp(filteredImages{currentImage}.fct,'select') && get(hConnect,'Value')==1 && ~any(any(isnan(selectedComponent)))
            selectedComponent=NaN;
            redrawImage();
        elseif strcmp(filteredImages{currentImage}.fct,'select') && ~isempty(modifyPoly)
            modifyPoly=[];
            drawPolygon();
        end
        if isa(handdraw,'images.roi.Freehand')
            delete(handdraw);
            handdraw=NaN;
            if get(hFreehand,'Value')==1
                handdraw=drawfreehand(axesZoom);
            end
        end
            
    end

    
    %% Writes the information in the provided file
    function save(~, ~)
        if ~isnan(selAngle) && selAngle ~= angle
            %angle changed, will be saved to config by openImages.m
            %after closing demarcate menu
            selAngle=angle;
        end
        save_Img=1;
        if strcmp(filteredImages{currentImage}.fct,'polygon') && numel(polygonPoints)>=3
            mask=poly2mask(polygonPoints(:,1)./scale,polygonPoints(:,2)./scale,size(image,1),size(image,2));
            outImage=image;
            outImage(mask==0)=65535;
            outImage(mask==1)=1337;
        elseif strcmp(filteredImages{currentImage}.fct,'select') || strcmp(filteredImages{currentImage}.fct,'finalize')
            outImage=image;
            outImage(filteredImages{currentImage}.compImage==0)=65535;
            outImage(filteredImages{currentImage}.compImage==1)=1337;
        else
            %Nothing to be saved
            save_Img=0;
        end
        if save_Img
            imwrite(outImage,fullfile(pathImage, [imageName '_mod.tif']));
        end
        if rotated
            %If image has been rotated, rotate image files
            rotateSavedImage(fullfile(pathImage,imageName),scale,rotated,~save_Img,true);
        end
        updated=true;
    end % save

    function changeBgBrightness(hOb,~)
        defaults.BackgroundBrightness=get(hOb,'Value');
        filteredImages=changeBackgroundBrightness(image,filteredImages,defaults);
        redrawImage();
    end
    function changeLeftValue(hOb,~)
        defaults.changeLeftImage=hOb.Value;
    end
        
    %% Closes the figure.
    function closeCallBack ( ~ , ~)
        position=get(mainFigure,'Position');
        closeCB(updated, @save);
    end 
end

