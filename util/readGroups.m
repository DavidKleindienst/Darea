function [groupnames, groups, routes] = readGroups(datFile)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
filename=[datFile(1:end-4) '_groups.dat'];

if nargout>1
    [routes,~,groups]=readConfig(datFile);
end

if ~isfile(filename)
    groupnames={'Folder'};
    return
end

% T=readtable(filename, 'delimiter', ',');
% groupnames=T.Properties.VariableNames(2:end);

G=tdfread(filename,',');
header=fieldnames(G);
groupnames=header(2:end);

if nargout>1
    [routes,~,groups]=readConfig(datFile);
    cfGroups=groups;
    %tbl=table2cell(T);
    %tbl=cellfun(@num2str, tbl, 'UniformOutput', false);
    tbl=cellfun(@(x)cellstr(num2str(G.(x))),header, 'UniformOutput', false);
    tbl=horzcat(tbl{:});
    groups=tbl(:,2:end);
    g_imgs=tbl(:,1);
    
    if ~isequal(routes,g_imgs)
        % If config file has changed since assigning groups
        % groups needs to be adapted (i.e. empty groups for new images added; 
        % and groups for images which have been removed need to be removed)
        diffs=setdiff(g_imgs,routes);
        for i=1:numel(diffs)
            % Image was set in group, but later deleted from config
            % -> Get rid of the line in groups
            groups(ismember(g_imgs,diffs{i}),:)=[];
            g_imgs(ismember(g_imgs,diffs{i}))=[];
        end
        diffs=setdiff(routes, g_imgs);
        for i=1:numel(diffs)
            % New Image has been added to config
            % We need to add a new line to groups but be careful to do
            % it at correct position
            idx=find(ismember(routes,diffs{i}));
            newline=cell(1,size(groups,2));
            if idx>1 && endsWith(routes{idx}, '_dupl') && strcmp(routes{idx}(1:end-5),routes{idx-1})
                %New Image is a duplicate, copy the groups from the original image
                newline(:)=groups(idx-1,:);
            else
                newline{1}=cfGroups{idx,1};
                newline(cellfun('isempty',newline))={''};
            end
            
            if idx==1
                groups=[newline; groups];
            elseif idx>size(groups,1)
                groups=[groups; newline];
            else
                groups=[groups(1:idx-1,:); newline; groups(idx:end,:)];
            end            
        end
    end
end

end

