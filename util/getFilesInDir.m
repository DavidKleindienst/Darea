function files = getFilesInDir(folder, suffix)
%% Returns cell array of files in folder
%Hidden files are ignored
%if suffix is specified, only files with that suffix are returned

files=dir(folder);
files={files.name};
files=files(~startsWith(files, '.'));
if nargin>1
    files=files(endsWith(files, suffix));
end

end

