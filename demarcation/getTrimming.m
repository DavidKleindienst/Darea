function image = getTrimming(image,originalImage,trimPoly,defaults)
%GETTRIMMING Summary of this function goes here
%   Detailed explanation goes here

trimmedImg=zeros(size(image.compImage));
trimmedImg(image.compImage==1)=1;
for i=2:size(trimPoly,1)
    mask=createLineMask(size(trimmedImg),trimPoly(i-1,2),trimPoly(i-1,1),trimPoly(i,2),trimPoly(i,1));
    trimmedImg(mask==1)=0;
end
image.compImage=trimmedImg;

originalImage(trimmedImg==0)=originalImage(trimmedImg==0)*defaults.BackgroundBrightness;
image.image=originalImage;
end

