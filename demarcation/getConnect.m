function image=getConnect(image,originalImage,selectedComponent,defaults)
%GETCONNECT Summary of this function goes here
%   Detailed explanation goes here

image.compImage(:)=max(image.compImage(:),selectedComponent(:));
originalImage(image.compImage==0)=originalImage(image.compImage==0)*defaults.BackgroundBrightness;
image.image=originalImage;

end

