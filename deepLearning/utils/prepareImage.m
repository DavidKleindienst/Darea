function [image, label] = prepareImage(image, targetSize, mask, targetColor, backgroundColor,rgb, dots)
%% If mask is specified it will be processed along; otherwise only image
if nargin<3
    mask=NaN;
end
if isnan(mask)
    label=NaN;
end
if nargin<6
    rgb=1;
end
if nargin<7
    dots=NaN;
end

if ~isnan(image)
    imsize=size(image);
else
    imsize=size(mask);
end
if imsize(1)~=imsize(2)
%% Compute square to crop image into a square if it is not
% This is done by cropping the image to the largest square in middle of image
% i.e. if image is 500x300 px, it will become 300x300px with the left and
% rightmost 100 px being discarded
% If an odd number is discarded, 1 more line of the higher index is
% discarded
   
    if imsize(1)<imsize(2)
        x=(imsize(2)-imsize(1))/2;
        rect=[ceil(x) 1 imsize(1)-1 imsize(1)];
    else
        x=(imsize(1)-imsize(2))/2;
        rect=[1 ceil(x) imsize(2) imsize(2)-1];
    end
    
end

if ~isnan(image)
if imsize(1)~=imsize(2)
    image=imcrop(image,rect);
end
assert(size(image,1)==size(image,2));

%Convert to 8bit grayscale
image=uint8(image/256);
%resize to target size
image=imresize(image,targetSize);

if isstruct(dots) && isstruct(targetColor)
   %Image will be prepared for particle prediction
   resizeFactor=size(image,1)/size(mask,1);
   mask=imresize(mask,targetSize, 'nearest');
   image(mask==1)=256;
   dotImage=ones(size(image)).*backgroundColor;
   [imColumns, imRows] = meshgrid(1:size(image,2), 1:size(image,1));
   for p=1:numel(dots.r)
      color=targetColor.(['nm' num2str(2*dots.r(p))]);
      circlePx=logicalCircle(imColumns,imRows,round(dots.c(p,1)*resizeFactor),round(dots.c(p,2)*resizeFactor),dots.r(p)*resizeFactor/dots.scale);
      
      dotImage(circlePx)=color;
   end
   
   dotImage(mask==1)=backgroundColor;
   dotImage=uint8(dotImage);
   %convert to RGB
    if rgb
        dotImage=cat(3,dotImage,dotImage,dotImage);
    end
   mask=NaN;    %Do not process mask, because this is for particle Detection
   label=dotImage;
end
if rgb
    %Convert to rgb
    image=cat(3,image,image,image);
end
end


if ~isnan(mask)
    if imsize(1)~=imsize(2)
        mask=imcrop(mask,rect);
    end
    assert(size(mask,1)==size(mask,2));
    label=ones(size(mask)).*backgroundColor;
    
    %give appropriate forground color for the label
    label(mask==0)=targetColor;
    label=uint8(label);
    
    %resize to target size
    label=imresize(label,targetSize, 'nearest');
    %convert to RGB
    if rgb
        label=cat(3,label,label,label);
    end
end

    function circlePx=logicalCircle(imColumns,imRows,centerX,centerY,r)
        circlePx = (imRows - centerY).^2 + (imColumns - centerX).^2 <= r.^2;
    end

end

