
function CopyAndPrepareTrainingImages(infolder,outfolder,predictParticles)
if predictParticles
    nrModes=2;
else
    nrModes=1;
end
%Particle prediction is experimental


safeMkdir(outfolder);
settings=readDefaults();

% For all subfolders (i.e. different things to be learned) in the folder
features=dir(infolder);
features={features.name};
features=features(~startsWith(features,'.'));
particleColors=NaN;
for mode=1:nrModes % 1 Feature Detection; 2 Particle Detection
    if mode==2
        prepareFolderForTrainDataset(outfolder,'Particles',settings)
    end
    if mode==1; numRepeats=numel(features); else; numRepeats=1; end
    for f=1:numRepeats   

        feat=features{f};
        if mode==2 || isfolder(fullfile(infolder,feat))
           if mode==1
               prepareFolderForTrainDataset(outfolder,feat,settings)
               targetfolder=fullfile(outfolder,feat);
           else
               targetfolder=fullfile(outfolder,'Particles');
           end
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
           
           if mode==2
               % Get all the configs accross different features
               configs=cellfun(@(x)fullfile(feat,x), configs, 'UniformOutput', false);
               for ff=2:numel(features)
                   feat=features{ff};
                   confs=getConfigsFromFolder(fullfile(infolder,feat));
                   confs=cellfun(@(x)fullfile(feat,x), confs, 'UniformOutput', false);
                   configs=[configs confs];
               end
               fullPathConfs=cellfun(@(x)fullfile(infolder,x), configs, 'UniformOutput', false);
               particleColors=getParticleColors(fullfile(targetfolder, 'class_dict.csv'), fullPathConfs);
               
               %make class_dict.csv
               classes=fieldnames(particleColors);
               fid=fopen(fullfile(targetfolder,'class_dict.csv'), 'w');
               fprintf(fid,'name,r,g,b');
               for cl=1:numel(classes)
                   color=particleColors.(classes{cl});
                   fprintf(fid,'\n%s,%i,%i,%i', classes{cl},color,color,color);
               end
               fclose(fid);
               
           end
               
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
               if mode==1
                   fuseDuplImages(fullfile(infolder,feat,conf));
                   sourceFolder=fullfile(infolder,feat);
               else
                   sourceFolder=infolder;
               end
               hash=Simulink.getFileChecksum(fullfile(sourceFolder,conf));
               if sum(strcmp(oldConfigs,conf))==0
                   addConfig(cfid,conf,hash,targetfolder,sourceFolder,particleColors);
               elseif ~isequal({hash},oldHashes(strcmp(oldConfigs,conf)))
                   % Config has changed. Remove all images, then repeat convert
                   removeConfig(targetfolder,conf);
                   addConfig(cfid,conf,hash,targetfolder,sourceFolder,particleColors);
               else
                   % Config identical
                   fprintf(cfid,'\n%s;%s',conf,hash);
               end
           end
           fclose(cfid);
       end
    end
end

function addConfig(cfid,conf,hash,targetfolder,inFile,particleColors)
    % Config was not copied previously
   fprintf(cfid,'\n%s;%s',conf,hash);
   fullfile(targetfolder,replaceSlash([conf(1:end-3) 'csv']))
   ifid=fopen(fullfile(targetfolder,replaceSlash([conf(1:end-3) 'csv'])),'w');
   fprintf(ifid,'OriginalRoute;Name;ImageSize;Type');
   copyAndPrepareFromConfig(inFile,conf,targetfolder,ifid,particleColors);
   fclose(ifid); 
end
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
function configs=getConfigsFromFolder(folder)
    configs=dir(folder);
    configs={configs.name};
    configs=configs(endsWith(configs,'.dat'));
    configs=configs(~endsWith(configs,'_options.dat'));
    configs=configs(~endsWith(configs,'_groups.dat'));
    configs=configs(~endsWith(configs,'_selected.dat'));
    configs=configs(~startsWith(configs,'.'));
end
function colors=getParticleColors(classCsv, configs)
    classes=tdfread(classCsv,',');
    assert(all(classes.r==classes.g & classes.g==classes.b))
    r=classes.r;
    names=cellstr(classes.name);
    for c=1:numel(names)
        colors.(names{c})=r(c);
    end
    sets=readDefaults();
    r=[r;sets.foregroundColor(1)];
    fields=fieldnames(colors);
    for c=1:numel(configs)
        conf=configs{c};
        sets=readDefaults(conf);
        pT=num2cell(sets.particleTypes);
        pT=cellfun(@(x) ['nm' num2str(x)], pT, 'UniformOutput', false);
        for p=1:numel(pT)
            while ~ismember(pT{p}, fields)
                col=randi([1,255]);
                if ~ismember(col,r)
                    colors.(pT{p})=col;
                    r=[r; col];
                    fields=[fields; pT{p}];
                end
            end
        end
    end
end
    
end