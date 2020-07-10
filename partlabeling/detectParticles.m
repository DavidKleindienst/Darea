function [centers, radii, metrics, particleFeatures] = detectParticles(image, maskSection, imR, scale, sensitivity, radiusNm, radMarginNm, showProgress, useClassifier, debug)
    %useClassifier - provide filename (without .mat) of classifier inside folder classifiers
    %set maskSection to NaN to predict on whole image
    %% Disables the warnings
    warning('off','images:initSize:adjustingMag');

    warning('off','images:imfindcircles:warnForSmallRadius');
    warning('off','images:imfindcircles:warnForLargeRadiusRange')
    s=readDefaults();
    if useClassifier
        %Load the Naive Bayes classifiers
        classifier=load(fullfile(s.classifierPath, [useClassifier '.mat']));
        %% Choose classifier with the radius most similar to the one requested
        classParticles=fields(classifier);
        classifiedDiameters=zeros(1,numel(classParticles));
        for p=1:numel(classParticles)
            classifiedDiameters(p)=str2double(strrep(classParticles{p}(3:end),'_','.'));    %strrep for decoding float diameters
        end
        [~, classInd]=min(abs(classifiedDiameters./2-radiusNm));
        classifier=classifier.(classParticles{classInd});
    end
    
    %% Stores the data 
    centers = [];
    radii = [];
    metrics = [];
    particleFeatures = [];
    
    %% Debug is disabled unless other option is indicated
    if nargin<10
        debug=false;
    end

    %% Use whole image if no demarcation is provided
    if isnan(maskSection)
        maskSection=ones(size(image));
    end

    %% Shows the image if showing progress is enabled
    if showProgress
            % Gets the image of interest, which will be shown.
            resImage = image;
            resImage(~maskSection)=resImage(~maskSection)./2;
            % Image measures
            sizeGUI=0.7;
            % Main image
            [imageHeightPx, imageWidthPx] = size(image);
            screenSize = get(0,'Screensize');
            % Calculates ratios image/screen 
            ratioImScreen = [imageHeightPx/screenSize(4)  imageWidthPx/screenSize(3)];
            % Takes the size of the screen for the dimmension with the biggest ratio
            if ratioImScreen(1)>ratioImScreen(2)
                dispImageHeightPx = screenSize(4) * sizeGUI; 
                dispImageWidthPx = dispImageHeightPx/imageHeightPx * imageWidthPx;
            else
                dispImageWidthPx = screenSize(3) * sizeGUI; 
                dispImageHeightPx = dispImageWidthPx/imageWidthPx * imageHeightPx;
            end  
            figureWidthPx = dispImageWidthPx+20;
            figureHeightPx = dispImageHeightPx+60;
            
            %% Figure
            title=sprintf('Automatic detection for %g nm particles', radiusNm*2);
            mainFigure = figure('NumberTitle','off','Position',[screenSize(3)-figureWidthPx screenSize(4)-figureHeightPx figureWidthPx figureHeightPx],...
                                'name',title,'keyRelease',@hotkeys);
            set(mainFigure, 'menubar', 'none'); % No menu bar.
            set(mainFigure,'resize','off'); % Prevents the figure for resizing (it is almost maximized).
            set(mainFigure,'resize','off'); % Prevents the figure for resizing (it is almost maximized).                             
            panelImage = uipanel('Units','pixels','Position',[10 60 dispImageWidthPx dispImageHeightPx]);
            axesImage = axes('parent', panelImage, 'Position', [0 0 1 1]);                 
            imshow(resImage, imR, 'Parent', axesImage);   
            uicontrol('Style', 'pushbutton', 'String', 'Add marks','Units','pixels','Position',[dispImageWidthPx-170 20 80 25],'Tooltipstring','Closes the figure','Callback',@closeAcceptCallBack);
            uicontrol('Style', 'pushbutton', 'String', 'Cancel','Units','pixels','Position',[dispImageWidthPx-80 20 80 25],'Tooltipstring','Closes the figure','Callback',@closeCancelCallBack); 
            
            pause(0.2);
    end
    
    
    %% Measures and scales
    
    % radius

    radiusMarginNm = radMarginNm/2; %Margin corresponds to diameter
    
    % Size of the image.
    imageSizePx = size(image);
    imageSizeNm = imageSizePx .* scale;
    
    % It is necessary to define margins.
    %marginPx = 5;
    marginNm = 10;
    
    % Size of the image minus margins
    utilImageSizeNm = imageSizeNm - (2*marginNm);
    
    % Size of each subimage.
    subImageSizePx = 200;
    subImageSizeNm = subImageSizePx * scale;
    
    %% Process each 100x100Nm subimage.
    
    % Number of subimages
    numSubImagesX = ceil(utilImageSizeNm(2)/subImageSizeNm);
    numSubImagesY = ceil(utilImageSizeNm(1)/subImageSizeNm);
    
    % The size of the subimage can change. But the x coord changes only once
    subImageSizeNmX = subImageSizeNm;
    
    % Obtains the coordinates of the subimage for each column.
    for subImgXId=0:numSubImagesX-1
    
        posX = marginNm + (subImgXId * subImageSizeNm);  
        if (posX + subImageSizeNmX) > imageSizeNm(2)-marginNm
            subImageSizeNmX = (imageSizeNm(2)-marginNm) - posX;
        end         
        subImageSizeNmY = subImageSizeNm;
        
        % Obtains the coordinates of the subimage for each row.
        for subImgYId=0:numSubImagesY-1 
            posY = marginNm + (subImgYId * subImageSizeNm);    
            
             if (posY + subImageSizeNmY) > imageSizeNm(1)-marginNm
                 subImageSizeNmY = (imageSizeNm(1)-marginNm) - posY;
             end                        
             
             %% Extracts the subimage
             %  Coordinates of the subimage. 
             rectSubImgNm = [posX posY subImageSizeNmX subImageSizeNmY];
             [xPx, yPx]=worldToSubscript(imR,rectSubImgNm(1),rectSubImgNm(2));
             rectSubImgPx=[yPx,xPx,round(rectSubImgNm(3)./scale),round(rectSubImgNm(4)./scale)];
             % Checks whether the subimage must be processed. If not, continues.
             if numel(find(maskSection(rectSubImgPx(2):rectSubImgPx(2)+rectSubImgPx(4),rectSubImgPx(1):rectSubImgPx(1)+rectSubImgPx(3))==1))==0
                continue;
             end   
             
             % Shows the rectangle if showing progress
             if (showProgress==true)     
                figure(mainFigure);
                rectangle('Position', rectSubImgNm, 'LineWidth', 2, 'EdgeColor','w');  
             end      
             
             %  The subimage where the circles are detected is slightly bigger,
             %  but only those circles whose center is inside the rectangle will be considered.
             workRectSubImgNm = [rectSubImgNm(1)-marginNm,rectSubImgNm(2)-marginNm, rectSubImgNm(3)+2*marginNm, rectSubImgNm(4)+2*marginNm];
             [xPx, yPx]=worldToIntrinsic(imR,workRectSubImgNm(1),workRectSubImgNm(2));
             workRectSubImgPx=[xPx,yPx,workRectSubImgNm(3)./scale,workRectSubImgNm(4)./scale];
             
             %Crop the subimage and set scale properly
             subImg = imcrop(image,workRectSubImgPx);     
             subMask = imcrop(maskSection,workRectSubImgPx);   
             
             subR=imref2d(size(subImg),scale,scale);
             
             subR.XWorldLimits=subR.XWorldLimits+workRectSubImgNm(1);
             subR.YWorldLimits=subR.YWorldLimits+workRectSubImgNm(2);
         
             
             % In the resized image, obtains the rectangle of interest (particles in the margins are discarded).
             %rectSubImgPxSc = [marginPxSc marginPxSc subImgSizePxSc(2)-2*marginPxSc subImgSizePxSc(1)-2*marginPxSc];    
             
             % Shows the image if debugging.
             if (debug==true)                
                 subImgFigure = figure();
                 resSubImg = subImg;
                 resSubImg(~subMask)=subImg(~subMask)./2;
                 imshow(resSubImg,subR);
                 pause(0.5)
                 % Marks the rectangle which is considered
                 rectangle('Position', rectSubImgNm, 'LineWidth', 2, 'EdgeColor','red');
             end
             
            %% Finds candidate particles
            lowerMargin = radiusNm - radiusMarginNm;
            lowerMarginPx=floor(lowerMargin/scale);
            if lowerMarginPx<1
                lowerMarginPx=1;
            end
            upperMargin = radiusNm + marginNm;
            upperMarginPx=ceil(upperMargin/scale);
            [detCentersPx, detRadiiPx, subImgMetrics] = imfindcircles(subImg, [lowerMarginPx upperMarginPx],'Method','TwoStage','ObjectPolarity','dark','Sensitivity',sensitivity);

            if numel(detRadiiPx)>0
                [a,b]=intrinsicToWorld(subR,detCentersPx(:,1),detCentersPx(:,2));
                detCentersNm=[a,b];
                detRadiiNm=detRadiiPx.*scale;
                
                selected = false(numel(detRadiiNm),1);
                % Discards those outside the margin
                selected(detCentersNm(:,1)>rectSubImgNm(1) & detCentersNm(:,1)<rectSubImgNm(1)+rectSubImgNm(3) & ...
                              detCentersNm(:,2)>rectSubImgNm(2) & detCentersNm(:,2)<rectSubImgNm(2)+rectSubImgNm(4))=true;
                            
                % Does not include those in the discarded areas.
                % Beware of the use of indexes. DiscardedAreas is a matrix.

                selected = and(selected, diag(subMask(round(detCentersPx(:,2)),round(detCentersPx(:,1)))));
                % Deletes discarded particles.
                detCentersNm = detCentersNm(selected,:);
                detRadiiNm = detRadiiNm(selected);
                detRadiiPx = detRadiiPx(selected);
                subImgMetrics = subImgMetrics(selected);
            end
            %% Processes the candidate particles             
            numCandPart = numel(detRadiiPx);  
            if numCandPart>0               
                % Shows the subimage and candidate particles.
                if (debug==true)
                    figure(subImgFigure)
                    viscircles(detCentersNm,detRadiiNm, 'LineWidth',2, 'EdgeColor', 'red');
                    pause;
                    %delete(subImgFigure) 
                end
                
                % Classifies the images
                selected = false(numCandPart,1);
                for partId=1:numCandPart
                    % Gets the image of the particle.
                    rectParticle = [detCentersNm(partId,1)-marginNm ,detCentersNm(partId,2)-marginNm, 2*marginNm, 2*marginNm];
                    [xPx, yPx]=worldToIntrinsic(imR,rectParticle(1),rectParticle(2));
                    rectParticlePx=[xPx,yPx,rectParticle(3)./scale,rectParticle(4)./scale];
                    
                    imageParticle = imcrop(image, rectParticlePx);
                    partR=imref2d(size(imageParticle),scale,scale);
                    
                    partR.XWorldLimits=partR.XWorldLimits+rectParticle(1);
                    partR.YWorldLimits=partR.YWorldLimits+rectParticle(2);
                    
                    % Extracts dot fatures.
                    partFeatures = getDotFeatures(imageParticle, partR, scale, radiusNm, radMarginNm, sensitivity, false);
                    particleFeatures=[particleFeatures; partFeatures];
                    if  useClassifier & isTrue(predict(classifier,partFeatures))
                            selected(partId)=true;
                    end
                end
                if ~useClassifier
                    selected = true(numCandPart,1);
                end
                centersNm = detCentersNm(selected,:);
                radiiNm = detRadiiNm(selected);
                subImgMetrics = subImgMetrics(selected);    
                    
                % Shows the progress
                if (showProgress)
                    figure(mainFigure);
                    viscircles(centersNm,radiiNm, 'LineWidth',1, 'EdgeColor', 'red'); 
                    pause(0.05)
                end    
                
                % Updates the detected circlesload 
                centers = [centers; centersNm];
                radii = [radii; radiiNm];
                metrics = [metrics; subImgMetrics];                                   
                
            end
        end
    end

    % Waits for the main figure.
    if (showProgress)    
       waitfor(mainFigure);
    end
    
    function closeCancelCallBack ( ~ , ~)
        centers = [];
        radii = [];
        delete(gcf);
        return
    end      

    function closeAcceptCallBack ( ~ , ~)
        delete(gcf);
        return
    end
    function hotkeys(~,key)
        if strcmp(key.Key,'space') 
            closeAcceptCallBack()
        elseif strcmp(key.Key,'escape')
            closeCancelCallBack()
        end
    end 
    function val=isTrue(val)
        if iscell(val)
            val=str2double(val{1});
        end
    end
end

    

