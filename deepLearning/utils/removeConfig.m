function removeConfig(targetfolder,conf)
    conf=replaceSlash(conf);
    infoFile=fullfile(targetfolder, [conf(1:end-4) '.csv']);
    info=tdfread(infoFile,';');
    images=cellstr(info.Name);
    folder=cellstr(info.Type);
    for img=1:numel(images)
       imfile=fullfile(targetfolder,folder{img}, images{img});
       imlabel=fullfile(targetfolder,[folder{img} '_labels'], images{img});
       delete(imfile);
       delete(imlabel);
    end
    delete(fullfile(targetfolder, [conf(1:end-4) '.csv']));
end