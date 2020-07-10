function infoGroups = getInfoGroups(datFile, chosenGroups)
%   Gets information about which group(s) each image belongs to.
%   infoGroups: cell array containing information related to the groups.
%
%   infoGroups.groupings:               Variables by which it was grouped
%   infoGroups.number:                  Number of groups.
%   infoGroups.names:                   Cell array with the name of each group.
%   infoGroups.imgGroup:                Array with the index of the group each image belongs to.

% Input arguments:
% datFile: infoFile of the project (see Men

if nargin<2
    chosenGroups=1;
end
infoGroups.chosenGroups=chosenGroups;
[groupnames, groups]=readGroups(datFile);
groupnames=groupnames(chosenGroups);
groups=groups(:,chosenGroups);

infoGroups.groupings=groupnames;
fusedGroups=cell(size(groups,1),1);
for g=1:size(groups,1)
    fusedGroups{g}=strjoin(groups(g,:),'_');
end
infoGroups.names=unique(fusedGroups);
infoGroups.number=numel(infoGroups.names);
imgGroup=zeros(numel(fusedGroups),1);
for g=1:numel(fusedGroups)
    imgGroup(g)=find(strcmp(infoGroups.names, fusedGroups{g}));
end
infoGroups.imgGroup=imgGroup;
