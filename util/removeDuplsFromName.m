function name = removeDuplsFromName(name)
% Removes all _dupl suffixes from name or filename
flag=0;
if ~endsWith(name, '_dupl')
    %It maybe a filename, remove extension and check again
    [folder, fn, ext] = fileparts(name);
    if ~endsWith(fn, '_dupl')
        return;
    end
    flag=1;
    name=fn;
end
while endsWith(name, '_dupl')
    name=name(1:end-5);
end
if flag
    name=fullfile(folder, [name ext]);
end

end