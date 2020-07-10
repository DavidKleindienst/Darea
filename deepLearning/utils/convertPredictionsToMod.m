function convertPredictionsToMod(predFolder,imList,targetSizes,overwrite)
%CONVERTPREDICTIONSTOMOD Summary of this function goes here
%   Detailed explanation goes here
nrImg=numel(imList);
assert(nrImg==numel(targetSizes))
if ~isfile(fullfile(predFolder,  '1.tif'))
    %not simply numbered file, get files list!
    islist=1;
    files=dir(predFolder);
    files={files.name};
    files=files(~startsWith(files,'.'));
    files=files(endsWith(files,'_pred.tif'));
    assert(numel(files)==nrImg);
else
    files=cell(1,nrImg);
    %When doing parfor, files needs to be of appropriate size even when
    %islist is 0, because files{img} is broadcast (I think)
    islist=0;
end
parfor (img=1:nrImg, getCurrentPoolSize())
    if ~overwrite && isfile(imList{img})
        %Skip image if it exists and should not be overwritten
        continue;
    end
    %Assumes images in predFolder are just numbered (as made by prepareForPrediction.m)
    if islist
        
        image=imread(fullfile(predFolder, files{img}));
    else
        image=imread(fullfile(predFolder, [int2str(img) '.tif']));
    end
    image=convertPredtoMask(image,targetSizes{img});
    imwrite(image,imList{img});
end


end

