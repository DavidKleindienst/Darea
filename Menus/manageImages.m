function manageImages(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin==0
    [infoFile, folder] = uigetfile('*.dat');
    datFile=fullfile(folder,infoFile);
end

[routes, scales]=readConfig(datFile);

%Temporary Config file to save all changes to
safeMkdir('tmpI');
[~,n,e]=fileparts(datFile);
newConfig=fullfile('tmpI', [n e]);
copyfile(datFile,newConfig);

positionFigure =  [25, 50, 700, 505];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Manage Images'); 
set(mainFigure, 'CloseRequestFcn', @close);

%'ColumnWidth', {220, 80},
hTable=uitable('Data', [routes,num2cell(scales)],'Position', [25 100 450 350],  'ColumnEditable', [false, true], ...
        'ColumnName', {'Image', 'Scale [nm/px]'}, 'CellSelectionCallback',@selectCell, 'CellEditCallback', @changeScale);
jScroll = findjobj(hTable);
jTable = jScroll.getViewport.getView;
jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
hAdd=uicontrol('Style', 'pushbutton', 'String', 'Import Image(s)', 'Position', [480, 260, 140, 25], 'Callback', @addRow, 'Tooltipstring', 'Select images to import');
hRemove=uicontrol('Style', 'pushbutton', 'String', 'Remove Selected Image', 'Position', [480, 230, 140, 25], 'Callback', @remRow, 'Tooltipstring', 'Remove selected image');
selectedCell=NaN;


hSave=uicontrol('Style', 'pushbutton', 'String', 'Save', 'Callback', @save, 'Position', [250 25 50 25]);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Callback', @close, 'Position', [325 25 50 25]);

waitfor(mainFigure);
    
function close(~,~)
    try rmdir('tmpI','s'); end
    delete(gcf);
end

function save(~,~)
    scale=cell2mat(hTable.Data(:,2));
    if any(isnan(scale)) || any(scale<=0)
        msgbox(sprintf(['Error: At least one image has no  scale set or the scale is negative\n' ...
                        'Please set proper scales for all images and try again']), 'Error');
        return;
    end
    copyfile(newConfig,datFile);
end
    function [viewport, P]=getScrollPosition()
    jscrollpane = javaObjectEDT(jScroll);
    viewport    = javaObjectEDT(jscrollpane.getViewport);
    P = viewport.getViewPosition();
    end
    %jtable = = javaObjectEDT( viewport.getView );
    % Do whatever you need to do in the callback...
    %
    %
    function setScrollPosition(viewport,P)
    drawnow() %This is necessary to ensure the view position is set after matlab hijacks it
    viewport.setViewPosition(P);
    end
function addRow(~,~)
    [images, path]=uigetfile('*.tif', 'Select one or more images', 'Multiselect', 'on');
    images=images(~endsWith(images,'_mod.tif'));
    if isempty(images)
        fprintf('No valid images selected. _mod.tif images are not valid images');
        return;
    end
    images=cellfun(@(x)fullfile(path,x),images,'UniformOutput',false);
    py.makeProjectFile.addImages(newConfig,py.list(images),datFile)
    readChangedConfig(); 
end
function remRow(~,~)
    if ~isnan(selectedCell)
        if numel(selectedCell)==1
            py.makeProjectFile.removeImage(newConfig,py.int(selectedCell-1));
        else
            py.makeProjectFile.removeImage(newConfig,py.list(int32(selectedCell-1)));
        end
        readChangedConfig();
    end
end
function selectCell(~,evt)
    selectedCell=unique(evt.Indices(:,1));
end

function changeScale(~,evt)
    if isnan(evt.NewData)
        %User entered invalid value
        set(hTable,'Data',[routes,num2cell(scales)]);
        return;
    end
    py.makeProjectFile.changeScale(newConfig,py.int(evt.Indices(1)-1),py.float(evt.NewData));
    readChangedConfig()
end

function readChangedConfig()
    [viewport, P]=getScrollPosition();
    [routes, scales]=readConfig(newConfig);
    set(hTable,'Data',[routes,num2cell(scales)]);
    setScrollPosition(viewport,P)
end

end

