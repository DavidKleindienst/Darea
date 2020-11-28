function makeMissingDemarcations(folder)
%% Make all missing _mod files as background
%% All images have to have the same size!
files=dir(folder);
files={files.name};
files=files(~startsWith(files,'.'));
imgs=files(endsWith(files,'.tif'));
mods=imgs(endsWith(imgs,'_mod.tif'));

missing=imgs(~ismember(imgs,mods));
mods=cellfun(@(x)[x(1:end-8) '.tif'], mods, 'UniformOutput', false);
missing=missing(~ismember(missing,mods));

missing=cellfun(@(x)fullfile(folder,x), missing, 'UniformOutput', false);
im=readAndConvertImage(missing{1});
s=size(im);
modImg=ones(s)*65535;

modPaths=cellfun(@(x)[x(1:end-4) '_mod.tif'], missing, 'UniformOutput', false);

for i=1:numel(modPaths)
    imwrite(modImg,modPaths{i});
end

end

