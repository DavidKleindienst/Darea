function image = readAndConvertImage(filename,imNr)
%% Reads image from pathname and converts it to proper bitdepth
% If it is a duplicated image (ending with '_dupl' suffix)
% Original image without that suffix is found

if ~isfile(filename)
    % Duplicated image doesn't need to be stored, so remove _dupls and find original filename
    if endsWith(filename,'.tif')
    
        [a,n,e]=fileparts(filename);
        while endsWith(n,'_dupl')
            n=n(1:end-5);
        end
        filename=fullfile(a,[n e]);
    elseif endsWith(filename,'_dupl')
        filename=filename(1:end-numel('_dupl'));
    end
end


if endsWith(filename,'.tif')
    try
        image=imread(filename);
    catch exc
        fprintf(['Failed reading image ' filename ' with following error']);
        rethrow(exc);
    end
    
else
    if imNr == 0
        %No image has been selected, use the first one
        %This should not happen, functions calling this function should already
        %correct for it, so issue warning
        warning('No angle has been selected for image %s, using first image', filename);
        imNr=1;
    end
    image=ReadMRC(filename,imNr,1);
    image=flip(image');
end
% Necessary type conversions:
if size(image,3)==3         %If image is RGB, convert to grayscale
    image=rgb2gray(image);
end
if isa(image, 'uint8') || isa(image, 'int8')      %If image is 8bit
    image=im2uint16(image);     %Convert to 16 bit
elseif isa(image, 'int16')
    if min(min(image))<0
        image=im2uint16(image);
    else
        image=im2uint16(image)-32768;
    end
end

end

