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
    for type=1:2
        %Type 1 - Original image; type 2 - demarcation
        
        flag=0;
        if type==1
            route = fullfile(path,[routes{imgIndex} '.tif']);
        else
            route = fullfile(path,[routes{imgIndex} '_mod.tif']);
        end
        try
            image=imread(route);
        catch
            if type==1
                fprintf('Image %s could not be opened', route);
            end
            continue;
        end
        if convert
            if size(image,3)==3         %If image is RGB, convert to grayscale
                image=rgb2gray(image);
                flag=1;
            end
            if isa(image, 'uint8') || isa(image, 'int8') || isa(image, 'double')     %If image is 8bit
                image=im2uint16(image);     %Convert to 16 bit
                flag=1;
            elseif isa(image, 'int16')
                image=im2uint16(image)-32768;
                flag=1;
            elseif ~isa(image, 'uint16')
                fprintf('Image is of type %s, no conversion has been implemented for this type', class(image));
            end
        end

        if invert && type==1
            image=imcomplement(image);
            flag=1;
        end

        if contrast && type==1
            image=imadjust(image);
            flag=1;
        end

        if flag         %Save if anything was changed
            imwrite(image,route);  
        end
    end
        
    if nargin<5 && mod(imgIndex,5)==1
        fprintf('.');           %print . every 5 images to show progress
    end 
end
fprintf('\nPreprocessing finished.\n');

end

