function dotFeatures = getDotFeatures(imageDot, imageDotR, scale, radiusNm, marginNm, sensitivity, debug)
%% Extracts the features corresponding to the dot provided the center and radius of the circle where it is inscribed.

% imageDot: Image containing the dot.
% scale: Scale of the image (nanometers/pixel).
% radiusNm: Expected radius of the dot (nanometers). 
% marginNm: Tolerated difference with the expected radius (nanometers)
% sensitivity: Sensitivity used by imfindcircles.
% debug: If true, shows images.

% dotFeatures: Vector containing the features of the dot.

    extra_features=0;
    

    % Shows the figure if debugging.
    if (debug)
        figure('OuterPosition',[1200 0 400 300]), subplot(1,2,1), imshow(imageDot);
    end

    % Stores output features.
    if extra_features
        gauss_sigmas=[1,3,5];
        dotFeatures=double(zeros(1,27+15*numel(gauss_sigmas)));
    else
        dotFeatures = double(zeros(1,27));
    end
    
    

    % Gets the main circle in the image.
    [centerNm, actRadiusNm, metric] = getMainCircle(imageDot, imageDotR, radiusNm, scale, sensitivity, marginNm);

    % If there is no circle, there is no dot.
    if (numel(actRadiusNm)==0)
        return
    end  
    
    % Calculates sections of interest
    coreRadiusNm = radiusNm*0.75;
    contourRadiusNm = radiusNm*1.25;
    
    % Shows the figure if debugging.
    if (debug)
        subplot(1,2,2), imshow(imageDot,imageDotR);
        viscircles(centerNm,coreRadiusNm,'LineWidth',1, 'LineStyle','-','EdgeColor', 'white');
        viscircles(centerNm,radiusNm,'LineWidth',1, 'LineStyle','-','EdgeColor', 'white');
        viscircles(centerNm,contourRadiusNm,'LineWidth',1, 'LineStyle','--','EdgeColor', 'white');    
        viscircles(centerNm,actRadiusNm,'LineWidth',1, 'LineStyle','-','EdgeColor', 'red');   
    end    
    
    %convert to Px
    radiusPx=radiusNm/scale;
    coreRadiusPx=coreRadiusNm/scale;
    contourRadiusPx=contourRadiusNm/scale;
    actRadiusPx=actRadiusNm/scale;
    
    % Get pixels of the dot, circle, border, and contour.
    sqSide = size(imageDot,1);
    [rr, cc] = meshgrid(1:sqSide);
    radii_from_middle=sqrt((rr-(sqSide+1)/2).^2+(cc-(sqSide+1)/2).^2);
    % Detected circle (actual radius)
    particle = radii_from_middle<=actRadiusPx;

    % Theoretical radius
    core = radii_from_middle<=coreRadiusPx;
    dot = radii_from_middle<=radiusPx;
    contour = radii_from_middle<=contourRadiusPx;
    contour = xor(dot,contour);    
    
    % Converts the image to double
    imageDot = double(imageDot);
    
    % Mean color of each region
    meanImage = mean(imageDot(:));
    meanParticle = mean(imageDot(particle));
    meanCore = mean(imageDot(core));
    meanDot = mean(imageDot(dot));
    meanContour = mean(imageDot(contour));    
    
    % Standard deviation in the color of each region 
    stdImage = std(imageDot(:));
    stdParticle = std(imageDot(particle));
    stdCore = std(imageDot(core));
    stdDot = std(imageDot(dot));
    stdContour = std(imageDot(contour));     
    
    % Interquartile range for each region
    iqrImage = iqr(imageDot(:));
    iqrParticle = iqr(imageDot(particle));
    iqrCore = iqr(imageDot(core));
    iqrDot = iqr(imageDot(dot));
    iqrContour = iqr(imageDot(contour)); 
    
    
    % Differences
    diffImgPart = meanImage - meanParticle;
    diffImgCore = meanImage - meanCore;
    diffImgDot = meanImage - meanDot;
    diffImgCont = meanImage - meanContour;

    diffParCore = meanParticle - meanCore;
    diffParDot = meanParticle - meanDot;
    diffParCont = meanParticle - meanContour;

    diffCorDot = meanCore - meanDot;
    diffCorCont = meanCore - meanContour;
    
    diffDotCont = meanDot - meanContour;
    
    
    
    %% Feature vector
    % Radius (nanometers)
    dotFeatures(1) = actRadiusNm;
    
    % Metric
    dotFeatures(2) = metric;
   
    % Mean color of each region
    dotFeatures(3) = meanImage;
    dotFeatures(4) = meanParticle;
    dotFeatures(5) = meanCore;
    dotFeatures(6) = meanDot;
    dotFeatures(7) = meanContour;    
    
    % Variances
    dotFeatures(8) = stdImage;
    dotFeatures(9) = stdParticle;
    dotFeatures(10) = stdCore;
    dotFeatures(11) = stdDot;
    dotFeatures(12) = stdContour;     
    
    % Interquartile range for each region
    dotFeatures(13) = iqrImage;
    dotFeatures(14) = iqrParticle;
    dotFeatures(15) = iqrCore;
    dotFeatures(16) = iqrDot;
    dotFeatures(17) = iqrContour;     
    
    % Differences
    dotFeatures(18) = diffImgPart;
    dotFeatures(19) = diffImgCore;
    dotFeatures(20) = diffImgDot;
    dotFeatures(21) = diffImgCont;

    dotFeatures(22) = diffParCore;
    dotFeatures(23) = diffParDot;
    dotFeatures(24) = diffParCont;

    dotFeatures(25) = diffCorDot;
    dotFeatures(26) = diffCorCont;
    
    dotFeatures(27) = diffDotCont;   
    
    if extra_features
        laplacianKernel = [-1,-1,-1;-1,8,-1;-1,-1,-1];
        for s=1:numel(gauss_sigmas)
            gauss=imgaussfilt(imageDot, gauss_sigmas(s));
            lap=imfilter(double(gauss), laplacianKernel);
            % Mean color of each region
            dotFeatures(27+1+(s-1)*15) = mean(lap(:));
            dotFeatures(27+2+(s-1)*15) = mean(lap(particle));
            dotFeatures(27+3+(s-1)*15) = mean(lap(core));
            dotFeatures(27+4+(s-1)*15) = mean(lap(dot));
            dotFeatures(27+5+(s-1)*15) = mean(lap(contour));    

            % Standard deviation in the color of each region 
            dotFeatures(27+6+(s-1)*15) = std(lap(:));
            dotFeatures(27+7+(s-1)*15) = std(lap(particle));
            dotFeatures(27+8+(s-1)*15) = std(lap(core));
            dotFeatures(27+9+(s-1)*15) = std(lap(dot));
            dotFeatures(27+10+(s-1)*15) = std(lap(contour));     

            % Interquartile range for each region
            dotFeatures(27+11+(s-1)*15) = iqr(lap(:));
            dotFeatures(27+12+(s-1)*15) = iqr(lap(particle));
            dotFeatures(27+13+(s-1)*15) = iqr(lap(core));
            dotFeatures(27+14+(s-1)*15) = iqr(lap(dot));
            dotFeatures(27+15+(s-1)*15) = iqr(lap(contour));
            
        end
    end
        
   
    if (debug)
        fprintf('Detected radius: %.2f.\n\n', dotFeatures(1));
        fprintf('Metric: %.2f.\n\n', dotFeatures(2)); 
    
        fprintf('Mean image: %.2f.\n', dotFeatures(3));
        fprintf('Mean particle: %.2f.\n', dotFeatures(4));
        fprintf('Mean core: %.2f.\n', dotFeatures(5));
        fprintf('Mean circle: %.2f.\n', dotFeatures(6));
        fprintf('Mean contour: %.2f.\n', dotFeatures(7));
        
        fprintf('Diff core-contour: %.2f.\n', dotFeatures(26));

    end    
   

end



