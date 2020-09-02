function changeModToRim(datFile)
%% Modifies all demarcation in project to only the outer rim
settings=readDefaults(datFile);
[routes, scales]=readConfig(datFile);
folder=fileparts(datFile);
numImages=numel(routes);
dilate=settings.dilate;
for imgIndex=1:numImages
    route=fullfile(folder,routes{imgIndex});
    scale=scales(imgIndex);
    imageName = [route '.tif'];
    image=imread(imageName);
    imageSelName = [route '_mod.tif'];
    discardedAreas = getBaseImages(imageName, imageSelName);
    if dilate && sum(discardedAreas,'all')>0
        se=strel('diamond', round(dilate/scale));
        %using imerode, since demarcated area has value 0, this will dilate it.
        dil_discardedAreas=imerode(discardedAreas,se);
    end
    rim=~xor(discardedAreas,dil_discardedAreas);
    rimIm=image;
    rimIm(rim)=65535;
    rimIm(~rim)=1337;
    %imshow(rimIm);

    imwrite(rimIm,imageSelName);
end


end

