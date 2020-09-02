%
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

function [settings, Data, position]=visualize(pathImage, imageName, scale, imgId, autocontrast, settings, datFile, Data, position)
   
    fullImageName=[fullfile(pathImage,imageName) '.tif'];
    modImageName=[fullfile(pathImage,imageName) '_mod.tif'];
    image = imread(fullImageName);
    if autocontrast
        image=imadjust(image);
    end
    zoomLimit=min(size(image))*scale;
    if size(image,3)==1
        image = cat(3,image,image,image);   %Convert image to rgb
    end
    mask=[]; rim=[];
    
    dotsFile = [fullImageName 'dots.csv'];
    warning('off','MATLAB:polyshape:repairedBySimplify');
    
    if ~isa(image, 'uint16')
        msgbox('This image is not 16 bit and cannot be processed');
        return
    end

    infoI=Data.Orig.Images;
    infoP=Data.Orig.PartCount;
    particletypes=infoP.categories;
    if ~strcmp(Data.methodA{1}, 'all')
        %First color is reserved for all particles, so should be removed when all was not analyzed
        %However, settings will be returned and reused, so it should only happen once
        %Therefore load defaults and compare if it has been changed
        def=readDefaults(datFile);
        if isequal(def.particleColor,settings.particleColor)
            settings.particleColor(1)=[];
            settings.fillParticle(1)=[];
        end
    end
    particleList=cellfun(@(x)getName(Data,x), Data.methodA, 'UniformOutput',false);
    if ~isempty(Data.simnames)
        particleList=[particleList, cellfun(@(x)['Sim ' x], particleList, 'UniformOutput',false)];
    end
    if ~isfield(Data.settings.SimOptions, 'exclZones')
        %Compatibility with analysis from previous version
        Data.settings.SimOptions.exclZones=0;
    end
    %Make simulation list
    SimLookup{1}.Text='None';
    SimLookup{1}.s='';
    for s=1:numel(Data.simnames)
        name=Data.simnames{s};
        for a=1:numel(Data.methodA) %Which particle was simulated
            mname=getName(Data,Data.methodA{a});
            for n=1:Data.nrsim
                currentCount=(s-1)*numel(Data.methodA)*Data.nrsim+(a-1)*Data.nrsim+n+1;
                SimLookup{currentCount}.Text=[name ' - ' mname ' - ' num2str(n)];
                SimLookup{currentCount}.s=name;
                SimLookup{currentCount}.a=a;
                SimLookup{currentCount}.n=n;
            end
        end
    end
    lookup=SimLookup{1};
    %% GUI
    imR=imref2d(size(image),scale,scale);
    title='Darea - Visualize';
    [mainFigure, axesImage,axesZoom, hZoomText, hZoom, gridXPx, gridYPx,hPosX,hPosY] = make2PanelWindow(title,image,imageName,scale,0.72,0.8,1, settings, @createZoom,@moveZoomToPos);
    
    set(mainFigure, 'CloseRequestFcn', @closeCallBack); % Manages figure closing.
    set(mainFigure, 'windowbuttonupfcn',@imageMouseReleased);
    set(mainFigure, 'KeyReleaseFcn',@keyRelease);
    hMeasure=uicontrol('Style','togglebutton','String','Measure Distance', 'Position', [gridXPx(2)-360 20 100 25],'Callback',@measure);

    
    markI=[]; markZ=[]; cmarkI=[]; cmarkZ=[]; scale_bar=[];
    centerX=0; centerY=0; centerMarkI=[]; centerMarkZ=[];
    demLineI=[]; demLineZ=[]; rimLineI=[]; rimLineZ=[]; exclLineI=[]; exclLineZ=[];
    exclZones=[];
    % Structures containing measuring objects
    measurePoints = []; 
    measureLines = [];
    
    %Info on simulation
    simI=NaN;

    hMarkPointsCheckBox = uicontrol('Style', 'CheckBox', 'String','Particles', 'Position', [25 125 75 25], 'Callback', @(~,~)markDots(), 'Value', settings.showParticles);
     
    clusterbuttons=gobjects(1,numel(Data.methodA));
    for p=1:numel(Data.methodA)
        clusterbuttons(p)=uicontrol('Style', 'CheckBox', 'String', ['Clusters ' getName(Data,Data.methodA{p})], 'Position', [-15+p*120 125 100 25], 'Callback', @(~,~)showClusters());
        addprop(clusterbuttons(p), 'radius');
        set(clusterbuttons(p), 'radius', Data.methodA{p});
    end


    hSimText=uicontrol('Style', 'Text', 'String','Show Simulation', 'Position', [25 90 85 25]);
    simtexts=cell(1,numel(SimLookup));
    for i=1:numel(SimLookup); simtexts{i}=SimLookup{i}.Text; end
    hSimulate = uicontrol('Style', 'popup', 'String', simtexts, 'Position', [110 90 170 25], 'Callback', @(~,~)showSim());
    if numel(simtexts)==1 
        hSimText.Visible='off';
        hSimulate.Visible='off';
    end
    hCenter=uicontrol('Style','checkbox', 'String', 'Show Center of Gravity', 'Value', settings.showCenter, ...
                        'Position', [25 60 150 25] ,'Callback', @(~,~)markDots());
    
    hSettingsButton = uicontrol('Style', 'pushbutton', 'String', 'Settings', 'Position', [400 60 80 25], 'Callback', @(~,~)setsettings());
    hScalebarCheckBox=uicontrol('Style', 'CheckBox', 'Value', settings.showScalebar, 'String', 'Scalebar', 'Position', [285 90 80 25], 'Callback', @(~,~)scaleBar());
    hColocalization=uicontrol('Style', 'Checkbox', 'String', 'Show Colocalization', 'Position', [200 60 150 25], 'Callback', @(~,~)setZoom());
    if ~isfield(Data.Orig, 'Colocalization')
        set(hColocalization, 'Visible', 'off');
    end
    
    hHideIm=uicontrol('Style', 'checkbox', 'String', 'Hide Image', 'Position', [gridXPx(3) 20 80 25], ...
                    'Tooltipstring', 'Hide image. Only display Annotations', 'Callback', @(~,~)setZoom);
    
    hExportInfo=uicontrol('Style', 'checkbox', 'String', 'Save Info', 'Position', [gridXPx(4)-310 20 80 25],...
                    'Tooltipstring', 'Write information about image to file when exporting', 'Value', 1);
    hExportButton = uicontrol('Style', 'pushbutton','String','Export','Position', [gridXPx(4)-220 20 100 25], 'Callback',@export);
    uicontrol('Style', 'pushbutton', 'String', 'Close [c]','Units','pixels','Position',[gridXPx(4)-100 20 100 25],'Tooltipstring','Closes the application','Callback',@closeCallBack); 

    
    %% Loads the main image
    maskedImage=[];
    showMaskedImage();
    
    
    %% Creates the zoom 
    positionZoomNm = [imR.ImageExtentInWorldX/2-settings.zoomImageSizeNm/2 imR.ImageExtentInWorldY/2-settings.zoomImageSizeNm/2 settings.zoomImageSizeNm settings.zoomImageSizeNm];
    
    % Declares these elements so that they can be accesed in the whole function
    zoomRectangle = [];
    zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                'Deletable', false, 'FixedAspectRatio',true);
    xl=get(axesImage,'XLim');
    yl=get(axesImage,'YLim');
    set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);
    maskedImageZoom = [];
    handleZoom = [];
    
   
    %% Sets the zoom 
    setZoom();
    
    set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable
    if ~isnan(position)
        %Put figure to the position the user had with the image before
        set(mainFigure, 'Position', position);
    end
    % Waits for the figure to close to end the function.
    waitfor(mainFigure);

    function heatmap=getColocalizationHeatmap()
        r1=Data.radii(1);
        r2=Data.radii(2);
        %sigma=getThreshold(r1,r2)./2.355./2;   %threshold is fwhm, so divide by 2.355 to get sigma
        sigma=[40/2.355, 40/2.355]; 
        coloc=imageColocalization(infoI{imgId}, r1, r2, sigma, 1);
        heatmap=cat(3,coloc.colocalizationImage,coloc.gaussP1, coloc.gaussP2);
        fprintf('colocP1 %g\ncolocP2 %g\ncoloc %g\n',coloc.coloc_of_P1,coloc.coloc_of_P2,coloc.colocalization);
    end



    function showSim()
       currentSim=get(hSimulate, 'Value');
       lookup=SimLookup{currentSim};
       if lookup.s
           simI=Data.(lookup.s){lookup.a}.Images{lookup.n}{imgId};
       else
           simI=NaN;
       end
       if isfield(simI,'exclusionZoneCenters') && ~isempty(simI.exclusionZoneCenters)
           exclZones=getExclusionZones(infoI{imgId}.demarcatedAreas, simI.exclusionZoneCenters,...
                        Data.settings.SimOptions.zoneDiameter/2/scale,'only');
       else
           exclZones=[];
       end
       drawRoiLines();
       markDots();
       showClusters();
    end
    
    function showMaskedImage()
        maskedImage = image;
        if settings.maskFromAnalysis
            mask=infoI{imgId}.demarcatedAreas;
            rim=infoI{imgId}.discardedAreas;
            boundary=infoI{imgId}.boundary;
        else
            mask=getBaseImages(fullImageName, modImageName);
            rim=getBaseImages(fullImageName, modImageName, round(settings.dilate/scale));
            boundary=getBoundary(mask,scale,true);
        end
        mask=cat(3,mask,mask,mask);
        rim=cat(3,rim,rim,rim);
        if strcmp('Brightness',settings.DemarcationStyle) && strcmp('Color',settings.RimStyle)
            %With this combination, mask and rim definition is modified so it looks good
            newmask=rim;
            rim=~xor(rim,mask);
            mask=newmask;
        end
        if sum(mask,'all')>0
            
            if strcmp('Brightness',settings.RimStyle)
                maskedImage(rim) = maskedImage(rim)*settings.BackgroundBrightness;
            elseif strcmp('Color', settings.RimStyle)
                overlaidImage=overlayImage(image, settings.colorRimColor,settings.transparencyRim);
                maskedImage(~rim)=overlaidImage(~rim);
            end
            if strcmp('Brightness',settings.DemarcationStyle)
                maskedImage(mask) = maskedImage(mask)*settings.BackgroundBrightness;
            elseif strcmp('Color', settings.DemarcationStyle)
                overlaidImage=overlayImage(image, settings.colorDemColor,settings.transparencyDem);
                maskedImage(~mask)=overlaidImage(~mask);
            end
                
            
        end
        polygon=polyshape(boundary(:,1), boundary(:,2));
        [centerX, centerY]=centroid(polygon);
        handleImage = imshow(maskedImage, imR, 'Parent', axesImage);    
        set(handleImage,'ButtonDownFcn',@imageClickCallBack);
    end


    function changeMask()
        showMaskedImage();
        zoomRectangleMov = drawrectangle(axesImage, 'Position', positionZoomNm, 'FaceAlpha',0,'LineWidth',3, ...
                         'Deletable', false, 'FixedAspectRatio',true);
        xl=get(axesImage,'XLim');
        yl=get(axesImage,'YLim');
        set(zoomRectangleMov, 'DrawingArea',[xl(1),yl(1),xl(2)-xl(1),yl(2)-yl(1)]);
        setZoom();
    end

    function imageClickCallBack(~ , ~)
       coordinates = get(axesImage,'CurrentPoint');
       positionZoomNm(1) = coordinates(1,1)-settings.zoomImageSizeNm/2;
       positionZoomNm(2) = coordinates(1,2)-settings.zoomImageSizeNm/2;
       setZoom();    
    end
    function imageMouseReleased(~ , ~)
        % If the current object is the main image.
        if (gca==axesImage)
            % If the coordinates of the rectangle have changed, changes the zoom
            positionZoomMovNm = zoomRectangleMov.Position;
            
            if positionZoomNm(1) ~= positionZoomMovNm(1) || positionZoomNm(2) ~= positionZoomMovNm(2) || positionZoomMovNm(3) ~= settings.zoomImageSizeNm
                positionZoomNm(1) = positionZoomMovNm(1);
                positionZoomNm(2) = positionZoomMovNm(2);
                if positionZoomMovNm(3) ~= settings.zoomImageSizeNm
                    settings.zoomImageSizeNm=positionZoomMovNm(3);
                    set(hZoom, 'String', int2str(settings.zoomImageSizeNm))
                    createZoom();
                    return;
                end
                setZoom();  
            end
        end
    end
    function zoomClickCallback(~,~)
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
        end
    end
    function showClusters()
        clearClusters()
        for c=1:numel(clusterbuttons)
            if get(clusterbuttons(c),'Value')
                markClusters(get(clusterbuttons(c),'radius'));
            end
        end
    end
    function clearClusters()
        delete(cmarkZ);
        delete(cmarkI);
        cmarkZ=[]; cmarkI=[];
    end
    function markClusters(r)
        %thresh=getAppropriateThreshold(infoI{imgId}, r);
        c = cellfun(@(x)isequal(x,r),Data.methodA);
        points = infoI{imgId}.centers;
        infoC=Data.Orig.Clustering{c}{imgId};
        cmarkZ=[cmarkZ, drawClusters(points, infoC.clusters, 'convexhull', '--', 1, settings.particleColor{c}, axesZoom)];
        cmarkI=[cmarkI, drawClusters(points, infoC.clusters, 'convexhull', '--', 1, settings.particleColor{c}, axesImage)];

        %Simulation
        if isstruct(simI) && isequal(Data.methodA{lookup.a},r)
            points=simI.centers;
            simC=Data.(lookup.s){lookup.a}.IndivClust{c}{lookup.n}{imgId};
            cmarkZ=[cmarkZ, drawClusters(points, simC.clusters, 'convexhull', '--', 1, settings.particleColor{find(c)+numel(particletypes)},axesZoom)];
            cmarkI=[cmarkI, drawClusters(points, simC.clusters, 'convexhull', '--', 1, settings.particleColor{find(c)+numel(particletypes)},axesImage)];
        end
        set(cmarkZ,'ButtonDownFcn', @zoomClickCallback);
    end
    

    function markDots()
        settings.showCenter=hCenter.Value;
        settings.showParticles=hMarkPointsCheckBox.Value;
        clearDots();
        if settings.showCenter
            centerMarkI=[centerMarkI, drawCircle(centerX, centerY, 5, ':', 2, 'black', false, axesImage)];
            centerMarkZ=[centerMarkZ, drawCircle(centerX, centerY, 5, ':', 2, 'black', false, axesZoom)];
        end
        set(centerMarkZ, 'ButtonDownFcn', @zoomClickCallback);
        if settings.showParticles
            for nCat=1:numel(particletypes)
                radius = particletypes(nCat);
                c = cellfun(@(x)isequal(x,radius),Data.methodA);
                centers = infoI{imgId}.centers(infoI{imgId}.teorRadii==radius,:);
                numP=size(centers,1);
                for i=1:numP
                    markI =[markI, drawCircle(centers(i,1), centers(i,2), radius, '-', 2, settings.particleColor{c}, settings.fillParticle(c), axesImage)];
                    markZ = [markZ, drawCircle(centers(i,1), centers(i,2), radius, '-', 2, settings.particleColor{c}, settings.fillParticle(c), axesZoom)];
                end
                
                set(markZ, 'ButtonDownFcn', @zoomClickCallback);
            end
            if isstruct(simI)       %Display simulated points
                if strcmp(Data.methodA{lookup.a}, 'all')
                    simradiii=unique(infoI{imgId}.teorRadii);
                else
                    simradiii=[Data.methodA{lookup.a}];
                end
                for r=1:numel(simradiii)
                    radius=simradiii(r);
                    c = cellfun(@(x)isequal(x,radius),Data.methodA);
                    centers=simI.centers(simI.teorRadii==radius,:);
                    numP=size(centers,1);
                    for i=1:numP
                        partNum=find(c)+numel(particletypes);
                        markI = [markI, drawCircle(centers(i,1), centers(i,2), radius, '-', 2, settings.particleColor{partNum}, settings.fillParticle(partNum), axesImage)];
                        markZ =[markZ, drawCircle(centers(i,1), centers(i,2), radius, '-', 2, settings.particleColor{partNum}, settings.fillParticle(partNum), axesZoom)];
                    end
                end   
            end
        end
    end
    %% Clears all particle marks
    function clearDots()
        delete(markI);
        delete(markZ);
        delete(centerMarkI);
        delete(centerMarkZ);
        markZ=[]; markI=[]; centerMarkI=[];centerMarkZ=[];
    end

    
    %Opens window to change simulation settings
    function setsettings()
        settings=VisualizeOptionsMenu(settings, particleList,Data.settings.SimOptions.exclZones);
        changeMask();
    end

    %% Displays a scale bar on the image
    function scaleBar()
        settings.showScalebar=get(hScalebarCheckBox, 'Value');
        if settings.showScalebar
            zoomSize=settings.zoomImageSizeNm;
            offset=round(zoomSize/20);
            switch settings.scalePos
                case('northwest')
                    offsetX=offset; offsetY=offset;
                case('northeast')
                    offsetX=zoomSize-offset-settings.scaleLength; offsetY=offset;
                case('southwest')
                    offsetX=offset; offsetY=zoomSize-offset;
                case('southeast')
                    offsetX=zoomSize-offset-settings.scaleLength; offsetY=zoomSize-offset;
            end
            
            x=positionZoomNm(1)+offsetX;
            y=positionZoomNm(2)+offsetY;
            switch settings.scaleOrientation
                case('horizontal')
                    scale_bar=line(axesZoom, [x, x+settings.scaleLength], [y, y], 'color', settings.scaleColor, 'LineWidth', settings.scaleWidth);
                case('vertical')
                    if endsWith(settings.scalePos, 'east')
                        x=x+settings.scaleLength;
                    end
                    if startsWith(settings.scalePos,'north')
                        scale_bar=line(axesZoom, [x, x], [y, y+settings.scaleLength], 'color', settings.scaleColor, 'LineWidth', settings.scaleWidth);
                    else
                        scale_bar=line(axesZoom, [x, x], [y, y-settings.scaleLength], 'color', settings.scaleColor, 'LineWidth', settings.scaleWidth);
                    end
            end
            set(scale_bar, 'ButtonDownFcn', @zoomClickCallback);
        else
            delete(scale_bar);
            scale_bar=[];
        end
    end

    function drawRoiLines()
        clearLines();
        if strcmp(settings.DemarcationStyle,'Line')
           [demLineI,demLineZ]=drawBoundary(settings.lineDemStyle, settings.lineDemColor, settings.lineDemWidth,mask);
        end
        if strcmp(settings.RimStyle,'Line')
           [rimLineI,rimLineZ]=drawBoundary(settings.lineRimStyle,settings.lineRimColor, settings.lineRimWidth, rim);
        end
        if strcmp(settings.ExclStyle,'Line') && ~isempty(exclZones)
           [exclLineI,exclLineZ]=drawBoundary(settings.lineExclStyle,settings.lineExclColor, settings.lineExclWidth, exclZones);
        end
    end

    function [lineI, lineZ]=drawBoundary(style,color,width,areamask)
        marker=getLineStyleMarker(style);
        boundary=getBoundary(areamask,scale,false);
        lineI = gobjects(1,numel(boundary)-1); lineZ = gobjects(1,numel(boundary)-1);
        for i=1:numel(boundary)
           lineI(i)=line(axesImage, boundary{i}(:,1), boundary{i}(:,2), 'LineStyle', marker, 'color', color, 'LineWidth', width);
           lineZ(i)=line(axesZoom, boundary{i}(:,1), boundary{i}(:,2), 'LineStyle',  marker, 'color', color, 'LineWidth', width);
        end
        set(lineZ, 'ButtonDownFcn', @zoomClickCallback);
    end
    
    function clearLines()
        delete(demLineI); delete(demLineZ);
        delete(rimLineI); delete(rimLineZ);
        delete(exclLineI); delete(exclLineZ);
        demLineI=[]; demLineZ=[]; rimLineI=[]; rimLineZ=[]; exclLineI=[]; exclLineZ=[];
    end
    
    function marker=getLineStyleMarker(style)
       switch style
           case 'solid'
               marker='-';
           case 'dashed'
               marker='--';
           case 'dotted'
               marker=':';
           case 'dash-dot'
               marker='-.';
       end
    end

    % Export
    function export(~, ~)
        
        [exportedImgName,expPath]=uiputfile({'*.png;*.tif;*.jpg'},'Export to', [fullfile(pathImage,imageName) '_export.png']);
        if ~exportedImgName; return; end
        exportedImgName=fullfile(expPath,exportedImgName);
        msg=msgbox('Exporting Image...');
        
        exportfig=figure('Visible','off');
        exportax=copyobj(axesZoom,exportfig);
        set(exportax,'Visible','off', 'xtick',[],'ytick',[]);
        set(exportax, 'Units','normalized', 'Position', [0,0,1,1]);

        export_fig(exportfig, exportedImgName, '-native');
        %save([currentRoute 'info.mat'], 'currImgI', 'simI', 'settings')
        %saveas(exportFigure,exportedImgName);
        if hExportInfo.Value
            %Export some info about the image
            fil=fopen([exportedImgName(1:end-4) '.csv'],'w');
            fprintf(fil,'Route;Scalebar [nm];ZoomPositionX [nm];ZoomPositionY [nm];Zoom width [nm]\n');
            fprintf(fil,'%s;%g;%g;%g;%g', fullfile(pathImage,imageName), settings.scaleLength, positionZoomNm(1),positionZoomNm(2),settings.zoomImageSizeNm);
            fclose(fil);
        end
        delete(msg);
        msgbox(['Figure exported as: ' exportedImgName]);
        delete(exportfig);
    end
    function createZoom(~,~)
        [settings.zoomImageSizeNm, positionZoomNm] = calcZoom(settings.zoomImageSizeNm,hZoom,hZoomText,zoomRectangleMov,zoomLimit);
        set(hZoom, 'String', int2str(settings.zoomImageSizeNm))
        setZoom();
    end

    function measure(~, ~)
        if get(hMeasure, 'Value')==0 && size(measurePoints,1)>0
            measurePoints=[];
            measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        end
    end

    function setZoom()
        
        delete(zoomRectangle);
        [zoomRectangle, ~, zoomR, positionZoomPx, positionZoomNm]=getNewZoomPosition(positionZoomNm,zoomRectangleMov,imR,settings.zoomImageSizeNm,axesImage,image,scale);
        hPosX.String=num2str(positionZoomNm(1));
        hPosY.String=num2str(positionZoomNm(2));
        if get(hColocalization,'Value')
            heatmap=getColocalizationHeatmap();
            maskedImageZoom = imcrop(heatmap,positionZoomPx);
        elseif hHideIm.Value
            maskedImageZoom = imcrop(ones(size(maskedImage)),positionZoomPx);
        else
            maskedImageZoom = imcrop(maskedImage,positionZoomPx);
        end
        axes(axesZoom);
        handleZoom = imshow(maskedImageZoom,zoomR);
        set(handleZoom,'ButtonDownFcn',@zoomClickCallback);

        measureLines = drawMeasure(hMeasure,measurePoints,measureLines,axesZoom);
        markDots();
        scaleBar();
        showClusters();
        drawRoiLines();
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
    function keyRelease(~,key)
         switch key.Key
             case 'c'
                 closeCallBack(0,0);
         end
        
    end
    %% Closes the figure.
    function closeCallBack ( ~ , ~)
        position=get(mainFigure,'Position');
        delete(mainFigure);
    end % closeCallback

end