function closeAllImages(datFile,rCloseNm)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[path, file,fileextension]=fileparts(datFile);

[routes, scales]=readConfig([fullfile(path,file) fileextension]);

for i=1:numel(routes)
    mod_route=fullfile(path,[routes{i} '_mod.tif']);    
    if ~isfile(mod_route)
        continue
    end
    
    close_radius=round(rCloseNm/scales(i));
    modImage=readAndConvertImage(mod_route);
    modComponents=zeros(size(modImage));
    modComponents(modImage==65535)=1;
    modComponents = bwareaopen(modComponents,20);
    modComponents = imopen(modComponents, strel('diamond',2));
    modComponents = abs(modComponents-1); %Invert binary image
    
    modComponents = imclose(modComponents,strel('disk',close_radius));

    outImage=modImage;
    outImage(modComponents==0)=65535;
    outImage(modComponents==1)=1337;
    imwrite(outImage,mod_route);
end

end

