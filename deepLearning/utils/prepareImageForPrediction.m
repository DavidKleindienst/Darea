function imageSize = prepareImageForPrediction(imName,angle, imSize, outpath, adjustContrast)
    if isnan(angle) || angle ~= 0
        if isnan(angle)
            image=readAndConvertImage([imName '.tif']);
        else
            image=readAndConvertImage(imName,angle);
        end
        if adjustContrast
            image=imadjust(image);
        end
        imageSize=[size(image,1),size(image,2)];
        image=prepareImage(image,imSize);

        %Images will be just numbered
        %So you'll need the original image list to backconvert
        imwrite(image,[outpath '.tif']);
    else
        %Forloop
        [~, angles] = readMdoc([imName '.mdoc']);
        
        for a=1:numel(angles)
            image=readAndConvertImage(imName,a);
            if adjustContrast
                image=imadjust(image);
            end
            if a==1 %Is same for all angles anyway
                imageSize=[size(image,1),size(image,2)]; 
            end
            image=prepareImage(image,imSize);

            %Images will be just numbered
            %So you'll need the original image list to backconvert
            imwrite(image,[outpath '_' int2str(a) '.tif']);
        end
        
    end


end