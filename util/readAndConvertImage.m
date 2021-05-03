function image = readAndConvertImage(filename,imNr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~isfile(filename)
    % Duplicated image doesn't need to be stored, so remove _dupls and find original filename
    [a,n,e]=fileparts(filename);
    while endsWith(n,'_dupl')
        n=n(1:end-5);
    end
    filename=fullfile(a,[n e]);
end


if endsWith(filename,'.tif')
    image=imread(filename);
else
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

