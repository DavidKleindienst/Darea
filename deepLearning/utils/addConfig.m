function addConfig(cfid,conf,hash,targetfolder,configFolder)
    % Config was not copied previously
    fprintf(cfid,'\n%s;%s',conf,hash);
    fullfile(targetfolder,replaceSlash([conf(1:end-3) 'csv']))
    ifid=fopen(fullfile(targetfolder,replaceSlash([conf(1:end-3) 'csv'])),'w');
    fprintf(ifid,'OriginalRoute;Name;ImageSize;Type');
    copyAndPrepareFromConfig(configFolder,conf,targetfolder,ifid);
    fclose(ifid); 
end