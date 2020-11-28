function setContrast(images,minmax)
%% Converts images by applying contrast
% images can be path to single image, or config file or a folder.
% If minmax is set to NaN, will use autocontrasting

if nargin<2
    minmax=NaN;
end
    function performContrast(imageName,minmax)
        im=readAndConvertImage(imageName);
        
        if isnan(minmax)
            im=imadjust(im);
        else
            im=imadjust(im,[minmax(1),minmax(2)]);
        end
        %If image was rgb, convert it back
        if rgbflag
            im = cat(3, im, im, im);
        end
        
        imwrite(im,imageName);
    end

if endsWith(images,'.dat')
    routes=readConfig(images);
    routes=getFullRoutes(routes,images);
    numImages = size(routes,1);

    for imgIndex=1:numImages
        imageName = [routes{imgIndex} '.tif'];         
        performContrast(imageName,minmax)
        %now same for mod image if it exists
        imageName=[routes{imgIndex} '_mod.tif'];
        if isfile(imageName)
            performContrast(imageName,minmax)
        end
    end
elseif endsWith(images,'.tiff') || endsWith(images, '.tif')
    performContrast(images,minmax); 
elseif isfolder(images)    
    imFiles=dir(fullfile(images,'*.tif'));
    for imgIndex=1:numel(imFiles)
        imageName=fullfile(images,imFiles(imgIndex).name);
        performContrast(imageName,minmax);
    end
end
end

%last time we used [0.065,0.16]