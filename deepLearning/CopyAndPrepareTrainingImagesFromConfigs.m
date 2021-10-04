function CopyAndPrepareTrainingImagesFromConfigs(configs, outfolder, feature, featureByGroup, settings)
%COPYANDPREPARETRAININGIMAGESFROMCONFIGS Summary of this function goes here
%   Detailed explanation goes here
% if featureByGroup is true, feature should be the groupname


configs=configs(endsWith(configs,'.dat'));
configs=configs(~endsWith(configs,'_options.dat'));
configs=configs(~endsWith(configs,'_groups.dat'));
configs=configs(~endsWith(configs,'_selected.dat'));
configs=configs(~startsWith(configs,'.'));

if featureByGroup
   %Ensure all configs have the necessary group
    for c=1:numel(configs)
        
        groups=readGroups(configs{c});
        if ~ismember(groups, feature)
            sprintf('Project %s does not contain group "%s". Aborting...', configs{c}, feature)
            return
        end
    end
end
safeMkdir(outfolder);

if ~isfile(fullfile(targetfolder,'configs.csv'))
   oldConfigs={};
   prepareFolderForTrainDataset(outfolder,'.',settings.backgroundColor)
else
   %read previous data 
   old=tdfread(fullfile(targetfolder,'configs.csv'),';');
   oldConfigs=cellstr(old.Name);
   oldHashes=cellstr(old.Hash);
end

for c=1:numel(configs)
    
    
    
end

end

