function success=CopyAndPrepareTrainingImagesFromConfigs(configs, outfolder, feature, settings)
%COPYANDPREPARETRAININGIMAGESFROMCONFIGS Summary of this function goes here
%   Detailed explanation goes here
% if featureByGroup is true, feature should be the groupname

success=false;
safeMkdir(outfolder);
       
configs=configs(endsWith(configs,'.dat'));
configs=configs(~endsWith(configs,'_options.dat'));
configs=configs(~endsWith(configs,'_groups.dat'));
configs=configs(~endsWith(configs,'_selected.dat'));
configs=configs(~startsWith(configs,'.'));


safeMkdir(outfolder);
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

if ~isfile(fullfile(outfolder,'feature.info'))
   prepareFolderForTrainDataset(outfolder,'.',settings.backgroundColor)
   offset=0;
else
   %read previous data 
   fid=fopen(fullfile(outfolder,'feature.info'), 'r');
   oldInfo=split(fgetl(fid),';');
   oldFeature=oldInfo{1};
   offset=str2double(oldInfo{2});
   fclose(fid);
   if oldFeature ~= feature
       msgbox(sprintf(['At this location a dataset for feature "%s" already exists\n' ...
               'Cannot combine the old dataset with the new dataset of different feature "%s".\n' ...
               'Please either select a different folder or use the same name as feature!'], ...
               oldFeature, feature));
       return;
   end
   
end

for c=1:numel(configs)
   fprintf('Processing config %i of %i\n', c, numel(configs));
   [path,conf,ext]=fileparts(configs{c});
   conf=[conf ext];
   nrImages=copyAndPrepareFromConfig(path,conf,outfolder,NaN,settings, offset);
   offset=offset+nrImages;
    
end
fid=fopen(fullfile(outfolder,'feature.info'), 'w');
fprintf(fid, '%s;%i', feature,offset);
fclose(fid);
success=true;
end

