
function success=CopyAndPrepareTrainingImagesFromFolder(infolder,outfolder,settings)

success=false;
safeMkdir(outfolder);
if nargin<3
    settings=readDefaults();
end
infoFile=fullfile(outfolder,'dataset.info');
if isfile(infoFile)
    settings.imageSize=getImageSizeFromInfoFile(infoFile);
    f=fopen(infoFile,'a');
    fprintf(f, '\nUpdated\t%s',  datestr(datetime('now')));
    fclose(f);
else
    f=fopen(infoFile,'w');
    fprintf(f, 'imageSize\t[%i, %i]', settings.imageSize(1),settings.imageSize(2));
    fprintf(f, '\nCreated\t%s',  datestr(datetime('now')));
    fclose(f);
end
% For all subfolders (i.e. different things to be learned) in the folder
features=dir(infolder);
features={features.name};
features=features(~startsWith(features,'.'));

for f=1:numel(features)   

    feat=features{f};
    if isfolder(fullfile(infolder,feat))
       prepareFolderForTrainDataset(outfolder,feat,settings.backgroundColor)
       targetfolder=fullfile(outfolder,feat);

       if ~isfile(fullfile(targetfolder,'configs.csv'))
           oldConfigs={};
       else
           %read previous data 
           old=tdfread(fullfile(targetfolder,'configs.csv'),';');
           oldConfigs=cellstr(old.Name);
           oldHashes=cellstr(old.Hash);
       end
       cfid=fopen(fullfile(targetfolder,'configs.csv'),'w');
       fprintf(cfid,'Name;Hash');

       % For all config files
       configs=getConfigsFromFolder(fullfile(infolder,feat));


       for c=1:numel(oldConfigs)
           conf=oldConfigs{c};
           if sum(strcmp(configs,conf))==0
               %Config has been removed
               %Remove images from Prepared Dataset
               removeConfig(targetfolder,conf);
           end
       end   
       for c=1:numel(configs)
           conf=configs{c};
           sourceFolder=fullfile(infolder,feat);

           hash=Simulink.getFileChecksum(fullfile(sourceFolder,conf));
           if sum(strcmp(oldConfigs,conf))==0
               addConfig(cfid,conf,hash,targetfolder,sourceFolder);
           elseif ~isequal({hash},oldHashes(strcmp(oldConfigs,conf)))
               % Config has changed. Remove all images, then repeat convert
               removeConfig(targetfolder,conf);
               addConfig(cfid,conf,hash,targetfolder,sourceFolder);
           else
               % Config identical
               fprintf(cfid,'\n%s;%s',conf,hash);
           end
       end
       fclose(cfid);
   end
end

success=true;


function configs=getConfigsFromFolder(folder)
    configs=dir(folder);
    configs={configs.name};
    configs=configs(endsWith(configs,'.dat'));
    configs=configs(~endsWith(configs,'_options.dat'));
    configs=configs(~endsWith(configs,'_groups.dat'));
    configs=configs(~endsWith(configs,'_selected.dat'));
    configs=configs(~startsWith(configs,'.'));
end

    
end