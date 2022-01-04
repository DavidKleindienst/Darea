function files = findFilesinFolder(folder,suffix,prefix,showHidden)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin<2
    suffix='';
end
if nargin<3
    prefix='';
end
if nargin<4
    showHidden=false;
end

files = dir(folder);
files = {files.name};

if ~showHidden
    files = files(~startsWith(files,'.'));
end

files = files(startsWith(files,prefix));
files = files(endsWith(files,suffix));

end

