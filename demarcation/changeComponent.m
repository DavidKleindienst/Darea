function image = changeComponent(image,originalImage,polygon,action,defaults)
%UNTITLED Summary of this function goes here
%  action should be add or remove

changedC=zeros(size(image.compImage));
changedC(image.compImage==1)=1;
mask=poly2mask(polygon(:,1),polygon(:,2),size(image.image,1),size(image.image,2));
if strcmp(action,'add')
    changedC(mask==1)=1;
elseif strcmp(action,'remove')
    changedC(mask==1)=0;
end

image.compImage=changedC;

originalImage(changedC==0)=originalImage(changedC==0)*defaults.BackgroundBrightness;
image.image=originalImage;
end

