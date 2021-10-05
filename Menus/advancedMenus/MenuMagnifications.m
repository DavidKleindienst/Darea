function [mags,deliminator,defaultMag] = MenuMagnifications(mags,deliminator,defaultMag)
%MENUMAGNIFICATIONS Summary of this function goes here
%   Detailed explanation goes here
oldMags=mags;
MagMenu=figure('OuterPosition',[365, 255, 410, 405],'menubar', 'none', 'resize','off', 'Name', 'Import Images into Configuration File', 'CloseRequestFcn', @cancel);

selectedCell=NaN;

hTable=uitable('Data', {'',0},'Position', [25 50 200 280], 'ColumnEditable', true, ...
        'ColumnName', {'Magnification', 'Scale [nm/px]'}, 'CellSelectionCallback',@selectCell);
hAdd=uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [230, 260, 25, 25], 'Callback', @addRow, 'Tooltipstring', 'Add row');
hRemove=uicontrol('Style', 'pushbutton', 'String', '—', 'Position', [230, 230, 25, 25], 'Callback', @remRow, 'Tooltipstring', 'Remove selected row');
hSaveAs=uicontrol('Style', 'pushbutton', 'String', 'Save Magnifications', 'Position', [25, 20, 100, 25], ...
            'Callback', @(~,~)selectMagFile('write'), 'Tooltipstring', 'Remove selected row');
hSaveAsDefault=uicontrol('Style', 'pushbutton', 'String', 'Save as Default', 'Position', [135, 20, 100, 25], ...
            'Callback', @(~,~)writeMags(NaN), 'Tooltipstring', 'Remove selected row');
hLoadMags=uicontrol('Style', 'pushbutton', 'String', 'Load Magnifications', 'Position', [230 308 110 25], ...
            'Callback', @(~,~)selectMagFile('read'), 'Tooltipstring', 'Load Magnifications from file');
hDeliminatorT=uicontrol('Style', 'Text', 'String', 'Deliminator', 'Position', [275, 258, 55, 25], 'HorizontalAlignment','left');
hDeliminatorE=uicontrol('Style', 'Edit', 'String', deliminator, 'Position', [333, 263, 25, 20]);

hSkippedImagesText=uicontrol('Style', 'Text', 'String', 'When no magnification is found in filename', 'Position', [225 167 97 50]);
hr1=uicontrol('Style', 'radiobutton', 'String', 'Skip Image', 'Position', [322 195 100 20], 'Value', 1);
hr2=uicontrol('Style', 'radiobutton', 'String', 'Use Value', 'Position', [322 175 100 20], 'Callback', @(h,~)selectMagDefault(h,hr1));
set(hr1,'Callback', @(h,~)selectMagDefault(h,hr2));
hDefaultMag=uicontrol('Style', 'Edit', 'Position', [344 155 30 20], 'Visible', 'off');

if defaultMag ~= -1
    hr2.Value=1;
    selectMagDefault(hr2,hr1);
    hDefaultMag.String=num2str(defaultMag);
end


hOk=uicontrol('Style', 'pushbutton', 'String', 'Ok', 'Position', [233 50 80 25], 'Callback', @accept);
hCancel=uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', [318 50 80 25], 'Callback', @cancel);

set(hTable,'Data',mags)
waitfor(MagMenu);

function selectMagDefault(hObj,hOther)
    if get(hObj,'Value')
        set(hOther,'Value',0);
    else
        set(hOther,'Value',1);
    end
    if hObj==hr1
        set(hDefaultMag,'Visible', 'off');
    else
        set(hDefaultMag,'Visible', 'on');
    end
end
function addRow(~,~)
    mags = get(hTable,'Data');
    s=size(mags,1);
    mags{s+1,1}='';
    mags{s+1,2}=0;
    set(hTable,'Data',mags)
end
function remRow(~,~)
    if ~isnan(selectedCell)
        mags = get(hTable,'Data');
        mags(selectedCell,:)=[];
        set(hTable,'Data',mags)
    end
end
function selectCell(~,evt)
    selectedCell=unique(evt.Indices(:,1));
end
function selectMagFile(instruction)
    if strcmp(instruction,'write')
        filename=uiputfile('Magnification.txt');
    elseif strcmp(instruction, 'read')
        filename=uigetfile('*.txt');
    end
    if filename
        if strcmp(instruction,'write')
            writeMags(filename);
        elseif strcmp(instruction, 'read')
            mags=readMags(filename);
        end
    end
end
function writeMags(filename)
    mags=get(hTable,'Data');
    if isnan(filename)
        filename=defaultMagFile; %Replace Default
    end
    Magnification=mags(:,1);
    Scale=mags(:,2);
    writetable(table(Magnification,Scale),filename,'Delimiter','\t');
end

function accept(~,~)
    mags=get(hTable,'Data');
    deliminator=get(hDeliminatorE,'String');
    if get(hr1,'Value')
        defaultMag=-1;
    else
        defaultMag=str2double(get(hDefaultMag,'String'));
    end
    delete(MagMenu);
end

function cancel(~,~)
    mags=oldMags;
    delete(MagMenu);
end

function mags=readMags(filename)
    magInfo=tdfread(filename);
    mags=cell(numel(magInfo.Scale),2);
    for i=1:numel(magInfo.Scale)
       mags{i,1}=strtrim(num2str(magInfo.Magnification(i,:)));
       mags{i,2}=magInfo.Scale(i);
    end
end

end

