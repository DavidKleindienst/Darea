function [modPath] = getModImagePath(imagePath,angle)
%% Gets name of modImage
% This is either imageName_mod.tif or imageName_mod_angle.tif

if endsWith(imagePath, '.tif')
    imagePath=imagePath(1:end-4);
end

modPath=[imagePath '_mod.tif'];
if nargin==1 || isnan(angle) || isfile(modPath)
    %modPath has been found
    return;
end

if isfile([imagePath '_mod_' int2str(angle) '.tif'])
    modPath=[imagePath '_mod_' int2str(angle) '.tif'];
end