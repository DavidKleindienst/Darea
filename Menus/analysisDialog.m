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

function [Data, ret]=analysisDialog(datFile)
%% User interface for setting parameters for the analysis
% Allows the user to select the .bat file containing information on the images as well as specify the details of analysis
% Will then call StartAnalysis() to perform the simulations and analyse distances and cluster parameters
% according to user input.
% Returns boolian value ret. 
% ret==1 -> User has pressed batch processing, the Interface will appear again
% and allow adding of another analysis for batch processing.
% ret==0 -> User has closed the interface.

Data=NaN; %Default return value, Data will only be returned in specific case (successfull non-batch analysis)
ret=0;  %Will be set to one if batch processing is selected
settings=readDefaults(); %Read Default parameters

%variables which will be filled with useful information


fileImageList = '';     %Filename of the .dat file containing Image info
pathImageList = '';     %Path to the image file
groupnames={};
groups={};
analysisName='Analysis';
if isfile('Batch.mat')        %If a batch file already exists
    Batch=load('Batch.mat');            %New parameters will be added to the end
    Batch=Batch.Batch;
    analysisName=[Batch{1}{4} '_Batch_' num2str(numel(Batch)+1)];
else
    Batch={};
end

names=cell(1,numel(settings.particleTypes));     %By Default the name of each particle is it's Diameter
for r=1:numel(settings.particleTypes)
    names{r}=[num2str(settings.particleTypes(r)) 'nm'];
end
settings.type='Analysis';        %Some identification value, which is used for verification when loading settings

%Default values for advanced Options

Defaultsettings=settings;

%% Main figure

positionFigure = [25, 50, 700+(positive(numel(settings.particleTypes)-2))*165, 450];

mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'Name', 'Perform analysis'); 
figureColor = get(mainFigure, 'color'); % Gets the color.


%% Controls in the main figure.


hImageLPathText = uicontrol('Style', 'Text', 'String', 'Project:','backgroundcolor',figureColor,'HorizontalAlignment','left','Position', [25 365 100 25]);     
hImageLPathEdit = uicontrol('Style', 'Text', 'String', 'Chose file name', 'Tooltipstring','Path to the project file',...
                       'HorizontalAlignment','left','backgroundcolor','white','Position', [125 370 325 25]); 
hImageLPathButton = uicontrol('Style', 'pushbutton', 'String', 'Change Project', 'Tooltipstring','Change to a different project','Position', [475 370 100 25], 'Callback', @openFileImages);

nameTT=sprintf('Name of this Analysis\nGive different names when running multiple analyses from same project');
hAnalysisNameTxt=uicontrol('Style','Text','String', 'Analysis Name', 'HorizontalAlignment','left', 'Tooltipstring', nameTT, 'Position', [25 335 100 25]);
hAnalysisNameEdit=uicontrol('Style', 'Edit', 'String', analysisName, 'Tooltipstring', nameTT, 'Position', [125 340 325 25], 'Callback', @changeAnalysisName); 


%% Particle name controls
hParticlesforAnalysis= uicontrol('Style', 'Text', 'String', 'Particles to be analyzed', 'backgroundcolor', figureColor, 'HorizontalAlignment', 'left', 'Position', [25 295 100 25], ...
                        'Tooltipstring', 'Select all particles that should be analyzed and provide a name. Special Characters and formatting can be used using Latex code.');
                    

hXnm=gobjects(1,numel(settings.particleTypes));
hXnmName=gobjects(1,numel(settings.particleTypes));
for r=1:numel(settings.particleTypes)
    hXnm(r)=uicontrol('Style', 'CheckBox', 'String', names{r}, 'Position', [110+(r-1)*165 295 60 25], 'Tooltipstring', ['Include ' names{r} ' particles in analysis'], 'Value', 1);
    hXnmName(r)= uicontrol('Style', 'Edit', 'String', [names{r} ' name'], 'Tooltipstring', ['Select a name for ' names{r} ' particles. This name will be displayed in the figures. Latex code can be used for formating and special characters.'], ...
                    'Position', [170+(r-1)*165 295 85 25], 'Callback' , @(hObj, ~)changeNameXnm(hObj, r));
end


hAll=uicontrol('Style', 'CheckBox', 'String', 'All', 'Tooltipstring', 'Particles will also be analysed irrespective of size', ...
                'Position', [115+length(settings.particleTypes)*165, 295, 55, 25]);
hAllName=uicontrol('Style', 'Edit', 'String', 'All name', 'Tooltipstring', 'Select a name which will be used for additional analysis of all particles irrespective of size', ...
                'Position', [165+length(settings.particleTypes)*165, 295, 85, 25], 'Callback', @changeNameAll);


%Simulation Controls            
            
hSimuText=uicontrol('Style', 'Text', 'String', 'Perform Simulations', 'Position', [10 240 150 25], 'FontWeight', 'bold', 'HorizontalAlignment','left');
hSimCheckbox = uicontrol('Style', 'CheckBox', 'String', 'Random Simulation', 'Position', [25 215 125 25], ...
                        'Tooltipstring', 'Perform random simulation of particles');
hSimfitCheckbox = uicontrol('Style', 'CheckBox', 'String', 'Fitted Simulation', 'Position', [155 215 130 25], ...
                    'Tooltipstring', 'Perform random simulation with fitting mean NND of simulation to be same as mean NND of original Image');

hPermCheckbox=uicontrol('Style', 'CheckBox', 'String', 'Permutation', 'Position', [265 215 90 25], ...
                    'Tooltipstring', sprintf('Perform permutations of particle identity\ni.e. Particles will randomly get a radius assigned, but number of particles of each radius will stay the same'));
                
hNumberSimulationsText = uicontrol('Style', 'Text', 'String', 'Number of Simulations', 'Position', [360 215 100 25]);
hNumberSimulationsEdit = uicontrol('Style', 'Edit', 'String', num2str(settings.nrsim), 'Position', [445 215 40 25], 'Callback', @chksimnr);

hSimAdvanced= uicontrol('Style', 'pushbutton', 'String', 'Advanced', 'Position', [550 215 75 25], 'Callback', @advancedSimulation, ...
                        'Tooltipstring', 'Advanced options for simulation');
                    
%Clustering Controls
hClusteringText= uicontrol('Style', 'Text', 'String', 'Clustering Options', 'Tooltipstring', 'Options on Cluster formation', ...
                            'Position', [25 145 100 25], 'Fontweight', 'bold', 'HorizontalAlignment','left');
hminPointsText= uicontrol('Style', 'Text', 'String', 'Minimum Particles', 'Tooltipstring', 'Minimum number of particles to be counted as a Cluster. Must be at least 3, because smaller Clusters do not have an area.', ...
                            'Position', [30 120 100 20]);
hminPointsEdit = uicontrol('Style', 'Edit', 'String', num2str(settings.minpointscluster), 'Position', [135 120 50 25], 'Callback', @chkclustnr);
                        

hClustDistanceText=uicontrol('Style', 'Text', 'String', 'Maximum Distance', 'Tooltipstring', sprintf('Maximum Distance between two particles. Below this distance, they are counted as the same Cluster.\nIf "mean + x times SD" is selected, the distance is mean NND of all particle over all images + x times the standard deviation, where x needs to be specified.\nIf "nm" is selected, please specify the Distance in nanometers.'), ...
                            'Position', [210 120 100 20]);
hClustDistDropDown=uicontrol('Style', 'popup', 'Callback', @changeMaxDistUnit, 'String', {'mean + x times SD', 'nm'}, 'Position', [315 107 150 35], 'Tooltipstring', sprintf('Maximum Distance between two particles. Below this distance, they are counted as the same Cluster.\nIf "mean + x times SD" is selected, the distance is mean NND of all particle over all images + x times the standard deviation, where x needs to be specified.\nIf "nm" is selected, please specify the Distance in nanometers.'));
hClustDistEdit=uicontrol('Style', 'Edit', 'String', num2str(settings.maxDist{2}), 'Position', [475 120 40 25], 'Callback', @chkmaxDist, 'Tooltipstring', sprintf('Maximum Distance between two particles. Below this distance, they are counted as the same Cluster.\nIf "mean + x times SD" is selected, the distance is mean NND of all particle over all images + x times the standard deviation, where x needs to be specified.\nIf "nm" is selected, please specify the Distance in nanometers.'));                    
hClustDistError=uicontrol('Style', 'Text', 'foregroundcolor', 'red', 'Fontweight', 'bold', 'Position', [400 145 180 25], 'String', 'Only Numbers can be used as input!', 'Visible', 'off');
hClustAdvanced= uicontrol('Style', 'pushbutton', 'String', 'Advanced', 'Position', [550 120 75 25], 'Callback', @advancedClustering, ...
                        'Tooltipstring', 'Advanced options for Clustering');
switch settings.maxDist{1}
    case 'nm'
        hClustDistDropDown.Value=2;
end
                    
%Load and Save settings controls
hLoadSettings=uicontrol('Style', 'pushbutton', 'String', 'Load settings', 'Position', [520 400 100 25], 'Callback', @loadSettings, 'Tooltipstring', 'Load previously saved settings from file');
hLoadSettingsError=uicontrol('Style', 'Text', 'FontWeight', 'bold', 'foregroundcolor', 'red', 'Position', [475 375 180 25], 'String', 'Loading Settings failed. Did you provide the correct file?', ...
                            'Tooltipstring', 'Only files generated by the save button of this programm and Data files generated by this program can be loaded', 'Visible', 'off');

hSaveSettings=uicontrol('Style', 'pushbutton', 'String', 'Save settings', 'Position', [75 25 90 30], 'Tooltipstring', 'Save current settings to file', 'Callback', @saveSettings);
hSavedSettingSuccess=uicontrol('Style', 'Text', 'String', 'Saved successfully', 'Position', [75 55 90 15], 'foregroundcolor', 'blue', 'Visible', 'off');

% Analyis start, close and Errors
hPerformAnalysisButton = uicontrol('Style', 'pushbutton', 'String', 'Analyze', 'Tooltipstring','Opens image list file','Position', [225 20 150 45], 'Callback', @startAnalysis); 
hProgress=uicontrol('Style', 'Text', 'Position', [35 65 580 50], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');
hImagesMissingError=uicontrol('Style', 'Text', 'FontWeight', 'bold', 'foregroundcolor', 'red', 'Position', [100 85 170 25], 'String', 'Cannot start analysis, because no Image file has been selected.', 'Visible', 'off');
hCannotStartError=uicontrol('Style', 'Text', 'FontWeight', 'bold', 'foregroundcolor', 'red', 'Position', [100 60 170 25], 'String', 'Cannot start analysis, because at least one input is not valid!', 'Visible', 'off');

if nargout>1
    hBatchProcessButton = uicontrol('Style', 'pushbutton', 'String', 'Batch', 'Tooltipstring', sprintf('Saves settings for Batchprocessing.\nYou can then set new settings for next analysis.\nClicking Analyze will then carry out all analysis at once'), ...
                            'Callback', @forBatch, 'Position', [405 25 100 25]);
end
hBatch=uicontrol('Style', 'Text', 'Position', [10 85 120 25], 'foregroundcolor', 'blue', 'FontWeight', 'bold', 'Visible', 'off');
                        
hCloseButton = uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring','Exit without saving','Position', [535 25 100 25], 'Callback', @close); 

%If datFile is already supplied, act accordingly
if nargin>0
    [pathImageList, fileImageList, extension]=fileparts(datFile);
    fileImageList=[fileImageList extension];
    readFileImages(fileImageList, pathImageList);
    
    %Change analysis name if that analysis already exists
    counter=1;
    while isfile(fullfile(pathImageList,[fileImageList(1:end-4) '_' analysisName '.mat']))
        counter=counter+1;
        analysisName=['Analysis_' num2str(counter)];
    end
    hAnalysisNameEdit.String=analysisName;
end
enableAdvancedMenus();
% Waits for the figure to close to end the function.
set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

waitfor(mainFigure);

%% Loads the information of the file.
    function openFileImages( ~, ~)
        %% Lets the user select the Image file

        % Opens the file
        [fileImageList, pathImageList] = uigetfile('*.dat');
        readFileImages(fileImageList, pathImageList);
    end
    function readFileImages(fileImageList, pathImageList)
        set(hImagesMissingError, 'visible', 'off');
        oldDiam=settings.particleTypes;
        datFile=fullfile(pathImageList, fileImageList);
        settings=updateDefaults(getOptionsName(datFile),settings);
        groupnames=readGroups(datFile);
        if ~isequal(oldDiam,settings.particleTypes)
            names=cell(1,numel(settings.particleTypes));     %By Default the name of each particle is it's Diameter
            for r=1:numel(settings.particleTypes)
                names{r}=[num2str(settings.particleTypes(r)) 'nm'];
            end
            changeFigureforDiameters(settings.particleTypes)
        end
        % Updates the interface.
        set(hImageLPathEdit, 'String', datFile); 
        enableAdvancedMenus();
    end
    function close(~ , ~)
        %% Closes the application.
        delete(gcf);
    end
    function enableAdvancedMenus()
        %If a project is selected, enable buttons
        %Otherwise disable
        if isempty(fileImageList)
            val='off';
        else
            val='on';
        end
        set([hSimAdvanced,hClustAdvanced],'Enable', val);
    end
    
    function changeAnalysisName(hOb,~)
        analysisName=hOb.String;
    end

    function changeNameXnm(hObj,r)
        %% Gets names for the particles from userinput
        names{r}=get(hObj, 'String');
    end
    function changeNameAll(hObj, ~)
        %% Change Name which is used for all particles together
        settings.allName=get(hObj, 'String');
    end
    function chksimnr(hObj, ~)
        settings.nrsim=shouldBeNumber(settings.nrsim,hObj,0,[0,inf]);
    end
    function chkclustnr(hObj,~)
        %% Checks and sets minpoints per Cluster
        settings.minpointscluster=shouldBeNumber(settings.minpointscluster,hObj,0,[3,inf]);
    end

    function chkmaxDist(hObj,~)
        %% Checks and sets maxdistance per Cluster
        settings.maxDist{2}=shouldBeNumber(settings.maxDist{2},hObj,1,[0,inf]);
    end

    function changeMaxDistUnit(source,~)
        %% Gets maxdistance Unit
        val=get(source, 'Value');
        if val==1
            settings.maxDist{1}='SD';
        elseif val==2
            settings.maxDist{1}='nm';
        else
            fprintf('Programmer has forgotten something');
        end
    end
        

    function nr=positive(nr)
        if nr<0
            nr=0;
        end
    end

%% Functions which open advanced option menus 
    function advancedSimulation(~,~)
        settings.SimOptions=MenuSimulation(settings.SimOptions,settings.particleTypes);
    end
    function advancedClustering(~,~)
        settings=MenuClustering(settings,groupnames);
    end

    function changeFigureforDiameters(newDiameter)
       %% Adjusts figure Diameter depending on how many particles are chosen
       %This function may contain some bugs, but since for now we only needed two types of particles
       %I did not want to spend too much time on this
       set(mainFigure, 'OuterPosition', [25, 50, 700+(positive(numel(newDiameter)-2))*165, 450])
       set(hAll, 'Position', [115+numel(newDiameter)*165, 305, 55, 25]);
       set(hAllName, 'Position', [165+numel(newDiameter)*165, 305, 85, 25]);
       for r=1:numel(hXnm)
            delete(hXnm(r));
            delete(hXnmName(r));
       end
       hXnm=gobjects(1,numel(settings.particleTypes));
       hXnmName=gobjects(1,numel(settings.particleTypes));
       for r=1:numel(settings.particleTypes)
            hXnm(r)=uicontrol('Style', 'CheckBox', 'String', names{r}, 'Position', [110+(r-1)*165 305 60 25], 'Tooltipstring', ['Include ' names{r} ' particles in analysis'], 'Value', 1);
            hXnmName(r)= uicontrol('Style', 'Edit', 'String', [names{r} ' name'], 'Tooltipstring', ['Select a name for ' names{r} ' particles. This name will be displayed in the figures. Latex code can be used for formating and special characters.'], ...
                    'Position', [170+(r-1)*165 305 85 25], 'Callback' , @(hObj, ~)changeNameXnm(hObj, r));
       end

    end

    function readSettings()
        %% Reads all userinput and saves to variables
        settings.includeall=get(hAll, 'Value');
        settings.simnames={};
        settings.SimulationNames={};
        settings.Simtruth=[];
        settings.radii=[];
        settings.names={};
        
        for r=1:numel(settings.particleTypes)
           if get(hXnm(r), 'Value')
               settings.radii(end+1)=settings.particleTypes(r)/2;
               settings.names{end+1}=names{r};
           end
        end
        
        if get(hSimCheckbox,'Value')
            settings.simnames{end+1}='Sim';
            settings.Simtruth(end+1)=false;
        end
        if get(hSimfitCheckbox, 'Value')
            settings.simnames{end+1}='SimFit';
            settings.Simtruth(end+1)=true;
        end
        if get(hPermCheckbox, 'Value')
            settings.simnames{end+1}='Permutation';
            settings.Simtruth(end+1)=NaN;
        end
    end

    function newSettings=ensureSettingsFunctionality(newSettings, Default)
        % If the program has been updated since settings have been saved,
        % the program may require some Settings that have not been saved, because the functionality didn't exist
        % This function makes sure that older saved settings still work
        % by taking all the missing variable from the Default settings
        settingfields=fieldnames(Default);
        for fi=1:numel(settingfields)
           if ~isfield(newSettings, settingfields{fi})
               newSettings.(settingfields{fi})=Default.(settingfields{fi});
           elseif isstruct(Default.(settingfields{fi}))
               structfields=fieldnames(Default.(settingfields{fi}));
               for sf=1:numel(structfields)
                   if ~isfield(newSettings.(settingfields{fi}), structfields{sf})
                      newSettings.(settingfields{fi}).(structfields{sf})=Default.(settingfields{fi}).(structfields{sf}); 
                   end
               end
           end
        end
    end

    function loadSettings(~,~)      
        %% Loads settings
        oldreqDiameter=settings.particleTypes;
        set(hLoadSettingsError, 'Visible', 'off');
        [loadFile, loadPath]=uigetfile('*.mat');
        loadFile=[loadPath loadFile]; 
        loadsettings=load(loadFile);
        if isfield(loadsettings, 'settings') && strcmp(settings.type, 'Analysis')
            settings=ensureSettingsFunctionality(loadsettings.settings, Defaultsettings);
        elseif isfield(loadsettings, 'Data')
            settings=ensureSettingsFunctionality(loadsettings.Data.settings, Defaultsettings);
        else        %Show error message if file doesn't contain appropriate Data
            set(hLoadSettingsError, 'Visible', 'on');
            return
        end
        if numel(oldreqDiameter)~=numel(settings.particleTypes)
            changeFigureforDiameters(settings.particleTypes);        %Adjusts figure so that appropriate number of checkboxes to include radii in analysis are present
        else        
            for x=1:numel(hXnm)
                set(hXnm(x), 'Value', 1);       %Check all boxes, because if figure is changed, boxes come checked to
                set(hXnmName(x), 'String', [num2str(settings.particleTypes(x)) 'nm']);
            end
        end
        %Uncheck radii checkboxes where appropriate    
            for x=1:numel(settings.particleTypes)
                if ~any(settings.particleTypes(x)/2==settings.radii)
                   set(hXnm(x), 'Value', 0);
                else
                   set(hXnmName(x), 'String', settings.names{settings.radii==settings.particleTypes(x)/2});
                end
            end

        %First uncheck all boxes, then check all that apply.
        set(hAll, 'Value', settings.includeall);
        set(hSimCheckbox, 'Value', false);
        set(hSimfitCheckbox, 'Value', false);
        set(hminPointsEdit, 'String', num2str(settings.minpointscluster));
        set(hNumberSimulationsEdit, 'String', num2str(settings.nrsim));
        set(hClustDistEdit, 'String', num2str(settings.maxDist{2}));
        if strcmp(settings.maxDist{1}, 'nm')
            set(hClustDistDropDown, 'Value', 2);
        elseif strcmp(settings.maxDist{1}, 'SD')
            set(hClustDistDropDown, 'Value', 1);
        else
           fprintf('blblalb');
        end
        for s=1:numel(settings.Simtruth)
           if settings.Simtruth(s)
               set(hSimfitCheckbox, 'Value', true);
           else
               set(hSimCheckbox, 'Value', true);
           end
        end 
    end

    function saveSettings(~, ~)
        %% Saves the settings as .mat file at location specified by user
        readSettings();
        [saveFile, savePath]=uiputfile('*.mat');
        saveFile=[savePath saveFile];        
        save(saveFile,'settings');
        set(hSavedSettingSuccess, 'Visible', 'on');
    end

    function forBatch(~,~)
        %% Saves the input for batch processing
        set(hCannotStartError, 'Visible', 'off');

        
        if strcmp(fileImageList,'')        %or if no Image file has been selected
            set(hImagesMissingError, 'Visible', 'on');
            uistack(hImagesMissingError, 'top');
        else
            readSettings();
            
            if ~addToBatch()
                %Analysis Name already taken, return and let user pick different name
                return;   
            end
            save('Batch.mat', 'Batch');
            
            ret=1;      %Ret is set to 1 to make dialogue window reopen
            delete(gcf); %Dialogue window is closed
        end

    end
    function returnValue=addToBatch()
        returnValue=0;
        if ~isempty(Batch)
            names=cellfun(@(x)x{4}, Batch,'UniformOutput', false);
            if any(cell2mat(cellfun(@(x) strcmp(x, analysisName), names,'UniformOutput', false)))
                msgbox(sprintf('Analysis with name %s has already been added to this Batch\nPlease pick a different name',...
                            analysisName), 'Error','error');
                return;
            end
        end
        
        if isfile(fullfile(pathImageList,[fileImageList(1:end-4) '_' analysisName '.mat']))
            answer=questdlg(sprintf('Analysis %s already exists. Would you like to overwrite?', analysisName),...
                                    'Overwrite?','Yes','No','No');
            if strcmp(answer,'No')
                return;
            end
        end
        Batch{end+1}={fileImageList, pathImageList, settings, analysisName};
        returnValue=1;
    end
    function startAnalysis(~,~)
        %%Starts the Analysis
        set(hCannotStartError, 'Visible', 'off');
        
        set(hProgress, 'ForegroundColor', 'blue');
        

        if strcmp(fileImageList,'')
            set(hImagesMissingError, 'Visible', 'on');
            uistack(hImagesMissingError, 'top');
        else
            readSettings();
            
            if ~addToBatch()
                %Analysis Name already taken, return and let user pick different name
                return;   
            end
            set(hBatch, 'Visible', 'on');
            for b=1:numel(Batch)            %Batches are then analyzed in chronological order
                set(hBatch, 'String', Batch{b}{4});
                fileout=fullfile(Batch{b}{2}, Batch{b}{1});
                fileout=[fileout(1:end-4) '_' Batch{b}{4} '.mat'];
                if (hSimfitCheckbox.Value && settings.nrsim>10) || (hSimCheckbox.Value && settings.nrsim>50)
                    set(hProgress,'String','Performing analysis. This may take several hours');
                else
                    set(hProgress,'String','Performing analysis. This will take some minutes');
                end
                drawnow();
                if b==numel(Batch)
                    %Store Data if it was the last (or only) Analysis
                    Data=StartAnalysis(fullfile(Batch{b}{2}, Batch{b}{1}), Batch{b}{3}, hProgress, fileout,Batch{b}{4});
                else
                    StartAnalysis(fullfile(Batch{b}{2}, Batch{b}{1}), Batch{b}{3}, hProgress, fileout,Batch{b}{4});
                end
                set(hProgress, 'String', ['Saved results as: ' fileout]);
                drawnow();
            end
            if isfile('Batch.mat');delete('Batch.mat'); end
            %After finishing of the analyis, Batch file is deleted
            
        end
    end
end