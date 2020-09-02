function exportAllImagesFromDat(datFile,Data,color, transparency,outfolder)
safeMkdir(outfolder);
routes=readConfig(datFile);
pathImage=fileparts(datFile);
infoI=Data.Orig.Images;

for i=1:numel(routes)
    imageName=routes{i};
    %Make subfolders if neccessary
    subfolder=fileparts(imageName);
    safeMkdir(fullfile(outfolder,subfolder));
    
    fullImageName=[fullfile(pathImage,imageName) '.tif'];
    modImageName=[fullfile(pathImage,imageName) '_mod.tif'];
    image = imread(fullImageName);

    if size(image,3)==1
        image = cat(3,image,image,image);   %Convert image to rgb
    end
    
    if 1 %This is for exporting with outer rim; Should make an option for demarcation only
       area=infoI{i}.discardedAreas; 
    end
        
    area=cat(3,area,area,area);
    maskedImage=image;
    overlaidImage=overlayImage(image, color,transparency);
    maskedImage(~area)=overlaidImage(~area);
    maskedImage=maskedImage(:,:,1);
    imwrite(maskedImage,fullfile(outfolder,[imageName '.tif']));
    
end



end