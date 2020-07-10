function string=replaceSlash(string)
    %When preparing for particle prediction, we want to pool training data of
    %all features, but config files in different feature folders may have same
    %name.
    %We therefore record them as either "feature/config.dat" (in text files) or
    %feature__config.dat (in actual filenames)
    string=strrep(string, '/', '__');
    string=strrep(string, '\', '__');
end