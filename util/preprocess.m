function preprocess(datFile, convert, invert, contrast, hProgress)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    function [image,flag] = doConversion(image,convert,invert,contrast,type)
        flag=0;
        
        if convert
            if size(image,3)==3         %If image is RGB, convert to grayscale
                image=rgb2gray(image);
                flag=1;
            end
            if isa(image, 'uint8') || isa(image, 'int8') || isa(image, 'double')     %If image is 8bit
                image=im2uint16(image);     %Convert to 16 bit
                flag=1;
            elseif isa(image, 'int16')
                if min(min(image))<0
                    image=im2uint16(image);
                else
                    image=im2uint16(image)-32768;
                end
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
    end

if ~convert && ~invert && ~contrast
    %Nothing to do
    return;
end

[path, file,fileextension]=fileparts(datFile);

[routes,~,~,~,selAngle]=readConfig([fullfile(path,file) fileextension]);
isSerEM=any(~isnan(selAngle));

fprintf('Processing Images:\n');
drawnow();
for imgIndex=1:numel(routes)
    if nargin==5
        hProgress.String=sprintf('Processing image %g of %g', imgIndex, numel(routes));
        drawnow();
    end
    for type=1:2
        %Type 1 - Original image; type 2 - demarcation
        
        if type==1
            if isSerEM
                route=fullfile(path,routes{imgIndex});
            else
                route = fullfile(path,[routes{imgIndex} '.tif']);
            end
        else
            route = fullfile(path,[routes{imgIndex} '_mod.tif']);
        end
        try
            if type==1 && isSerEM
                [images, s]=ReadMRC(route);
            else
                image=imread(route);
            end
        catch
            if type==1
                fprintf('Image %s could not be opened\n', route);
            end
            continue;
        end
        
        if type==1 && isSerEM
            flag=0;
            for i=1:size(images,3)
                [image, fl] = doConversion(images(:,:,i),0,invert,contrast,type);
                % There is some issue with saving or reading uint16 MRC images, leading to strange
                % contrast. Thus convert is always 0
                flag=flag|fl;
                images(:,:,i) = image;
            end
            
        else
            [image,flag]=doConversion(image,convert,invert,contrast,type);
        end

        if flag && type==1 && isSerEM         %Save if anything was changed
            if convert
                encoding=6;
            elseif isa(images,'int16')
                encoding=1;
            else
                error('Cannot save Images in same format without converting to 16bit');
            end
            WriteMRC(images,s.pixA,route,encoding)
        elseif flag
            imwrite(image,route);  
        end
    end
        
    if nargin<5 && mod(imgIndex,5)==1
        fprintf('.');           %print . every 5 images to show progress
    end 
end
fprintf('\nPreprocessing finished.\n');

end

