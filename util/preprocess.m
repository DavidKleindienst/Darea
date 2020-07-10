function preprocess(datFile, convert, invert, contrast, hProgress)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ~convert && ~invert && ~contrast
    %Nothing to do
    return;
end

[path, file,fileextension]=fileparts(datFile);

routes=readConfig([fullfile(path,file) fileextension]);

fprintf('Processing Images:\n');

for imgIndex=1:numel(routes)
    if nargin==5
        hProgress.String=sprintf('Processing image %g of %g', imgIndex, numel(routes));
        drawnow();
    end
    flag=0;
    route = fullfile(path,[routes{imgIndex} '.tif']);
    image=imread(route);
    if convert
        if size(image,3)==3         %If image is RGB, convert to grayscale
            image=rgb2gray(image);
            flag=1;
        end
        if isa(image, 'uint8') || isa(image, 'int8') || isa(image, 'int16')      %If image is 8bit
            image=im2uint16(image);     %Convert to 16 bit
            flag=1;
        elseif ~isa(image, 'uint16')
            fprintf('Image is of type %s, no conversion has been implemented for this type', class(image));
        end
    end
    
    if invert
        image=imcomplement(image);
        flag=1;
    end
        
    if contrast
        image=imadjust(image);
        flag=1;
    end
     
    if flag         %Save if anything was changed
        imwrite(image,route);  
    end
        
    if nargin<5 && mod(imgIndex,5)==1
        fprintf('.');           %print . every 5 images to show progress
    end 
end
fprintf('\nPreprocessing finished.\n');

end

