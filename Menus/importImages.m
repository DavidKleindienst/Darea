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
defaultMag=-1;  % -1 means skip image if no Mag found.

ConfigMenu=figure('OuterPosition',[365, 255, 410, 405],'menubar', 'none', 'Name', 'Import Images into Configuration File', 'CloseRequestFcn', @cancel);

hSelectFolder=uicontrol('Style', 'pushbutton', 'String', 'Select Image Folder', 'Position', [20 340 280 25], ...
                    'Tooltipstring', 'Press help for details on the folderstructure', 'Callback', @userSelectFolder);
hHelp=uicontrol('Style', 'pushbutton', 'String', 'Help', 'Position', [305, 340, 50, 25], 'Callback', @showHelp); 


uicontrol('Style', 'Text', 'String', 'Projectname', 'Position', [20 285 80 25]);
hName=uicontrol('Style','Edit', 'String', 'Config', 'Position', [100 290 100 25]);


hrTif=uicontrol('Style', 'radiobutton', 'String', 'Import .tif images', 'Position', [20 250 200 20], 'Value', 1);
hrSer=uicontrol('Style', 'radiobutton', 'String', 'Import SerialEM files with multiple angles', 'Position', [20 230 250 20], 'Callback', @(h,~)radioButtons(h,hrTif));

set(hrTif,'Callback', @(h,~)radioButtons(h,hrSer));


hMagnifications=uicontrol('Style', 'pushbutton', 'String', 'Choose Magnifications', 'Position', [30 150 150 25], 'Callback', @setMagnifications);


hMake=uicontrol('Style', 'pushbutton', 'String', 'Create Project', 'Position', [80 50 100 25], 'Callback', @(~,~)makeConfig(true));
hCancel=uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', [220 50 80 25], 'Callback', @cancel);
set(findall(ConfigMenu, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

mags=readMags(defaultMagFile);
waitfor(ConfigMenu);

function radioButtons(hObj,hOther)
    if get(hObj,'Value')
        set(hOther,'Value',0);
    else
        set(hOther,'Value',1);
    end
    if hObj == hrSer
        set(hMagnifications, 'Visible', 'off');
    else
        set(hMagnifications, 'Visible', 'on');
    end
end

function makeConfig(fromButton)
    fileName=hName.String;
    
    
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
    if hrTif.Value
        pyMags=py.dict();
        for i=1:size(mags,1)
           pyMags.update(pyargs(mags{i,1},mags{i,2})); 
        end
        if defaultMag==-1
            arguments=pyargs('separator',deliminator);
        else
            arguments=pyargs('separator',deliminator, 'defaultMag',num2str(defaultMag));
        end
        py.makeProjectFile.run(folder,pyMags,[fileName '.dat'],arguments);
    else
        arguments=pyargs('outputName',[fileName '.dat'], 'serialEM', 1);
        py.makeProjectFile.run(folder,arguments);
    end
    path=fullfile(folder, [fileName '.dat']);
    if fromButton
        if ~isfile(path)
            path='';
            if hrSer.Value
                %Maybe we can later add an autofix for this as well.
                msgbox(sprintf("No images found. Please check that you've put the correct folder"));
                return;
            end
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
    global lastfolder
    if isempty(lastfolder)
        lastfolder=cd;
    end
    folder = uigetdir(lastfolder, 'Select image folder');
    if ischar(folder)
        lastfolder=folder;
    end
    set(hSelectFolder, 'String', folder);
end
function cancel(~,~)
    path='';
    delete(ConfigMenu);
end

function mags=readMags(filename)
    magInfo=tdfread(filename);
    mags=cell(numel(magInfo.Scale),2);
    for i=1:numel(magInfo.Scale)
       mags{i,1}=strtrim(num2str(magInfo.Magnification(i,:)));
       mags{i,2}=magInfo.Scale(i);
    end
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
function setMagnifications(~,~)
    [mags,deliminator,defaultMag]=MenuMagnifications(mags,deliminator,defaultMag);
end

end