function [image, label] = prepareImage(image, targetSize, mask, targetColor, backgroundColor,rgb,groups)
%% If mask is specified it will be processed along; otherwise only image
if nargin<3
    mask=NaN;
end
if ~iscell(mask) & isnan(mask)
    label=NaN;
end
if nargin<6
    rgb=1;
end
if nargin<7 | isnan(groups)
    groups=1;  
end

if ~isnan(image)
    imsize=size(image);
elseif iscell(mask)
    imsize=size(mask{1});
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


    if rgb
        %Convert to rgb
        image=cat(3,image,image,image);
    end
end

if ~iscell(mask) & isnan(mask)
    return;
end

if ~iscell(mask)
    mask={mask};
elseif numel(groups)>1
    assert(numel(mask)==numel(groups))
end
for i=1:numel(mask)
    if imsize(1)~=imsize(2)
        mask{i}=imcrop(mask{i},rect);
    end
    assert(size(mask{i},1)==size(mask{i},2));
end
label=ones(size(mask{i})).*backgroundColor;

for i=1:numel(mask)
    %give appropriate forground color for the label

    if numel(groups)==1
        label(mask{i}==0)=targetColor(groups);
    else
        label(mask{i}==0)=targetColor(groups(i));
    end

end
label=uint8(label);
%resize to target size
label=imresize(label,targetSize, 'nearest');
%convert to RGB
if rgb
    label=cat(3,label,label,label);
end




end

