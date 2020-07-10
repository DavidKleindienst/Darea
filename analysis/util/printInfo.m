function  printInfo(Data,filename)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
fid=fopen(filename, 'w');
Images=Data.Orig.Images;
fprintf(fid,'Image Id;Route;Group;Scale [nm/px]');
for i=1:numel(Images)
    fprintf(fid,'\n%g;%s;%s;%g', Images{i}.id,Images{i}.route,Data.Groups.names{Data.Groups.imgGroup(i)},Images{i}.scale);
end

