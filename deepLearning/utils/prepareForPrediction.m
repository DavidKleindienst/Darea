function sizes=prepareForPrediction(images,outputFolder, selAngles, imSize, adjustContrast)
%Converts image list for prediction
%Return original image sizes (useful for converting back
%If adjustContrast is True, imadjcontrast is applied

if nargin<5
    adjustContrast=false;
end

safeMkdir(outputFolder);
sizes={};
offset=0;
nbytes = fprintf('Preparing image 0 / %i', numel(images));
for img=1:numel(images)
    fprintf(repmat('\b',1,nbytes))
    nbytes = fprintf('Preparing image %i / %i\n', img, numel(images));
    imName=images{img};
    [~, n, ~]=fileparts(imName);
    if endsWith(n, '_dupl')
        offset=offset+1;
        continue;
    end
    outpath=fullfile(outputFolder, int2str(img-offset));
    if isnan(selAngles)
        sizes{end+1} = prepareImageForPrediction(imName, NaN, imSize,outpath, adjustContrast);
    else
        sizes{end+1} = prepareImageForPrediction(imName, selAngles(img), imSize,outpath, adjustContrast);
    end
%     if isnan(selAngles) 
%         outpath=fullfile(outputFolder, int2str(img-offset));
%         sizes{end+1} = prepareImageForPrediction(imName, NaN, imSize,outpath, adjustContrast);
%     elseif selAngles(img)>0
%         %Angle has been selected, only predict that image
%         outpath=fullfile(outputFolder, int2str(img-offset));
%         sizes{end+1} = prepareImageForPrediction(imName, selAngles(img), imSize,outpath, adjustContrast);
%     else
%         %Angle has not been selected, predict all angles
%         [~,angles]=readMdoc([imName '.mdoc']); 
%         for a=1:numel(angles)
%             outpath=fullfile(outputFolder, [int2str(img-offset) '_' int2str(a)]);
%             sizes{end+1} = prepareImageForPrediction(imName, selAngles(a), imSize,outpath, adjustContrast);
%         end
%     end
end

end

