function groupMenu(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin==0
    [infoFile, folder] = uigetfile('*.dat');
    datFile=fullfile(folder,infoFile);
end
[groupnames, groups, routes]=readGroups(datFile);
groupnames=groupnames';


positionFigure =  [25, 50, 850, 505];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none','Name', 'Assign Groups'); 
set(mainFigure, 'CloseRequestFcn', @close);


hImageList=uicontrol('Style', 'listbox', 'String', routes, 'min', 0, 'max', numel(routes), ...
                   'Position', [30 60 300 400], 'Callback', @listclick);
[hGroupNames, hGroups, hRem]=makeGroupFields();
listclick(0,0);

uicontrol('Style', 'pushbutton', 'String', 'Add Grouping', 'Callback', @addGrp, 'Position', [340 440 80 25]);

uicontrol('Style', 'pushbutton', 'String', 'Assign group(s) by image', 'Tooltipstring', 'Look through all images and decide on the group',...
            'Callback', @choiceByImage, 'Position', [380 100 180 25]);

hSave=uicontrol('Style', 'pushbutton', 'String', 'Save', 'Tooltipstring', 'Save', 'Position', [380 60 90 30], 'Callback', @save);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [490 60 90 30], 'Callback', @close);

waitfor(mainFigure);

function changeGrpName(hOb,~)
    hOb.String=strrep(hOb.String, ' ', '_');
    groupnames{hOb.idx}=hOb.String;
    
end

function choiceByImage(~,~)
    [groupings,results]=chooseGroupByImage(groupnames, datFile);
    if isnan(results)
        %Was cancelled
        return;
    end
    for g=1:numel(groupings)
        idx=strcmp(groupnames,groupings{g});
        for i=1:size(results,1)
            groups{i,idx}=results{i,g+1};
        end
    end
    
    listclick(0,0);
end

function changeGrp(hOb, ~)
    for v=1:numel(hImageList.Value)
        groups{hImageList.Value(v),hOb.idx}=hOb.String;
    end
end
function removeGrp(hOb, ~)
    groups(:,hOb.idx)=[];
    groupnames(hOb.idx)=[];
    [hGroupNames, hGroups, hRem]=makeGroupFields(hGroupNames, hGroups, hRem);
    listclick(0,0);
end
function addGrp(~,~)
    groupnames{end+1}='NewGroup';
    newgrp=cell(numel(routes),1);
    newgrp(:)={''};
    groups=[groups, newgrp];
    [hGroupNames, hGroups, hRem]=makeGroupFields(hGroupNames, hGroups, hRem);
    listclick(0,0);
end

function listclick(~,~)
    val=hImageList.Value;
    for g=1:numel(groupnames) 
        selGrps=unique(groups(val,g));
        if numel(selGrps)>1
            set(hGroups(g), 'String', '(Multiple Values)');
        elseif numel(selGrps)<1 || isempty(selGrps{1})
            set(hGroups(g), 'String', '(No Value)');
        else
            set(hGroups(g), 'String', selGrps{1});
        end
    end
end
function [hGroupNames, hGroups, hRem]=makeGroupFields(hGroupnames, hGroups, hRem)
    if nargin>0
        delete(hGroupnames);
        delete(hGroups);
        delete(hRem);
    end
    nrGrps=numel(groupnames);
    hGroupNames=gobjects(1,nrGrps);
    hGroups=gobjects(1,nrGrps);
    hRem=gobjects(1,nrGrps-1);
    for g=1:nrGrps
        hGroupNames(g)=uicontrol('Style', 'Edit', 'Callback', @changeGrpName, 'Tooltipstring', 'Name of Grouping', ...
                        'String', groupnames{g}, 'Position', [360+(g-1)*90 400 80 25]);
        hGroups(g)=uicontrol('Style', 'Edit', 'Callback', @changeGrp, 'Tooltipstring', 'Group for selected Images', ...
                        'Position',  [360+(g-1)*90 365 80 25]);
        addprop(hGroups(g), 'idx');
        hGroups(g).idx=g;
        addprop(hGroupNames(g), 'idx');
        hGroupNames(g).idx=g;
        if g>1
            hRem(g-1)=uicontrol('Style', 'pushbutton', 'String', 'Remove', 'Position', [375+(g-1)*90 330 50 25], ...
                        'Tooltipstring', 'Remove this group', 'Callback', @removeGrp);
            addprop(hRem(g-1), 'idx');
            hRem(g-1).idx=g;
        end
    end
end
function save(~,~)
    writeGroups=[routes groups];
    T=cell2table(writeGroups,'VariableNames', [{'Image'} groupnames]);
    writetable(T,[datFile(1:end-4) '_groups.dat']);
    if any(any(cellfun(@isempty, groups)))
        msgbox(sprintf(['Warning: At least one image has (No Value) for at least one Group\n' ...
            'This may cause unintended results when making figures\nGroups have been saved successfully']));
    end
end
function close(~,~)
    delete(gcf);
end

end

