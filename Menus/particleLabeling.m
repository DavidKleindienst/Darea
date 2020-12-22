%% 
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria - Klosterneuburg - Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%  
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%  
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
function [defaults,useless,positionFigure] = particleLabeling(pathImage, imageName, scale, ~, autocontrast, defaults,~, useless,positionFigure)
%% Carries out manual labeling of the dots. The results are written into a file 
% It requires 'imageName'.tif and 'imageName'_mod.tif. The first one must contain
% the original image, whereas the second contains a mask with the discarded area.

% Due to changes in intensity of the dots, the algorithm looks for dots
% with a margin of 40% of the radius, although this parameter can be
% changed.

% The name of the file containing the data is obtained from the name of the image. 
% Ej. If imageName ='img/1' the results are written in 'img/1dots.csv'. 

% pathImage: Path to the image. 
% imageName: Name (without extension) of the image file.
% origScale: Original scale of the image (nm/pixel).

% Aditional input paramaters:
%       'Overwrite': true/false whether to overwrite the existing file or append the results. Default is false.


% centers: Centers of the dots (nanometers)
% radii: radius of the dots (nanometers)
                  
% Ej: [centers radii] = manImageLabeling('img/1', 0.875, 'Overwrite', true); 
    
    % Disables warning for small circles.
    warning('off','images:imfindcircles:warnForSmallRadius');
    warning('off','images:imfindcircles:warnForLargeRadiusRange');
    

    %% Full route to the image
    fullImageName = fullfile(pathImage,imageName);
    %% Reads the image and the mask.
    imageFullName = [fullImageName '.tif'];
    imageSelFullName= [fullImageName '_mod.tif'];
    try
        [maskSection, image] = getBaseImages(imageFullName,imageSelFullName, round(defaults.dilate/scale));
    catch
        fprintf('Image or demarcated Image not found');
        return
    end
    if ~isa(image, 'uint16')
        msgbox('This image is not 16 bit and cannot be processed');
        return
    end
    if autocontrast
        image=imadjust(image);
    end
    imR=imref2d(size(image),scale,scale);
    maskSection = ~maskSection;
    resultsFile = [fullImageName 'dots.csv'];
    
    %% Default parameters.
    for p=1:numel(defaults.particleTypes)
        particleTypes(p).diameter = defaults.particleTypes(p);
        particleTypes(p).color = defaults.particleColor{p+1}; %p+1 because color 1 is for all particles
    end
    currentParticleType = 1;
    particleColor = particleTypes(currentParticleType).color;
    diameterNm = particleTypes(currentParticleType).diameter;
    % The zoom works with this resolution so that circles are detected.
    % Parameters derived
    radiusNm = 0;  
    minRadiusNm=0; maxRadiusNm=0;
    marginRadiusNm = 2; 
    minDistNm = 0;
    updateDiameter();
    
    %%  Structures containing the results
    centersNm = [];
    actRadiiNm = [];
    radiiNm = [];    
    % Structures containing the graphical dots
    particleMarks = [];
    zoomParticleMarks = [];
    zoomDiscardedMarks = [];  
    
    % Structures containing measuring objects
    measurePoints = []; 
    measureLines = [];
    
    %% Image measures 
    % Zoom image
    particleImageSideNm = max(defaults.particleTypes)*2;
    
    %% GUI
    title='Darea - Particle Detection';
    [mainFigure, axesImage,axesZoom,hZoomText, hZoom, gridXPx, gridYPx,hPosX,hPosY] = make2PanelWindow(title,image,imageName,scale,0.7,1,0.74, defaults, @createZoom, @moveZoomToPos);

    hRotate=uicontrol('Style','pushbutton', 'String', 'Rotate [r]', 'Callback', @rotateImg, 'Position', [gridXPx(3)-70 gridYPx(2)+15 60 25], ...
                    'Tooltipstring', 'Rotate image 90° clockwise');
    
    set(mainFigure, 'CloseRequestFcn', @closeCallBack);% Manages figure closing.
    set(mainFigure, 'windowbuttonupfcn',@imageMouseReleased);
    set(mainFigure, 'KeyReleaseFcn',@keyRelease);
    figureColor = get(mainFigure, 'color'); 

    % Create buttons for clearing the image, saving the file, and closing the application.
    hClear=uicontrol('Style', 'pushbutton', 'String', 'Clear','Units','pixels','Position', [gridXPx(2)-80 20 80 25],'Tooltipstring','Delete all marks and points','Callback',@clear);   
    uicontrol('Style', 'pushbutton', 'String', 'Close [c]','Units','pixels','Position',[gridXPx(4)-80 20 80 25],'Tooltipstring','Closes the application','Callback',@closeCallBack); 
    saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save [s]','Units','pixels','Position',[gridXPx(4)-170 20 80 25],'Tooltipstring','Save particle locations in a file','Callback',@save); 
    % The button is only enabled if a file name has been provided.

    
    hMeasure=uicontrol('Style','togglebutton','String','Measure Distance', 'Position', [gridXPx(2)-360 20 100 25],'Callback',@measure);
    % For automatic detection.
    hAutoDetect = uicontrol('Style', 'pushbutton', 'String', 'Automatic detection [d]','Units','pixels','Position', [gridXPx(2)-250 20 150 25],'Tooltipstring','Automatic detection','Callback',@automaticDet);   

    % Toggle marks
    toggleMarksCheckBox = uicontrol('Style', 'checkbox', 'String', 'Show marks [t]','Units','pixels','Position', [gridXPx(1) 20 150 25],'Tooltipstring','Shows/Hides the marks.','Value',1,'Callback',@toogleMarks);   

    
    %  Detected diameter
    uicontrol('Style', 'Text', 'String', 'Last diameter: ','HorizontalAlignment','left','backgroundcolor',figureColor,'Position', [gridXPx(4)-150 gridYPx(1)+101 105 25]);
    dDiameterText =uicontrol('Style', 'Edit', 'String','','Enable','inactive', 'backgroundcolor','white','Position', [gridXPx(4)-50 gridYPx(1)+105 50 25],...
                            'Tooltipstring','Shows the diameter of the last detected particle.','FontWeight','bold');    
    % Sensitivity      
    uicontrol('Style', 'Text', 'String', 'Sensitivity ( 0.5 - 0.99 ):','Position', [gridXPx(3) gridYPx(1)+61 155 25], 'backgroundcolor',figureColor,'HorizontalAlignment','left');      
    sensitivityEdit =uicontrol('Style', 'Edit','backgroundcolor','white','Position', [gridXPx(3)+160 gridYPx(1)+65 50 25],'String',num2str(defaults.sensitivity),...
                               'Tooltipstring','Fixes the sensitivity of the Hough transform. Higher values allow detecting more circles.','Callback',@editSensitivity);                       
    % Margin
    uicontrol('Style', 'Text', 'String', 'Margin ( > 0 Nm):','Position', [gridXPx(3) gridYPx(1)+34 150 25], 'backgroundcolor',figureColor,'HorizontalAlignment','left'); 
    marginEdit =uicontrol('Style', 'Edit', 'backgroundcolor','white','Position', [gridXPx(3)+160 gridYPx(1)+30 50 25],'String',num2str(defaults.marginNm),...
                          'Tooltipstring','Particles which differ from the selected diameter more than this margin are discarded.','Callback',@editMargin); 
    %Classifier
    classifiers=listClassifiers();
    hClassifierText=uicontrol('Style', 'Text', 'String', 'Classifier', 'Position', [gridXPx(3) gridYPx(1) 80 25], 'HorizontalAlignment', 'left');
    defaultId=find(ismember(classifiers,defaults.defaultClassifier));
    hClassifier=uicontrol('Style', 'popup', 'String', classifiers, 'Value', defaultId, 'Position', [gridXPx(3)+80 gridYPx(1) 150 25],'Callback', @setClassifier);
    
    if numel(classifiers)<2
        %Don't show if only one classifier exists
        set(hClassifierText, 'Visible', 'off');
        set(hClassifier, 'Visible', 'off');
    end
    
    hBrightnessText=uicontrol('Style','text','String','BackgroundBrightness','Position' ,[gridXPx(3)-20 25 105 25]);
    hBrightness=uicontrol('Style','slider','Min',0,'Max',1,'Value',defaults.BackgroundBrightness,'Position',[gridXPx(3)+90 25 130 25],'Callback',@changeBgBrightness);

    
    %  Diameter selection
    uicontrol('Style', 'Text', 'String', 'Diameter: ','HorizontalAlignment','left','backgroundcolor',figureColor,'Position', [gridXPx(3) gridYPx(1)+101 150 25]);
    diameterPopup = uicontrol('Style', 'popup', 'Position', [gridXPx(3)+125 gridYPx(1)+105 90 25],'String',' ','backgroundcolor','white','Callback',@editDiameter);                      
    set(diameterPopup,'String',createDiameterPopupOptions());
    set(diameterPopup,'Value',currentParticleType);
    
    ttexact=sprintf('If checked, particle center will be exactly where you click\nOtherwise, particle will be found near click');
    hExact=uicontrol('Style', 'checkbox', 'String','Click exact position [x]', 'Position', [gridXPx(3)+255 gridYPx(1)+46 150 25], ...
                'Tooltipstring', ttexact);
    
    allowHotkeys=[hExact,hClear,hAutoDetect,saveButton,hBrightness,hBrightnessText,diameterPopup];
    set(allowHotkeys, 'KeyReleaseFcn', @keyRelease);
            
    %% Loads the main image
    maskedImage = []; %dummy, will be filled showImage
    showImage();

    
    %% Creates the zoom 
    positionZoomNm = [imR.ImageExtentInWorldX/2-defaults.zoomImageSizeNm/2 imR.ImageExtentInWorldY/2-defaults.zoomImageSizeNm/2 defaults.zoomImageSizeNm defaults.zoomImageSizeNm];
    
    % Declares these elements so that they can be accesed in the whole function
    zoomRectangle = [];
    zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                'Deletable', false, 'FixedAspectRatio',true);
    xl=get(axesImage,'XLim');
    yl=get(axesImage,'YLim');
    set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);
    maskedImageZoom = [];
    handleZoom = [];
    createZoom(NaN,NaN); %If default Zoom is larger than image, this will take care of it
   
    
    % If there is a file, show dots 
    try
        datacsv = csvread(resultsFile);
        % Converts measures to pixels.
        %datacsv(:,1:3) = datacsv(:,1:3)./scale;
        centersNm = datacsv(:,1:2);
        actRadiiNm = datacsv(:,3);
        radiiNm = datacsv(:,4);
        % Draws all particles
        addAllParticleMarks();
    end     
    % Whether the information in the file has been updated.
    updated = true;
    rotated=0;

    %% Sets the zoom 
    setZoom();
    set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable
    if ~isnan(positionFigure)
        %Put figure to the position the user had with the image before
        set(mainFigure, 'Position', positionFigure);
    end
    % Waits for the main figure to return results.
    waitfor(mainFigure);  
    
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

    function showImage()
        maskedImage=image;
        maskedImage(~maskSection) = maskedImage(~maskSection)*defaults.BackgroundBrightness;
        handleImage = imshow(maskedImage, imR, 'Parent', axesImage);    
        set(handleImage,'ButtonDownFcn',@imageClickCallBack);
    end

    function changeBgBrightness(hOb,~)
        defaults.BackgroundBrightness=hOb.Value;
        showImage();
        zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                         'Deletable', false, 'FixedAspectRatio',true);
        setZoom();
    end

    function rotateImg(~, ~)
        %% rotate image 90° clockwise
        

        P=[1+imR.ImageExtentInWorldX/2, 1+imR.ImageExtentInWorldY/2];    %center point of image
        positionZoomNm(1:2)=rotatePoints(P,zoomRectangleMov.Vertices(2,:));
        image=imrotate(image,-90);
        imR=imref2d(size(image),scale,scale);
        maskSection=imrotate(maskSection,-90);
        maskedImage = image;
        maskedImage(~maskSection) = maskedImage(~maskSection)*defaults.BackgroundBrightness;
        handleImage = imshow(maskedImage, imR, 'Parent', axesImage);    
        set(handleImage,'ButtonDownFcn',@imageClickCallBack);
        
        centersNm=rotatePoints(P,centersNm);
        measurePoints=[];
        zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                'Deletable', false, 'FixedAspectRatio',true);
        xl=get(axesImage,'XLim');
        yl=get(axesImage,'YLim');
        set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);
        
        rotated=rotated+90;
        
        clearParticleMarks()
        addAllParticleMarks();
        createZoom(0,0);
    end
    
    function measure(~, ~)
        if get(hMeasure, 'Value')==0 && size(measurePoints,1)>0
            measurePoints=[];
            measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        end
    end

    function createZoom(~,~)
        [defaults.zoomImageSizeNm, positionZoomNm] = calcZoom(defaults.zoomImageSizeNm,hZoom,hZoomText,zoomRectangleMov,min(size(image))*scale);
        set(hZoom, 'String', int2str(defaults.zoomImageSizeNm))
        setZoom();
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
            return;
        end
        
        % Nothing happens when clicking over the discarded areas.
        [c1, c2]=worldToIntrinsic(imR,coordinates(1),coordinates(2));
        if ~maskSection(round(c2),round(c1))
            return
        end
        
        % If marks are deleted, shows them again.
        if ~get(toggleMarksCheckBox,'Value')
            set(toggleMarksCheckBox,'Value',1);
            toogleMarks;
        end

        
        if get(hExact,'Value')==1
            %Dot is put exactly where user clicked
            if addParticle(coordinates(1), coordinates(2), radiusNm, radiusNm, particleColor)
                addMarkToZoom(coordinates(1), coordinates(2),radiusNm,particleColor);
            end
        else
            % Gets the image of the dot
            rectParticle = [coordinates(1)-particleImageSideNm/2 ,coordinates(2)-particleImageSideNm/2,  particleImageSideNm-1, particleImageSideNm-1];
            % Does not allow incomplete rectangles (out of the margin)
            if (rectParticle(1)<1) || (rectParticle(2)<1)
                return
            end
            if ((rectParticle(1)+particleImageSideNm-1)>imR.ImageExtentInWorldX || (rectParticle(2)+particleImageSideNm-1)>imR.ImageExtentInWorldY)
                return
            end

            [xPx, yPx]=worldToIntrinsic(imR,rectParticle(1),rectParticle(2));
            rectParticlePx=[xPx,yPx,rectParticle(3)./scale,rectParticle(4)./scale];

            % Extracts the image of the dot and scales it so that circle can be properly detected.
            imageParticle = imcrop(image, rectParticlePx);
            imParticleR=imref2d(size(imageParticle),scale,scale);

            imParticleR.XWorldLimits=imParticleR.XWorldLimits+rectParticle(1);
            imParticleR.YWorldLimits=imParticleR.YWorldLimits+rectParticle(2);
            % Gets the main circle in the image of the dot.
            [detCenterNm, detActRadiusNm, ~] = getMainCircle(imageParticle, imParticleR, radiusNm, scale, defaults.sensitivity,defaults.marginNm+2); 

            % If some circle has been detected
            if detActRadiusNm>0

                % Resports the diameter of the detected point.
                set(dDiameterText,'String',num2str(detActRadiusNm*2));   

                % Determines if the radius is valid.
                isValidDotRadius = (detActRadiusNm>=minRadiusNm && detActRadiusNm<=maxRadiusNm);
                % If it is valid, it is visualized and added.
                if isValidDotRadius
                      % Add particle returns true if the particle has been added  and false when there is already a particle at a
                      % minimum distance.
                      if addParticle(detCenterNm(1), detCenterNm(2) , radiusNm, detActRadiusNm, particleColor)
                            set(dDiameterText,'Foregroundcolor','black');   
                            addMarkToZoom(detCenterNm(1), detCenterNm(2),radiusNm,particleColor);
                      end
                % Otherwise, they are marked as discarded.                  
                else 
                    set(dDiameterText,'Foregroundcolor','red');
                    addDiscardedMarkToZoom(detCenterNm(1), detCenterNm(2));
                end % isValidDotRadius
            end % actRadiusScaledPx
        end
        
    end % zoomClickCallback

    %% Adds a particle to the main image and results.
    function result = addParticle(coordX, coordY, radius, actRadius,color)
        if numel(centersNm)>0
            distNearest = min(pdist2(centersNm,[coordX,coordY]));
            
            if distNearest < minDistNm
                result = false; % The particle has not been added.
                return 
            end
        end
        centersNm = [centersNm; [coordX coordY]];
        radiiNm = [radiiNm; radius];
        actRadiiNm = [actRadiiNm; actRadius];        
        mark =  drawCircle (coordX, coordY, radius, '-', 2, color, false, axesImage);
        set(mark,'HitTest','off');
        particleMarks = [particleMarks, mark];
        updated = false;
        result = true; % The particle has been added.
        return;
    end

    %% Adds a particle to the zoom.
    function addMarkToZoom(coordX, coordY, radius, color)
        mark =  drawCircle (coordX, coordY, radius, '-', 2, color, false, axesZoom);
        set(mark,'ButtonDownFcn',@deleteParticle);  
        zoomParticleMarks = [zoomParticleMarks; mark];
    end

    %% Adds a discarded mark in zoom
    function addDiscardedMarkToZoom(coordX, coordY)
        mark =  rectangle('Position',[coordX-radiusNm, coordY-radiusNm, 2*radiusNm, 2*radiusNm], 'LineWidth',1, 'FaceColor','white','Parent',axesZoom);
        set(mark,'ButtonDownFcn',@deleteDiscardedMark);  
        zoomDiscardedMarks = [zoomDiscardedMarks; mark];        
    end

    %% Deletes a particle.
    function deleteParticle(objectHandle , ~)
        % Gets the position
        position = get(objectHandle,'Position');
        centerNm = [position(1)+position(3)/2, position(2)+position(4)/2];
        % Removes the particle (only one can be found)
        % indMarkZoom (Maybe it is necessary to delete the particle from the zoomMarks)
        indPart= find(centersNm(:,1)<centerNm(1)+3 & centersNm(:,1)>centerNm(1)-3 & centersNm(:,2)<centerNm(2)+3 & centersNm(:,2)>centerNm(2)-3); 
        centersNm(indPart,:)=[];
        radiiNm(indPart,:) = [];
        actRadiiNm(indPart,:) = [];
        % Removes the mark from both images.
        clearParticleMarks();
        clearZoomParticleMarks();
        addAllParticleMarks();
        addAllZoomParticleMarks();
        updated = false;
    end
   
        
    %% Toogles the marks
    function toogleMarks(~,~)
        checked = get(toggleMarksCheckBox,'Value');
        % If not checked, removes the marks
        if ~checked
            clearParticleMarks();
            clearZoomParticleMarks();
        else
            addAllParticleMarks();
            addAllZoomParticleMarks();
        end
        
    end

    %% Adds all particle marks
    function addAllParticleMarks()
        particleMarks = gobjects(1,numel(radiiNm));
        for typeParticle=1:numel(particleTypes)
            radius = particleTypes(typeParticle).diameter/2;
            color =  particleTypes(typeParticle).color;
            particlesRadius = find(radiiNm==radius);
            for particle=1:numel(particlesRadius)
                particleId = particlesRadius(particle);
                mark =  drawCircle (centersNm(particleId,1), centersNm(particleId,2), radiiNm(particleId), '-', 2, color, false, axesImage);
                set(mark,'HitTest','off');
                particleMarks(particleId)= mark;
            end
        end
    end
    %% Clears all particle marks
    function clearParticleMarks()
        numMarks = numel(particleMarks);
        % Deletes the graphical objects
        for numMark=1:numMarks
            mark = particleMarks(numMark);
            delete(mark);
        end
        % Deletes the references.
        particleMarks = gobjects(numel(radiiNm,1));    
    end

     %% Adds all zoom particle marks
    function addAllZoomParticleMarks()
        if numel(centersNm)>0
            for typeParticle=1:numel(particleTypes)
                radius = particleTypes(typeParticle).diameter/2;
                color =  particleTypes(typeParticle).color;
                centers = find(radiiNm == radius);
                for i=1:size(centers)
                     addMarkToZoom(centersNm(centers(i),1),centersNm(centers(i),2), radius, color);
                end
            end
        end
        
    end
     %% Clears all particle in zoom marks
    function clearZoomParticleMarks()
        numMarks = numel(zoomParticleMarks);
        % Deletes the graphical objects
        for numMark=1:numMarks
            mark = zoomParticleMarks(numMark);
            delete(mark);
        end
        % Deletes the references.
        zoomParticleMarks=[];        
    end

    %% Deletes a discarded mark.
    function deleteDiscardedMark(objectHandle , ~)
         delete(objectHandle)
    end

    %% Clears all discarded marks from the zoom.
    function clearDiscardedMarks()
        numMarks = numel(zoomDiscardedMarks);
        % Deletes the graphical objects
        for numMark=1:numMarks
            mark = zoomDiscardedMarks(numMark);
            delete(mark);
        end
        % Deletes the references.
        zoomDiscardedMarks=[];
    end

    %% Sets the zoom
    function setZoom()
        delete(zoomRectangle);
        [zoomRectangle, ~, zoomR, positionZoomPx,positionZoomNm]=getNewZoomPosition(positionZoomNm,zoomRectangleMov,imR,defaults.zoomImageSizeNm,axesImage,image,scale);
        hPosX.String=num2str(positionZoomNm(1));
        hPosY.String=num2str(positionZoomNm(2));
        maskedImageZoom = imcrop(maskedImage,positionZoomPx);
        axes(axesZoom);
        handleZoom = imshow(maskedImageZoom,zoomR);
        set(handleZoom,'ButtonDownFcn',@zoomClickCallback);

        measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        clearZoomParticleMarks();
        clearDiscardedMarks();
        addAllZoomParticleMarks();
    end

    %% When updating the diameter, some values are affected.
    function updateDiameter()
        % Updates radius measures.
        radiusNm = diameterNm / 2;
        % Updates margins.
        marginRadiusNm =  defaults.marginNm./ 2;
        % Updates the valid range of radius.
        minRadiusNm = radiusNm - marginRadiusNm;
        maxRadiusNm = radiusNm + marginRadiusNm;  
        % Minimimum distance allowed
        minDistNm = 2*radiusNm/3;
    end % updateDiameter

   
    %% Edits the diameter
    function editDiameter(objectHandle , ~)
        oldDiameterNm = diameterNm;
        currentParticleType = objectHandle.Value;
        particleColor =  particleTypes(currentParticleType).color;
        diameterNm = particleTypes(currentParticleType).diameter;
        updateDiameter();
        % If changes, deletes discarded marks.
        if oldDiameterNm ~= diameterNm
            clearDiscardedMarks();
        end

    end
    
    %% Creates the popup options.   
    function diameterPopupOptions = createDiameterPopupOptions()
        numParticles = numel(particleTypes);
        diameterPopupOptions = {numParticles};
        for nPart=1:numParticles
            partLabel = sprintf('<HTML><FONT COLOR=rgb(%i,%i,%i)><b>%g Nm</b></HTML>',round(particleTypes(nPart).color.*255),particleTypes(nPart).diameter);
            diameterPopupOptions{nPart} = partLabel;
        end
    end % diameterPopupOptions

    %% Sets the margin
    function editMargin(hOb , ~)
        defaults.marginNm = shouldBeNumber(defaults.marginNm,hOb,1,[0,inf]);
        updateDiameter();
    end % editMargin  

    %% Edits the sensitivity
    function editSensitivity(hOb , ~)
        defaults.sensitivity = shouldBeNumber(defaults.sensitivity,hOb,1,[0.5,1]);
    end % editSensitivity 

   %% Clears all dots
    function clear ( ~, ~ )
        % Deletes all results
        centersNm = [];
        actRadiiNm = [];
        radiiNm = [];  
        % Structures containing the graphical dots
        clearParticleMarks();
        clearDiscardedMarks();
        clearZoomParticleMarks();
    end % clear
    function keyRelease(~,key)
        switch key.Key
            case 't'
                checked = get(toggleMarksCheckBox,'Value');
                % changes Checkbox to opposite Value
                set(toggleMarksCheckBox,'Value',abs(checked-1));
                toogleMarks();
            case 'd'
                automaticDet();
            case 's'
                save();
            case 'c'
                closeCallBack();
            case 'r'
                rotateImg(0,0);
            case 'x'
                hExact.Value=abs(hExact.Value-1);
            
        end
        
    end
    
    %% Writes the information in the provided file
    function save(~, ~)
        % Writes the data into a file. Although it uses 'wt' as mode, original points are considered.
        file = fopen(resultsFile, 'wt');     
        numParticles = numel(radiiNm);
        for i=1:numParticles
            fprintf(file,'%.4f, %.4f, %.4f, %.1f\n',centersNm(i,1), centersNm(i,2), actRadiiNm(i),radiiNm(i));
        end
        fclose(file);  
        
        if rotated
            %If image has been rotated, rotate saved image and demarcation
            rotateSavedImage(fullImageName,scale,rotated,true,false);
        end
        
        updated = true;
    end % save
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
    %% Closes the figure.
    function closeCallBack ( ~ , ~)
        positionFigure=get(mainFigure,'Position');
        closeCB(updated, @save);
    end % closeCallback

    function setClassifier(~,~)
        defaults.defaultClassifier=classifiers{get(hClassifier, 'Value')};
    end

    %% Automatic detection
    function automaticDet ( ~ , ~)
        % Detects the particles
        useClassifier=classifiers{get(hClassifier, 'Value')};
        [detectedCenters, detectedRadii] = detectParticles(image, maskSection, imR, scale, defaults.sensitivity, radiusNm, defaults.marginNm, true, useClassifier);
        if numel(detectedRadii)==0
            return
        end
        % Adds the new particls.
        for part=1:numel(detectedRadii)
            addParticle(detectedCenters(part,1), detectedCenters(part,2), radiusNm, detectedRadii(part),particleColor);
        end
        setZoom();   
    end
end