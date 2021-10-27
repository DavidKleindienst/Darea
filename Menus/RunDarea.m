function RunDarea(datFile)
%% The programs main GUI window

%Run setPath only at first start, for quicker startup afterwards
persistent pythonAvailable
if isempty(pythonAvailable)
    pythonAvailable=setPath();
end
%% For holding variables
if nargin==0
    datFile='';
end
Data=NaN;
if isfile('Batch.mat')
    %If Batch analysis failed or was interrupted it did not clean up
    %properly
    delete('Batch.mat');
end

%% Darea Main Menu
%any 0 in position indicates that this value will be computed later using align
mainMenu=figure('OuterPosition',[65, 155, 730, 405],'menubar', 'none', 'resize','off', 'Name', 'Darea');

% Loading dat file
hImageLPathText = uicontrol('Style', 'Text', 'String', 'Image list file:','HorizontalAlignment','left','Position', [25 335 100 25]);     
hImageLPathEdit = uicontrol('Style', 'Text', 'String', 'No File Chosen', 'Tooltipstring','Path to the file containing the list of images.',...
                       'HorizontalAlignment','left','backgroundcolor','white','Position', [125 0 325 25]); 
hImageLPathButton = uicontrol('Style', 'pushbutton', 'String', 'Load Project', 'Tooltipstring','Opens image list file', ...
                        'Position', [475 0 100 25], 'Callback', @openFileImages);
hMakeConfig = uicontrol('Style', 'pushbutton', 'String', 'Create Project',  'HorizontalAlignment','left', 'Position', ...
                [600 0 100 25], 'Callback', @makeConfig, 'Tooltipstring', 'Makes Configuration file from folder structure');
align([hImageLPathText, hImageLPathEdit, hImageLPathButton, hMakeConfig], 'none','top');

hImages = uicontrol('Style', 'pushbutton', 'String', 'Manage Images', 'Position', [600 290 100 25], ...
                    'Callback', @(~,~)launchFunction(@manageImages));

hProject = uicontrol('Style', 'pushbutton', 'String', 'Project Settings', 'Position', [600 250 100 25], ...
                    'Callback', @(~,~)launchFunction(@projectSettings));
hGroups = uicontrol('Style', 'pushbutton', 'String', 'Group Settings', 'Position', [600 210 100 25], ...
                    'Callback', @(~,~)launchFunction(@groupMenu));

                
%Preparation functions
uicontrol('HorizontalAlignment','left', 'Style','Text','String', 'Image Preparation', 'Position', [20 290 250 25], 'FontWeight', 'bold');
ttPrepro=sprintf('Image preprocessing\ne.g. convert to 16bit, adjust contrast, invert images.');
ttDemarcate=sprintf('Demarcate Area of Interest');
ttParticles=sprintf('Detect gold particles');
hPrepro=uicontrol('Style', 'pushbutton', 'String', 'Preprocessing', 'Tooltipstring', ttPrepro, 'Position',[25 270 100 25], ...
                'Callback', @(~,~)launchFunction(@preprocessingMenu));
hDemarcate=uicontrol('Style', 'pushbutton', 'String', 'Demarcate', 'Tooltipstring', ttDemarcate, 'Position',[140 0 100 25], ...
                'Callback', @(~,~)launchOpener( @demarcate,'demarcate Area', '_mod.tif'));
hParticles=uicontrol('Style', 'pushbutton', 'String', 'Particles', 'Tooltipstring', ttParticles, 'Position',[255 0 100 25], ...
                'Callback', @(~,~)launchOpener(@particleLabeling,'Particle labeling','dots.csv'));        
align([hPrepro, hDemarcate, hParticles], 'none','top');

%Analysis function
uicontrol('HorizontalAlignment','left', 'Style','Text','String', 'Image Analysis', 'Position', [20 235 250 25], 'FontWeight', 'bold');
ttAnalysis=sprintf('Measure area, density, perform simulations and cluster analysis');
ttFigures=sprintf('Calculate statistics and make figures');
hAnalysis=uicontrol('Style', 'pushbutton', 'String', 'Analysis', 'Tooltipstring', ttAnalysis, 'Position',[25 215 100 25], ...
                'Callback', @(~,~)launchAnalysis(true));
hFigures=uicontrol('Style', 'pushbutton', 'String', 'Figures', 'Tooltipstring', ttFigures, 'Position',[140 0 100 25], ...
                'Callback', @(~,~)launchWithData(@FiguresDialog));
hVisualize=uicontrol('Style', 'pushbutton', 'String', 'Visualize', 'Tooltipstring', 'Visualize image and simulations', ...
                'Position', [255 0 100 25], 'Callback', @(~,~)launchWithData(@visualize,'Visualize',NaN));
align([hAnalysis, hFigures,hVisualize], 'none','top');

%DeepLearningStuff
uicontrol('HorizontalAlignment','left', 'Style','Text','String', 'DeepLearning', 'Position', [20 180 250 25], 'FontWeight', 'bold');
ttPredict='Use deeplearning to demarcate images';
hPredict=uicontrol('Style', 'pushbutton', 'String', 'Automated Prediction', 'Tooltipstring', ttPredict, 'Position', [20 160 110 25], ...
                    'Callback', @(~,~)launchFunction(@predictMenu));
hTrainPart=uicontrol('Style', 'pushbutton', 'String', 'Train particle detection', 'Tooltipstring', 'Learn particle prediction based from data', ...
                    'Callback', @(~,~)launchFunctionWithoutDat(@trainParticleMenu), 'Position', [135 160 120 25]);
hTrain=uicontrol('Style', 'pushbutton', 'String', 'Train demarcation', 'Callback', @(~,~)launchFunctionWithoutDat(@TrainMenu),'Position', [270 160 120 25]);            


if nargin>0
    set(hImageLPathEdit,'String',datFile);
end

needsPythonDeepLearning={hPredict};
needsPython=[{hMakeConfig}, needsPythonDeepLearning(:)'];
if ~pythonAvailable
    for i=1:numel(needsPython)
        set(needsPython{i}, 'tooltipstring', 'This functionality requires python to be installed and properly configured.');
        jButton= findjobj(needsPython{i});
        set(jButton,'Enabled',false);
    end
elseif deepLearningAvailable()
    for i=1:numel(needsPythonDeepLearning)
        set(needsPythonDeepLearning{i}, 'tooltipstring', ...
        'This functionality requires certain python packages such as tensorflow to be installed.');
        jButton= findjobj(needsPythonDeepLearning{i});
        set(jButton,'Enabled',false);
    end
end

waitfor(mainMenu);


function bool=openFileImages(~,~)
    global lastfolder
    if isempty(lastfolder)
        lastfolder=cd;
    end
    [infoFile, folder] = uigetfile('*.dat', 'Choose project file', lastfolder);
    if ischar(folder)
        lastfolder=folder;
    end
    datFile=fullfile(folder,infoFile);
    if isstruct(Data)
        Data=NaN;   %Delete potentially existing Data when opening new file
    end
    set(hImageLPathEdit,'String',datFile);
    bool=isfile(datFile);
end

function bool=existsDatFile()
    if datFile
        bool=true;
        return
    else
        bool=openFileImages(0,0);
    end
end
function launchFunctionWithoutDat(fct)
    if datFile
        fct(datFile);
    else
        fct();
    end
    figure(mainMenu);
end

function launchFunction(fct)
    if ~existsDatFile()
        return
    end
    fct(datFile);
    figure(mainMenu); %Bring Menu to foreground
end
function launchAnalysis(batch)
    if batch
        if exist('Batch.mat', 'file')==2       %Delete former batch files if they exist
            delete('Batch.mat');
        end
        ret=1;
        while ret==1                           %Loop to allow for batch processing
            if datFile
                [Data, ret]=analysisDialog(datFile);
            else
                [~, ret]=analysisDialog();
            end
        end
    else
        if datFile
            Data=analysisDialog(datFile);
        else
            analysisDialog(datFile);
        end
    end
    figure(mainMenu); %Bring Menu to foreground
end
function launchOpener(fct,title,fileextension)
    if ~existsDatFile()
        return
    end
    if isstruct(Data)
        Data=openImages(title,fct,fileextension,datFile,Data);
    else 
        Data=openImages(title,fct,fileextension,datFile);
    end
    figure(mainMenu); %Bring Menu to foreground
end
function launchWithData(fct,title,filextension)
    if ~existsDatFile()
        return
    end
    analysis=selectAnalysis();
    if isequal(analysis,-1)
        %User cancelled selection
        return;
    end
    if ~isstruct(Data) || ~(( isempty(Data.analysisName) && isempty(analysis) ) || strcmp(Data.analysisName,analysis))
        
        msg=msgbox('Loading Data...');
        if ~loadDataFile(analysis)
            delete(msg);
            msgbox('Loading Data failed. Have you run the analysis?');
            return
        end
        delete(msg);
    end
    if nargin>1
        Data=openImages(title,fct,filextension,datFile,Data);
    else
        Data=fct(datFile,Data);
    end
    figure(mainMenu); %Bring Menu to foreground
end

function analysis=selectAnalysis()
    [folder, fname]=fileparts(datFile);
    names=dir(folder);
    names={names.name};
    names=names(startsWith(names,fname));
    names=names(endsWith(names,'.mat'));
    names=cellfun(@(x)x(numel(fname)+1:end), names, 'UniformOutput', false); %Remove datfile part of filename
    names=cellfun(@(x)x(1:end-4),names,'UniformOutput', false); %remove extension
    names(startsWith(names,'_'))=cellfun(@(x)x(2:end), names(startsWith(names,'_')), 'UniformOutput', false);
    if numel(names)==1
        %If there is only one, use that
        analysis=names{1};
        return;
    elseif numel(names)==0
        msgbox('No analysis file found. Have you run the analysis?');
        analysis=-1;
        return;
    end
    %Otherwise ask user which one
    displayNames=names;
    if any(cellfun(@isempty, displayNames)); displayNames{cellfun(@isempty, displayNames)}='(untitled)'; end
    [idx, tf]=listdlg('PromptString','Select which analysis to load:','ListString',displayNames,'SelectionMode','single');
    if tf
        analysis=names{idx};

    else
        %User cancelled load
        analysis=-1;
    end
    
end

function bool=loadDataFile(analysis)
    if ~isempty(analysis)
        analysis=['_' analysis];
    end
    dataFile=[datFile(1:end-4) analysis '.mat'];
    assert(isfile(dataFile));
    Data=loadData(dataFile);
    if ~isstruct(Data)
        %load not successful
        bool=false;
        return
    end
    bool=true;
    
end


function makeConfig(~,~)
    datFile=importImages();
    if isstruct(Data)
        Data=NaN;   %Delete potentially existing Data when opening new file
    end
    set(hImageLPathEdit,'String',datFile);
    figure(mainMenu); %Bring Menu to foreground
end
end
