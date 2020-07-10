function removeGroupFromConfig(config,grouping,group,newConfig)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[groupnames, grps]=readGroups(config);

idx=find(cellfun(@(x)strcmp(x,grouping),groupnames), 1);

if isempty(idx)
    fprintf('Grouping %s does not exist in this config\n', grouping);
    return;
end

if nargin>3
    copyfile(config,newConfig);
    if isfile([config(1:end-4) '_options.dat'])
        copyfile([config(1:end-4) '_options.dat'], [newConfig(1:end-4) '_options.dat']);
    end
    if isfile([config(1:end-4) '_groups.dat'])
        copyfile([config(1:end-4) '_groups.dat'], [newConfig(1:end-4) '_groups.dat']);
    end
    config=newConfig;
end

indeces=find(cellfun(@(x)strcmp(x,group),grps(:,idx)));

if ~isempty(indeces)
    py.makeProjectFile.removeImage(config,py.list(int32(indeces-1)));
end


end

