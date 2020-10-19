%% getMainCircle
% Finds a circle with the given radius in the image. In case there are many, returns the closest to the center.
%    
%       getMainCircle(image, radiusPx, sensitivity, marginPx)
%
% Example
%
%       getMainCircle(imDot, 5, 0.9, 1);

%% Parameters
%
% *image*: Image
%
% *radiusPx*: Radius of the circles searched. In pixels.
%
% *sensitivity*: (0,1] Sensitivity parameter for findcircles.
% 
% *margin*: Searches circles with radius [radiusPx-marginPx radiusPx+marginPx]

%% Returns
%
% *centerPx*: Center fo the circle closest to the center of the image.
%
% *actRadiusPx*: Detected radius of the circle.
%
% *metric*: Metric for the circle returned by imfindcircles.

%% Errors
%
% * Non valid image.
%
% * Parameters out of range.

%% Implementation
function [centerNm, actRadiusNm, metric] = getMainCircle(image, imR, radiusNm, scale, sensitivity, marginNm)
    
    warning('off','images:imfindcircles:warnForSmallRadius');
    warning('off','images:imfindcircles:warnForLargeRadiusRange')
    %% Gets values from the image.
    imgSide = size(image,1);
    imgCenter = size(image)./2;
    radiusPx=radiusNm/scale;
    marginPx=marginNm/scale;
    %% Validates the values of the parameters
    if (radiusPx*2>imgSide)
        fprintf('Radius %.2fPx is too big for an image with side %dpx.\n',radiusPx, imgSide);
        return;
    end
    if (sensitivity<=0 || sensitivity >1)
        fprintf('Sensitivity must be in (0,1] (currently %.2f).\n',sensitivity);
        return;
    end

    if (marginPx<=0)
        fprintf('Margin must be greater than 0 (currently %.2f).\n',marginPx);
        return;
    end

    % Due to changes in intensity and resolution of the images, it becomes necessary
    % to consider some margin in the expected radius.
    lowerMargin = floor(radiusPx - marginPx);
    if lowerMargin<1
        lowerMargin=1;
    end
    upperMargin = ceil(radiusPx + marginPx);

    %% Detects circles
    [centers, radii, metrics] = imfindcircles(image, [lowerMargin upperMargin] ,'Method','TwoStage','ObjectPolarity','dark','Sensitivity',sensitivity);
    

    %% Returns the circle of interest.
    % Number of circles detected
    numCircles = numel(radii);

    % If there are no circles, it returns empty variables.
    if (numCircles==0)
        centerNm = [];
        actRadiusNm = [];
        metric = 0;
        return;
    end

    % If there is only one, it is chosen.
    if (numCircles==1)
        centerPx = centers(1,:);
        actRadiusPx = radii(1);
        metric = metrics(1);

    % Otherwise, determines which circle which is closest to the center.
    elseif (numCircles>1)
        %First discard circles whoze size is to different
        %If particles of the correct size exist keep only those
        if ~any(radii>lowerMargin & radii<upperMargin)
            %Otherwise keep particles of radius+-1.3 Margin
            upperMargin=radiusPx+1.3*marginPx;
            lowerMargin=radiusPx-1.3*marginPx;
        end
        centers=centers(radii<=upperMargin,:);
        metrics=metrics(radii<=upperMargin);
        radii=radii(radii<=upperMargin);
        centers=centers(radii>=lowerMargin,:);
        metrics=metrics(radii>=lowerMargin);
        radii=radii(radii>=lowerMargin);
        numCircles = numel(radii);
        if numCircles==0
            centerNm = [];
            actRadiusNm = [];
            metric = 0;
            return;
        elseif numCircles==1
            centerPx = centers(1,:);
            actRadiusPx = radii(1);
            metric = metrics(1);
        else
            %Now find closest
            distances = sqrt(sum(bsxfun(@minus, centers, imgCenter).^2,2));
            closest = find(distances==min(distances));
            if numel(closest)>1
                %More than one Circle is closest
                %Pick a random one (probably not optimal solution...)
                idx=randi(numel(closest));
                closest=closest(idx);
            end
            centerPx = centers(closest,:);
            actRadiusPx = radii(closest);
            metric = metrics(closest);
        end
    end
    centerNm=[0,0];
    [centerNm(1),centerNm(2)]=intrinsicToWorld(imR,centerPx(1),centerPx(2));
    actRadiusNm=actRadiusPx.*scale;
    
    
end

