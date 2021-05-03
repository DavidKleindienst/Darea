function [pixelsize,angles] = readMdoc(file)
%% Reads relevant values from a serialEM .mdoc file

function num = getNum(line)
    %Gets the value after the = sign, and converts to double
    line = split(line,'=');
    num = str2double(strip(line{2}));
end



pixelspacing=[];
angles=[];

fid = fopen(file);
line = fgetl(fid);
while ischar(line)
    if startsWith(line,'PixelSpacing')
        pixelspacing(end+1)=getNum(line);
    elseif startsWith(line, 'TiltAngle')        
        angles(end+1)=getNum(line);
    end
    line = fgetl(fid);
end
fclose(fid);


if  numel(unique(pixelspacing))>1
    error('Different pixelsizes found in .mdoc file');
end

pixelsize=pixelspacing(1)*0.1;

end

