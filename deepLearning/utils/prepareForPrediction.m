function sizes=prepareForPrediction(images,outputFolder, selAngles, imSize, adjustContrast)
%Converts image list for prediction
%Return original image sizes (useful for converting back
%If adjustContrast is True, imadjcontrast is applied

if nargin<5
    adjustContrast=false;
end

safeMkdir(outputFolder);
sizes=cell(1,numel(images));
parfor (img=1:numel(images),getCurrentPoolSize())
    imName=images{img};
    if isnan(selAngles)
        outpath=fullfile(outputFolder, int2str(img));
        sizes{img} = prepareImageForPrediction(imName, NaN, imSize,outpath, adjustContrast);
    else
        
    end
end
end

