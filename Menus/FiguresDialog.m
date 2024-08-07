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

function Data=FiguresDialog(datFile,Data)
initnargin=nargin;
outpath='';
settings.type='Figures';
settings.allGroupsname='All Groups';
settings.Origname='Original';
settings.SimNames={};

%Variables being filled when loading file or settings
loadsettings={};
settings.ClusterNames={};
orig=[];
names=[];
simnames=[];

%% Defaults for Advanced Menus
settings.CumProbOptions.makeNND=true;           
settings.CumProbOptions.makeAllDist=false;      
settings.CumProbOptions.makeCluster=true;       
settings.CumProbOptions.Box='off';              
settings.CumProbOptions.colorscheme=get(groot, 'defaultAxesColorOrder'); 
settings.CumProbOptions.LegendBox='on';
settings.CumProbOptions.LegendLineWidth=0.5;
settings.CumProbOptions.ylabeling='Cumulative Probability';
settings.CumProbOptions.xlabeling='Nearest Neighbour Distance [nm]';
settings.CumProbOptions.unwantedGroupTraces={settings.allGroupsname};
settings.CumProbOptions.unwantedNNDTraces={};
settings.CumProbOptions.unwantedClusterTraces={};
settings.CumProbOptions.unwantedSimulationTraces={};

settings.StatisticsOptions.makeDescriptive=true;
settings.StatisticsOptions.makeAnalytics=false;
settings.StatisticsOptions.makeCluster=true;
settings.StatisticsOptions.makeNND=true;
settings.StatisticsOptions.makeAllDist=true;
settings.StatisticsOptions.unwantedGroupTraces={};
settings.StatisticsOptions.unwantedNNDTraces={};
settings.StatisticsOptions.unwantedClusterTraces={};
settings.StatisticsOptions.unwantedSimulationTraces={};
settings.StatisticsOptions.make1by1=1;
settings.StatisticsOptions.particlesThreshold=10;
settings.StatisticsOptions.pval=0.05;
settings.StatisticsOptions.statfct=@mean;
settings.StatisticsOptions.ImageWisePopMeans=true;
settings.StatisticsOptions.makeDistEdge=true;
settings.StatisticsOptions.maketSNE=false;
settings.StatisticsOptions.makeIndiv=true;
settings.StatisticsOptions.outerRimDetails=true;
settings.StatisticsOptions.makeCorrel=true;

settings.figformat='.png';

settings.makeHist=false;

Defaultsettings=settings;

positionFigure =  [25, 50, 650, 555];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'Name', 'Make Figures & Tables'); 

figureColor = get(mainFigure, 'color'); % Gets the color.

hLoadingText = uicontrol('Style', 'Text', 'Position', [200 380 300 100], 'FontWeight', 'bold', 'foregroundcolor', 'blue', 'String', 'Loading File. This may take several minutes.',...
                    'FontSize', 16, 'Visible', 'Off');
hLoadedText = uicontrol('Style', 'Text', 'Position', [160 455 300 50], 'foregroundcolor', 'blue', 'String', 'File loaded successfully!', 'Visible', 'off');
hLoadFailureText= uicontrol('Style', 'Text', 'Position', [160 455 300 50], 'foregroundcolor', 'red', 'FontWeight', 'bold', 'String', 'File did not contain expected Data. Please make sure you provide the correct file', 'Visible', 'off');

hLoadSettings=uicontrol('Style', 'pushbutton', 'String', 'Load settings', 'Position', [480 480 100 25], 'Callback', @loadSettings, 'Tooltipstring', 'Load previously saved settings from file');
hLoadSettingsError=uicontrol('Style', 'Text', 'FontWeight', 'bold', 'foregroundcolor', 'red', 'Position', [460 430 160 50], 'String', 'Loading Settings failed. Did you provide the correct file?', ...
                            'Tooltipstring', 'Only files generated by the save button of this programm can be loaded', 'Visible', 'off');

hOutputPathText = uicontrol('Style', 'Text', 'String', 'Output folder:','backgroundcolor',figureColor,'HorizontalAlignment','left','Position', [25 430 100 25]);     
hOutputPathEdit = uicontrol('Style', 'Edit', 'String', 'Choose output folder name', 'Tooltipstring','Path to the Output folder.',...
                       'HorizontalAlignment','left','backgroundcolor','white','Position', [125 435 325 25]); 
hOutputPathButton = uicontrol('Style', 'pushbutton', 'String', 'Choose folder', 'Tooltipstring','Opens output folder','Position', [475 435 100 25], 'Callback', @openFolderOutput);

hChooseClusterNames=uicontrol('Style', 'pushbutton', 'String', 'Choose Cluster Parameter names', 'Position', [100 390 200 25], 'Callback', @selectClusterNames, 'Tooltipstring', sprintf('Select for which ClusterParameters figures should be made.\nYou can also chose names as how they will be displayed in figure'));

hAllGroupsText=uicontrol('Style', 'Text', 'String', 'All Groups name', 'Position', [350 385 85 25], 'Tooltipstring', 'Name that will be displayed for the sum of all groups');
hAllGroupsEdit=uicontrol('Style', 'Edit', 'String', settings.allGroupsname, 'Position', [440 390 85 25], 'Callback', @selectAllGroups, 'Tooltipstring', 'Name that will be displayed for the sum of all groups');

hOrigText=uicontrol('Style', 'Text', 'String', 'Original Name', 'Position', [25 350 60 25], 'Tooltipstring', 'Name for non-simulated Original Data. Will be displayed in the figure');
hOrigEdit=uicontrol('Style', 'Edit', 'String', settings.Origname, 'Position', [85 350 110 25], 'Tooltipstring', 'Name for non-simulated Original Data. Will be displayed in the figure');


%Empty Variables for namefields for Simulations, which are being generated when file is loaded
hSimTexts={};
hSimEdits={};

%Group Selection
hAllowGroupSelection=uicontrol('Style', 'checkbox', 'String', 'Select Groups', 'Position', [60 300 150 25],'Callback',@activateGroups);
hGroupSelection=uicontrol('Style', 'listbox', 'min', 0, 'Position', [190 260 130 80], 'enable', 'off');

%Advanced Menus


hStatistics=uicontrol('Style','Checkbox', 'String', 'Statistics & Metrics', 'Position', [50 205 180 25], 'Tooltipstring', 'Check if statistics metrics should be computed', 'Value',1);
hStatisticsAdvanced=uicontrol('Style', 'pushbutton', 'String', 'Advanced Statistics & Metrics Options', 'Position', [230 205 300 25], 'Callback', @advancedStatistics);

hCumProb=uicontrol('Style','Checkbox', 'String', 'Cumulative Probability Plot', 'Position', [50 175 180 25], 'Tooltipstring', 'Check if Cumulative probability plots should be produced');
hCumProbAdvanced=uicontrol('Style', 'pushbutton', 'String', 'Advanced Cumulative Probability Plot Options', 'Position', [230 175 300 25], 'Callback', @advancedCumProb);

hFigFormatText=uicontrol('Style', 'Text', 'String', 'Fileformat for Images', 'Position', [50 115 175 25], 'Tooltipstring', 'Select fileformat of output images');
hFigFormatDropDown=uicontrol('Style', 'popup', 'Position', [230 115 80 25], 'String', {'.png', '.eps', '.fig'}, 'Tooltipstring', 'Select fileformat of output images');



hSaveSettings=uicontrol('Style', 'pushbutton', 'String', 'Save settings', 'Position', [75 45 90 30], 'Tooltipstring', 'Save current settings to file', 'Callback', @saveSettings);
hSavedSettingSuccess=uicontrol('Style', 'Text', 'String', 'Saved successfully', 'Position', [75 75 90 15], 'foregroundcolor', 'blue', 'Visible', 'off');

hStartFigureMaking=uicontrol('Style', 'pushbutton', 'Position', [250 35 110 50], 'String', 'Make Figures', 'Callback', @StartMaking, 'Tooltipstring', 'Start producing figures and statistics');
hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [220 85 180 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [430 45 90 30], 'Callback', @Close);
hNoOutpathError=uicontrol('Style', 'Text', 'Position', [100 80 100 30], 'foregroundcolor', 'red', 'FontWeight', 'bold', 'String', 'No Output Folder has been selected!', 'Tooltipstring', 'Please select a folder to which the figures will be saved!', 'Visible', 'off');


applyData();
set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable


% Waits for the figure to close to end the function.
waitfor(mainFigure);

    function activateGroups(hOb,~)
        if hOb.Value==1
            if isfield(Data, 'GroupNamesForClusterDistance')
                answer=questdlg(sprintf('Clustering distance has been calculated seperatly according to groups within %s.\nChanging the groups may pool images with different clustering distances!\nAre you sure you want to proceed?',...
                    strjoin(Data.GroupNamesForClusterDistance, ', ')), ...
                    'Group cluster distance confirmation', 'yes', 'no', 'no');
                if strcmp(answer,'no')
                    hOb.Value=0;
                    return
                end
            end
            set(hGroupSelection, 'enable', 'on');
            
        else
            set(hGroupSelection, 'enable', 'off');
        end
    end

%% Loads file

    
    function applyData()
        if ~isfield(Data,'methodA') || ~isfield(Data,'methodB') || ~isfield(Data,'Orig')
            set(hLoadFailureText, 'Visible','on');
            return
        end
        names=Data.names;
        if isempty(names)
            printNames=Data.allName;
        else
            printNames=names{1};
            for i=2:numel(names)
                if i==numel(names)
                    printNames=[printNames ' and ' names{i}];
                else
                    printNames=[printNames ', ' names{i}];
                end
            end
        end
        set(hLoadedText, 'String', ['This analysis (' Data.analysisName ') contains Data on ' printNames '.'], 'Visible', 'on'); 

        groupnames=readGroups(datFile);
        
        if numel(groupnames)>1
            set(hGroupSelection, 'String', groupnames, 'max', numel(groupnames));
            if isfield(Data, 'GroupsForClusterDistance')
                hGroupSelection.Value=Data.GroupsForClusterDistance;
            else
                def=readDefaults();
                def=updateDefaults(getOptionsName(datFile),def);
                hGroupSelection.Value=def.chosenGroups;
            end
            if isToolkitAvailable('Simulink') & Simulink.getFileChecksum(datFile)~=Data.checksum
                set(hAllowGroupSelection, 'enable', 'off');
                fprintf('Warning: %s has changed since the analysis was run', datFile);
                set(hAllowGroupSelection,'Tooltipstring', ...
                    sprintf('%s has changed since the analysis was run\nRerun analysis to be able to select groups', datFile));
            end
        else
            set(hAllowGroupSelection, 'Visible', 'off');
            set(hGroupSelection, 'Visible', 'off');
        end
        orig=Data.Orig;
        clstNames=fieldnames(orig.ClusterInteraction{1});
        clstNames=clstNames(3:end);     %Remove fields that aren't useful for making figures
        settings.ClusterNames={clstNames{:}; clstNames{:}}';
        orig=[];
        %Make fields to choose Names for simulations.
        simnames=Data.simnames;
        for s=1:numel(simnames) %For all types of simulation
            hSimTexts{s}=uicontrol('Style', 'Text', 'Position', [25+s*170 350 60 25], 'Tooltipstring', 'Name of the Simulation. Will be displayed in figure');
            hSimEdits{s}=uicontrol('Style', 'Edit', 'Position', [85+s*170 350 110 25], 'Callback', @(hObj, ~)setSimName(hObj, s), 'Tooltipstring', 'Name of the Simulation. Will be displayed in figure');
            switch simnames{s}
                case 'Sim'
                    set(hSimTexts{s}, 'String', 'random Sim');
                    set(hSimEdits{s}, 'String', 'random Simulation');
                    settings.SimNames{s}='random Simulation';
                case 'SimFit'
                    set(hSimTexts{s}, 'String', 'fitted Sim');
                    set(hSimEdits{s}, 'String', 'fitted Simulation');
                    settings.SimNames{s}='fitted Simulation';
                otherwise
                    set(hSimTexts{s}, 'String', simnames{s});
                    set(hSimEdits{s}, 'String', simnames{s});
                    settings.SimNames{s}=simnames{s};
            end
        end
        Defaultsettings=settings;
    end

%Gets output folder from user
    function openFolderOutput( ~, ~)
        set(hNoOutpathError, 'Visible', 'off');
        if initnargin>0 && isfile(datFile)
            outpath=uigetdir(fileparts(datFile));
        else
            outpath = uigetdir();
        end
        
        % Updates the interface.
        set(hOutputPathEdit, 'String', outpath);         
        
    end
%Exit
    function Close(~,~)
        delete(gcf);
    end

%Gets the name for the sum of all groups
    function selectAllGroups(hObj, ~)
        string=get(hObj, 'String');
            %Update unwanted Traces with the new name if neccessary
        if ismember(settings.allGroupsname, settings.CumProbOptions.unwantedGroupTraces)
            settings.CumProbOptions.unwantedGroupTraces(strcmp(settings.CumProbOptions.unwantedGroupTraces, settings.allGroupsname))=[];
            settings.CumProbOptions.unwantedGroupTraces{end+1}=string;
        end
        if ismember(settings.allGroupsname, settings.StatisticsOptions.unwantedGroupTraces)
            settings.StatisticsOptions.unwantedGroupTraces(strcmp(settings.StatisticsOptions.unwantedGroupTraces, settings.allGroupsname))=[];
            settings.StatisticsOptions.unwantedGroupTraces{end+1}=string;
        end
        settings.allGroupsname=string;
    end
    
    %Set the displayed Name of a certain type of simulation
    function setSimName(hObj, s)
        string=get(hObj, 'String');
            %Update unwanted Traces with the new name if neccessary
        if ismember(settings.SimNames{s}, settings.CumProbOptions.unwantedSimulationTraces)
            settings.CumProbOptions.unwantedSimulationTraces(strcmp(settings.CumProbOptions.unwantedSimulationTraces, settings.SimNames{s}))=[];
            settings.CumProbOptions.unwantedSimulationTraces{end+1}=string;
        end
        if ismember(settings.SimNames{s}, settings.StatisticsOptions.unwantedSimulationTraces)
            settings.StatisticsOptions.unwantedSimulationTraces(strcmp(settings.StatisticsOptions.unwantedSimulationTraces, settings.SimNames{s}))=[];
            settings.StatisticsOptions.unwantedSimulationTraces{end+1}=string;
        end
        settings.SimNames{s}=string; 
    end

%Functions calling advanced Menus

    function advancedCumProb(~,~)
        settings.CumProbOptions=MenuCumProb(settings.CumProbOptions, Data, settings);
    end

    function advancedStatistics(~,~)
        settings.StatisticsOptions=MenuStatistics(settings.StatisticsOptions, Data, settings);
    end
    function selectClusterNames(~,~)
       settings.ClusterNames=MenuClusterNaming(Data,settings.ClusterNames); 
    end
    
%Saves all user input to appropriate variables
    function readSettings()
        settings.makeCumProb=get(hCumProb, 'Value');
        settings.makeStatistics=get(hStatistics, 'Value');
        tempstr=get(hFigFormatDropDown, 'String');
        settings.figformat=tempstr{get(hFigFormatDropDown, 'Value')};
    end

%Saves settings as .mat file to a user-defined location
    function saveSettings(~, ~)
        readSettings();
        [saveFile, savePath]=uiputfile('*.mat');
        saveFile=fullfile(savePath, saveFile);        
        save(saveFile,'settings');
        set(hSavedSettingSuccess, 'Visible', 'on');
    end

    function newSettings=ensureSettingsFunctionality(newSettings, Default)
        % If the program has been updated since settings have been saved
        % The program may require some Settings that have not been saved, because the functionality didn't exist
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

%Loads settings file
    function loadSettings(~,~)
        set(hLoadSettingsError, 'Visible', 'off');
        [loadFile, loadPath]=uigetfile('*.mat');
        loadFile=fullfile(loadPath,loadFile); 
        loadsettings=load(loadFile);
        try
            if strcmp(settings.type, 'Figures')
                settings=ensureSettingsFunctionality(loadsettings.settings, Defaultsettings);
                set(hCumProb, 'Value', settings.makeCumProb);
                set(hStatistics, 'Value', settings.makeStatistics);
                set(hMetrics, 'Value', settings.makeMetrics);
                set(hFigFormatDropDown, 'Value', find(~cellfun('isempty', strfind(get(hFigFormatDropDown,'String'),settings.figformat))));
            else
                set(hLoadSettingsError, 'Visible', 'on');
            end
        catch
            set(hLoadSettingsError, 'Visible', 'on');
        end
    end
        
%StartAnalysis
    function StartMaking(~,~)
        readSettings();
        if strcmp(outpath,'')
            set(hNoOutpathError, 'Visible', 'on');
            return;
        end
        if hAllowGroupSelection.Value
            %Modify Data.Groups to reflect new chosen groups
            chosenGroups=hGroupSelection.Value;
            Data.Groups=getInfoGroups(datFile, chosenGroups);
        end
        
        makeFigures(Data,datFile,outpath,settings,hProgress);
        set(hProgress, 'String', 'Figures produced successfully');
    end
end