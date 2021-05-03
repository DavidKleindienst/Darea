%
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria - Klosterneuburg - Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%  
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%  
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

function data=openImages(title,downstreamFunction, fileextension, datFile, data)
%% This function allows opening a configuration file with the list of images and choosing them for
% manual labeling or demarcation

if nargin <5
    data=NaN;
end
Position=NaN;
%% This variables contain the useful information.
% Name of the file which contains the list of images.
file = '';
% The file with the list of the images and the images are in this path.
path = '';
% List of names of the images (routes).
routes = '';
% Scale of each image.
scales = '';
% Selected angles for serialEM
selAngles = NaN;
% Displayed Names
imNames = '';
defaults=readDefaults();
shiftpress=0;
%% Main figure
positionFigure =  [25, 50, 400, 600];
mainFigure = figure('OuterPosition', positionFigure); 
set(mainFigure, 'menubar', 'none'); % No menu bar.
set(mainFigure, 'Name', title); % Title. 
set(mainFigure, 'KeyReleaseFcn', @keyRelease);
set(mainFigure, 'KeyPressFcn', @keyPress);


%% Controls in the main figure.
figureColor = get(mainFigure, 'color'); % Gets the color.
hImageList = uicontrol('Style','listbox', 'String', ' ', 'Position', [50 60 300 500]);
hClose = uicontrol('Style', 'pushbutton', 'String', 'Close','Position', [280 10 70 25], 'Callback', @close); 
hAutoContrast = uicontrol('Style', 'checkbox', 'String', 'Auto-contrast', 'Position', [50 30 100 25], ... 
                'Tooltipstring', 'Automatically adjust brightness and contrast of the image');

%To Allow for Rightclicks in hImage list here:
% (Taken from https://undocumentedmatlab.com/blog/setting-listbox-mouse-actions )
% Get the listbox's underlying Java control
jScrollPane = findjobj(hImageList);
 
% We got the scrollpane container - get its actual contained listbox control
jListbox = jScrollPane.getViewport.getComponent(0);
 
% Convert to a callback-able reference handle
jListbox = handle(jListbox, 'CallbackProperties');


%ContextMenu
% Prepare the context menu (note the use of HTML labels)
menuItem1 = javax.swing.JMenuItem('Open');
menuItem2 = javax.swing.JMenuItem('Duplicate');
menuItem3 = javax.swing.JMenuItem('Duplicate with demarcation');
menuItem4 = javax.swing.JMenuItem('Remove');
 
% Set the menu items' callbacks
set(menuItem1,'ActionPerformedCallback',{@optionsHandler, 'open'});
set(menuItem2,'ActionPerformedCallback',{@optionsHandler, 'duplicate'});
set(menuItem3, 'ActionPerformedCallback',{@optionsHandler, 'duplicateDem'});
set(menuItem4,'ActionPerformedCallback',{@optionsHandler, 'remove'});
 
% Add all menu items to the context menu (with internal separator)
jmenu = javax.swing.JPopupMenu;
jmenu.add(menuItem1);
jmenu.add(menuItem2);
jmenu.add(menuItem3);
jmenu.add(menuItem4);
 
% Set the mouse-click callback
% Note: MousePressedCallback is better than MouseClickedCallback
%       since it fires immediately when mouse button is pressed,
%       without waiting for its release, as MouseClickedCallback does
set(jListbox, 'MousePressedCallback',{@listboxCallback,hImageList,jmenu});
 

set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized')    %Make objects resizable

% This flag controls that only one window is open
openedFigure = false;
%Configuration file may be already provided by calling program
if nargin>=4
    [path, file, ext]=fileparts(datFile);
    file=[file,ext];
    readDatFile(path,file);  
end
set(hImageList, 'KeyReleaseFcn', @keyRelease);
set(hImageList, 'KeyPressFcn', @keyPress);


% Waits for the figure to close to end the function.
waitfor(mainFigure);



    function readDatFile(path,file,index)
        %reads the datfile
        %if index is specified jumps to that image
        defaults=updateDefaults(getOptionsName(fullfile(path, file)),defaults);
        try
            [routes,scales,~,imNames,selAngles] = readConfig(fullfile(path,file),fileextension);
        catch
             msgbox([fullfile(path,file) 'is not a valid configuration file.'], 'Error','error');
        end
        % Updates the interface.
        set(hImageList,'String',imNames);
        if nargin>2
            set(hImageList,'Value',min(index+10,numel(imNames)));
            pause(0.02)
            set(hImageList,'Value',min(index,numel(imNames)));
        end           
    end
    function keyRelease(~,key)
        %Hotkeys
        switch key.Key
            case 'return'
                openImage(get(hImageList, 'Value'));
            case 'shift'
                shiftpress=0;
        end
    end
    function keyPress(~,key)
        switch key.Key
            case 'shift'
                shiftpress=1;
            case 'r'
                if shiftpress
                    imgIndex=get(hImageList,'Value');
                    removeImage(imgIndex);
                end
        end
    end
    
    % Opens an image
    function openImage(imgIndex)
        if openedFigure
            disp('Only one figure can be opened at a time');
            return;
        end
        route = routes{imgIndex};
        scale = scales(imgIndex);
        if ~isfile(fullfile(path,[route '.tif'])) && ~endsWith(route, '_dupl') ...
                && ~isfile(fullfile(path,route))
            
            answer=questdlg(sprintf(['This image does not exist, perhaps it has been moved or renamed.\n',...
                        'Should it be removed from this project?']), ...
                        'Image not found', 'yes','no','no');
            if strcmp(answer,'yes')
                removeImage(imgIndex)
            end
            return;
        end
        
        openedFigure = true;
        if isnan(selAngles)
            selAngle = NaN;
        else
            selAngle = selAngles(imgIndex);
        end
        [defaults, data, Position,newAngle]=downstreamFunction(path, route, scale, selAngle, imgIndex, hAutoContrast.Value, defaults, datFile, data, Position);
        openedFigure = false;
        if newAngle && ~isnan(selAngle) && newAngle ~= selAngle
            %Selected angle was changed,
            %save to config file
            py.makeProjectFile.changeSelectedAngle(datFile,py.int(imgIndex-1),py.int(newAngle));
            readDatFile(path,file,imgIndex); %Updates GUI
        else
            %Update GUI to show modified files
            currName=imNames{imgIndex};
            currFile=fullfile(path, [route fileextension]);
            if endsWith(currName, '*') && ~isfile(currFile)
                currName=currName(1:end-3);
            elseif ~endsWith(currName, '*') && isfile(currFile)
                currName=sprintf([currName '\t *']);
            end
            imNames{imgIndex}=currName;
            set(hImageList,'String',imNames);
            set(hImageList,'Value',min(imgIndex+10,numel(imNames)));   %Scroll down so the mark will be in middle
            pause(0.02)
            set(hImageList,'Value',min(imgIndex,numel(imNames)));
        end
        figure(mainFigure); %Bring Menu back to foreground when closing image
    end

    % Define the mouse-click callback function
    function listboxCallback(jListbox,jEventData,hListbox,jmenu)
        %% Modified from https://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
        % Determine the current listbox index
        % Remember: Java index starts at 0, Matlab at 1
        mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
        clickedIndex = jListbox.locationToIndex(mousePos) + 1;

        % Determine the click type
        if ~jEventData.isMetaDown  
            %LeftClick
            openImage(clickedIndex);
        else
            %RightClick 
            set(hListbox, 'Value', clickedIndex)
            jmenu.show(jListbox, jEventData.getX, jEventData.getY);
            jmenu.repaint;
        end
    end  
    function optionsHandler(~,~,selection)
        imgIndex=get(hImageList,'Value');
        switch selection
            case 'open'
                openImage(imgIndex);
            case 'duplicate'
                duplicateImage(imgIndex,0);
            case 'duplicateDem'
                duplicateImage(imgIndex,1);
            case 'remove'
                removeImage(imgIndex);
        end
    end
    function duplicateImage(index,dem)
        %Duplicate Image and update Datfile!
        if dem
            % duplicate demarcation as well
            py.makeProjectFile.duplicateImage(datFile,py.int(index-1),1);
        else
            py.makeProjectFile.duplicateImage(datFile,py.int(index-1));
        end
        readDatFile(path,file,index);
    end
    function removeImage(index)
        %Remove Image Entry from Datfile
        py.makeProjectFile.removeImage(fullfile(path,file),py.int(index-1));
        readDatFile(path,file,index);
    end

    % Closes the application.
    function close(~ , ~)
        delete(gcf);
    end
end