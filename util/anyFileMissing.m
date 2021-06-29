function anyFileMissing(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[path, file,fileextension]=fileparts(datFile);

routes=readConfig([fullfile(path,file) fileextension]);

for i=1:numel(routes)
    for j=1:3
       switch j
           case 1
               ending='.tif';
           case 2
               ending='_mod.tif';
           case 3 
               ending='dots.csv';
       end
    end
    filename=fullfile(path,[routes{i} ending]);
    
    if ~isfile(filename)
        fprintf('File %s is missing\n', filename);
    end
end
end


