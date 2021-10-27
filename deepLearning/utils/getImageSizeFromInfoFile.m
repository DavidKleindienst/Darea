function imageSize = getImageSizeFromInfoFile(infoFile)
%GETIMAGESIZE Summary of this function goes here
%   Detailed explanation goes here
imageSize=NaN;  %In case none is found in the file
if ~isfile(infoFile)
    error('File %s not found', infoFile);
end
f=fopen(infoFile,'r');
tline=fgetl(f);
while ischar(tline)
    if ~isempty(tline)
        s=strsplit(tline,'\t');
        if strcmp(s{1}, 'imageSize')
            imageSize=eval(s{2});
        end
    end
    tline=fgetl(f);
end
fclose(f);
end

