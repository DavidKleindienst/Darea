function preprocess(datFile, convert, invert, contrast, downscale,downscalePx, hProgress)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% ToDo: Dealing with dots.csv when downscaling. Edit .mdoc for new pixelsize.

    function [image,flag,newScale] = doConversion(image,scale,route,convert,invert,contrast,downscale,downscalePx,type)
        flag=0;
        newScale=scale;
        if downscale && (downscalePx(1)<size(image,1) || downscalePx(2)<size(image,2))
            aspectRatioChange=(size(image,1)/downscalePx(1))/(size(image,2)/downscalePx(2));
            if type==1
                newScale=scale*mean([size(image,1)/downscalePx(1),size(image,2)/downscalePx(2)]);
            end
            if aspectRatioChange<1; aspectRatioChange=1/aspectRatioChange; end
            if aspectRatioChange>1.05 && type==1  % 5% difference should usually be acceptable
                fprintf(['Warning: Aspect ratio for image %s was changed by %.1f %%. The new' ...
                         'pixelsize will be inaccurate. This may lead to wrong measurements\n'],...
                         route, (aspectRatioChange-1)*100);
            end
            if type==1
                image=imresize(image,downscalePx);
            else
                image=imresize(image,downscalePx, 'nearest');
            end
            flag=1;
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

if ~convert && ~invert && ~contrast && ~downscale
    %Nothing to do
    return;
end

[path, file,fileextension]=fileparts(datFile);

[routes,scales,selAngle]=readConfig([fullfile(path,file) fileextension]);
isSerEM=any(~isnan(selAngle));
if downscale
    newScales=scales;
end
fprintf('Processing Images:\n');
drawnow();
for imgIndex=1:numel(routes)
    if nargin==5
        hProgress.String=sprintf('Processing image %g of %g', imgIndex, numel(routes));
        drawnow();
    end
    for type=1:2
        %Type 1 - Original image; type 2 - demarcation
        newScale=NaN;
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
                newScales(imgIndex)=NaN;
            end
            continue;
        end
        
        if type==1 && isSerEM
            flag=0;
            if downscale
                newImages=zeros(min(downscalePx(1), size(images,1)), ...
                                min(downscalePx(2), size(images,2)), ...
                                size(images,3), class(images));
            else
                newImages=zeros(size(images), class(images));
            end
            for i=1:size(images,3)
                [image, fl,newScale] = doConversion(images(:,:,i),scales(imgIndex),route,0,invert,contrast,downscale,downscalePx,type);
                % There is some issue with saving or reading uint16 MRC images, leading to strange
                % contrast. Thus convert is always 0
                flag=flag|fl;
                newImages(:,:,i) = image;
            end
            images=newImages;
        else
            [image,flag,newScale]=doConversion(image,scales(imgIndex),route,convert,invert,contrast,downscale,downscalePx,type);
        end
        if flag && type==1
            newScales(imgIndex)=newScale;
        end
        if flag && type==1 && isSerEM         %Save if anything was changed
            if convert
                encoding=6;
            elseif isa(images,'int16')
                encoding=1;
            else
                error('Cannot save Images in same format (%s). Converting to 16bit is necessary.',...
                       class(images));
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

if downscale && any(newScales~=scales)
    indeces=1:numel(newScales);
    
    if any(isnan(newScales))
        %Probably _dupl images, but may be missing image too
        %For _dupl, get the newScale of original image. Then get rid of other NaNs
        nanIdx=find(isnan(newScales));
        toDel=[];
        
        for i=1:numel(nanIdx)
           if endsWith(routes{nanIdx(i)}, '_dupl')
               
               idx=strcmp(routes,removeDuplsFromName(routes{nanIdx(i)}));
               if any(idx)
                   newScales(nanIdx(i))=newScales(idx);
               end
           end
           if isnan(newScales(nanIdx(i)))
               toDel=[toDel nanIdx(i)];
           end
        end
        
        newScales(toDel)=[];
        indeces(toDel)=[];
    end
    
    pyIndeces=py.list(cellfun(@py.int,num2cell(indeces-1),'UniformOutput', false));
    pyScales=py.list(cellfun(@py.float,num2cell(newScales'),'UniformOutput', false));
    py.makeProjectFile.changeScales(datFile,pyIndeces,pyScales);
end

fprintf('\nPreprocessing finished.\n');

end

