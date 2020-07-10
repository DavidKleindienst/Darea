function path=importImages()
%% Menu for creating the .dat infofile for the project
% The user is asked to provide a path to a folder holding subfolders
% holding the images to be imported.

% A Config.dat infoFile is automatically created that contains the
% following information: 
% Each line of infoFile contains information related to a particular image.
% This information is divided into three fields separated by comma:

%   1) GROUP. Identifies the group an image belongs to.
%   2) ROUTE. Partial route (from 'folder') to the image. In particular, 3 files are processed: 
%             - folder/ROUTE'.tif'. Base image.
%             - folder/ROUTE'_mod.tif'. Image with discarded regions coloured white.
%             - folder/ROUTE'dots.csv. Locations and radii of the particles (nanometers).
%   3) PIXELSIZE. Size of one pixel in nm

%   Alternatively (i.e. if created manually), the File can also contain the following four fields separated by comma
%   
%   1) GROUP. (see above)
%   2) ROUTE. (see above)
%   3) CALIBRATION. Calibration of the microscope.
%   4) MAGNIFICATION. Magnification of the microscope.

% The terms "infoFile", "datFile", "ConfigFile" and "Configuration file"
% are used interchangeably to refer to this file.

% Output parameters:
% path: Absolute path to the created infoFile

%Some Defaults
defaultMagFile='Mags.txt';

%To hold variables
path='';
folder='';
deliminator='_';
selectedCell=NaN;


ConfigMenu=figure('OuterPosition',[365, 255, 410, 405],'menubar', 'none', 'resize','off', 'Name', 'Import Images into Configuration File', 'CloseRequestFcn', @cancel);

hSelectFolder=uicontrol('Style', 'pushbutton', 'String', 'Select Image Folder', 'Position', [20 340 280 25], ...
                    'Tooltipstring', 'Press help for details on the folderstructure', 'Callback', @userSelectFolder);
hHelp=uicontrol('Style', 'pushbutton', 'String', 'Help', 'Position', [305, 340, 50, 25], 'Callback', @showHelp); 

hTable=uitable('Data', {'',0},'Position', [25 50 200 280], 'ColumnEditable', true, ...
        'ColumnName', {'Magnification', 'Scale [nm/px]'}, 'CellSelectionCallback',@selectCell);
hAdd=uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [230, 260, 25, 25], 'Callback', @addRow, 'Tooltipstring', 'Add row');
hRemove=uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [230, 230, 25, 25], 'Callback', @remRow, 'Tooltipstring', 'Remove selected row');
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


uicontrol('Style', 'Text', 'String', 'Projectname', 'Position', [230 90 80 25]);
hName=uicontrol('Style','Edit', 'String', 'Config', 'Position', [310 90 80 25]);

hMake=uicontrol('Style', 'pushbutton', 'String', 'Create Project', 'Position', [228 50 100 25], 'Callback', @(~,~)makeConfig(true));
hCancel=uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', [333 50 80 25], 'Callback', @cancel);

mags=readMags(defaultMagFile);
waitfor(ConfigMenu);
function makeConfig(fromButton)
    fileName=hName.String;
    
    deliminator=get(hDeliminatorE,'String');
    %% Some Checks should be here
    
    if strcmp(folder(end), ' ')
        msgbox('Foldernames ending on a space character are not supported. Please rename the folder so its last character is something other than a space');
        return
    end
    if contains(folder, '+')
        msgbox('+ characters in the path are not allowed. Please rename your folder');
        return
    end
    %Config File will be created by a python function
    %So we need to convert Mags to a python dictionary
    
    pyMags=py.dict();
    for i=1:size(mags,1)
       pyMags.update(pyargs(mags{i,1},mags{i,2})); 
    end
    if get(hr1,'Value')
        arguments=pyargs('separator',deliminator);
    else
        arguments=pyargs('separator',deliminator, 'defaultMag',get(hDefaultMag,'String'));
    end
    py.makeProjectFile.run(folder,pyMags,[fileName '.dat'],arguments);
    path=fullfile(folder, [fileName '.dat']);
    if fromButton
        if ~isfile(path)
            path='';
            answer=questdlg(sprintf('No Images found.\nMaybe you need to go one folderlevel deeper or less deep?\nI can attempt to fix this automatically. Should I?'), ...
                        'No Images found', 'yes','no','no');
            if strcmp(answer,'no')
                return;
            end
            origFolder=folder;
            files=dir(folder);
            files={files.name};
            if any(endsWith(files,'.tif'))
                folder=fileparts(folder);
            else
                subfolders=dir(folder);
                subfolders={subfolders.name};
                subfolders=subfolders(~startsWith(subfolders,'.'));
                subfolders=subfolders(isfolder(fullfile(folder,subfolders)));
                if isempty(subfolders)
                    path='';
                    msgbox(sprintf('Still no images found.\nProblem could not be fixed automatically'));
                    return;
                elseif numel(subfolders)==1
                    folder=fullfile(folder,subfolders{1});
                else
                    [idx, tf]=listdlg('PromptString',{'Please select the subfolder that contains your images.',...
                    'If more than one subfolder contain your images, you have to modify the folder structure', ...
                    'In that case, press cancel, then click help for more information', ' '},...
                    'SelectionMode','single','ListString',subfolders);
                    if ~tf
                        path='';
                        return;
                    end
                    folder=fullfile(folder,subfolders{idx});
                end
            end
            makeConfig(0);
            if ~isfile(path)
                path='';
                folder=origFolder;
                msgbox(sprintf('Still no images found.\nProblem could not be fixed automatically'));
                return;
            end
        end
        
        msg=msgbox(sprintf('Image import successful\nProject saved as %s',path));
        waitfor(msg);
        delete(ConfigMenu);
    end
end
function userSelectFolder(~,~)
    folder = uigetdir();
    set(hSelectFolder, 'String', folder);
end
function cancel(~,~)
    path='';
    delete(ConfigMenu);
end
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

function mags=readMags(filename)
    magInfo=tdfread(filename);
    mags=cell(numel(magInfo.Scale),2);
    for i=1:numel(magInfo.Scale)
       mags{i,1}=strtrim(num2str(magInfo.Magnification(i,:)));
       mags{i,2}=magInfo.Scale(i);
    end
    set(hTable,'Data',mags)
end
function showHelp(~,~)
    x=repmat({'',''},1,9);
    msgbox(sprintf(['Your folderstructure should look like this:\n\n', ...
        'ProjectFolder\n',...
        '%-3s%s|\n', ...
        '%-3s%s|---Subfolder1\n',...
        '%-13s%s|\n', ...
        '%-13s%s|---Image1.tif\n',...
        '%-13s%s|---Image2.tif\n',...
        '%-3s%s|---Subfolder2\n',...
        '%-13s%s|\n', ...
        '%-13s%s|---Image1.tif\n',...
        '%-13s%s|---Image2.tif\n', ...
        '\nPlease select ProjectFolder in the dialog,\nor refer to the handbook for more information.\n'],...
        x{:}), 'Help');
        
end
end