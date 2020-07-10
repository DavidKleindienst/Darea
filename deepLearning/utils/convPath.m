function path=convPath(path)
%% Converts a path for usage by python called through shell command

    %Replaces Backslashes with forward slashes for Windows compatibility
    path=strrep(path,'\','/');
    path=char(py.os.path.abspath(path));
end
