function sizes=prepareForPrediction(images,outputFolder, imSize, adjustContrast)
%Converts image list for prediction
%Return original image sizes (useful for converting back
%If adjustContrast is True, imadjcontrast is applied

if nargin<4
    adjustContrast=false;
end

safeMkdir(outputFolder);
sizes=cell(1,numel(images));
parfor (img=1:numel(images),getCurrentPoolSize())
    imName=images{img};
    image=imread(imName);
    if ~isa(image, 'uint16')
        msgbox(sprintf('Not all images are 16 bit!\nPlease run the conversion then try again.'));
        error('Not all images are 16 bit! Please run the conversion then try again.');
    end
    if adjustContrast
        image=imadjust(image);
    end
    sizes{img}=[size(image,1),size(image,2)];
    image=prepareImage(image,imSize);
    outpath=fullfile(outputFolder, [int2str(img) '.tif']);
    %Images will be just numbered
    %So you'll need the original image list to backconvert
    imwrite(image,outpath);
end

end

