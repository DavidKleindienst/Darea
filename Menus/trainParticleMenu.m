function trainParticleMenu(datFile)
%TRAINPARTICLEMENU Summary of this function goes here
%   Detailed explanation goes here
settings=readDefaults();
if nargin>0
    settings=updateDefaults(getOptionsName(datFile), settings);
end

classifiers=listClassifiers();
classifiers=[{'None'}; classifiers(:)];
algorithms={'naiveBayes', 'randomForest'};

positionFigure =  [25, 50, 650, 505];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Train Particle Prediction'); 
set(mainFigure, 'CloseRequestFcn', @close);

filesTT='';
uicontrol('Style', 'Text', 'String', 'Config Files', 'Position', [35 420 80 25], 'Tooltipstring', filesTT);
hFiles=uicontrol('Style', 'listbox', 'Position', [120 370 150 100], 'Tooltipstring', filesTT, 'Min', 0, 'Max', 3, 'Value', []);
if nargin>0
    set(hFiles, 'String', {datFile});
end
hAdd=uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [275 430 20 20], 'Callback', @add);
hRemove=uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [275 410 20 20], 'Callback', @remove);

useDataTT='';
uicontrol('Style', 'Text', 'String', 'Use Data from', 'Position', [35 315 80 25], 'Tooltipstring', useDataTT);
hData=uicontrol('Style', 'popup', 'String', classifiers, 'Position', [115 315 90 25], 'Tooltipstring', useDataTT);

saveAsTT=sprintf('Name under which new classifier should be saved\nOld Classifiers will be overwritten if you choose existing name');
uicontrol('Style', 'Text', 'String', 'Name', 'Position', [230 315 80 25], 'Tooltipstring', saveAsTT);
hSaveAs=uicontrol('Style', 'Edit', 'Position', [315 315 100 25], 'Tooltipstring', saveAsTT);
hfnError=uicontrol('Style', 'Text', 'String', 'You have to enter a name for saving the classifier', ...
                'Visible', 'off', 'Position', [230 290 180 20], 'FontWeight', 'bold', 'foregroundcolor', 'red');

algoTT='Algorithm to use for training';
uicontrol('Style', 'Text', 'String', 'Algorithm', 'Position', [35 250 80 25],'Tooltipstring', algoTT);
hAlgo=uicontrol('Style', 'popup', 'String', algorithms, 'Position', [115 250 130 25], 'Tooltipstring', algoTT);

sensTT=sprintf('Sensitivity of circle detection\nLeave empty to use value from settings\nThis way different values can be used for different dat-files');
uicontrol('Style', 'Text', 'String', 'Sensitivity', 'Position', [315 250 80 25],'Tooltipstring', sensTT);
hSensitivity=uicontrol('Style', 'Edit', 'String', num2str(settings.sensitivity), 'Position', [395 250 80 25],'Tooltipstring', sensTT);

marginTT=sprintf('Margin of radius detected\nLeave empty to use value from settings\nThis way different values can be used for different dat-files');
uicontrol('Style', 'Text', 'String', 'Margin', 'Position', [315 220 80 25], 'Tooltipstring', marginTT);
hMargin=uicontrol('Style', 'Edit', 'String', num2str(settings.marginNm), 'Position', [395 220 80 25], 'Tooltipstring', marginTT);

hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [220 100 180 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');

hStart=uicontrol('Style', 'pushbutton', 'String', 'Train', 'Tooltipstring', 'Start Training', 'Position', [300 60 90 30], 'Callback', @start);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [430 60 90 30], 'Callback', @close);

waitfor(mainFigure);



function close(~,~)
    delete(gcf);
end

function start(~,~)
    filename=get(hSaveAs, 'String');
    if isempty(filename)
        set(hfnError, 'Visible', 'on');
        return
    else
        set(hfnError, 'Visible', 'off');
    end
    if ismember(classifiers, filename)
        choice = questdlg('A classifier with this name already exists. If you continue it will be overwritten!', ...
                'Warning', 'Continue', 'Cancel','Cancel');
        if strcmp(choice, 'Cancel')
            return
        end
    end

    datFiles=get(hFiles, 'String');
    algo=algorithms{get(hAlgo, 'Value')};
    dval=get(hData, 'Value');
    if dval==1
        data=0;
    else
        data=classifiers{dval};
    end
    sensitivity=str2double(get(hSensitivity, 'String'));    %Will be NaN if not a number
    margin=str2double(get(hMargin, 'String'));   %Then parameters will be gathered from each settings file
    
    set(hProgress, 'String', 'Gathering Training Data (this will take a while)...');
    drawnow();
    [features,classes, radii]=getTrainingData(datFiles,sensitivity,margin);
    if data
        set(hProgress, 'String', 'Loading Previous Data...');
        drawnow();
        dataset=load(fullfile(settings.classifierPath, [data '_data.mat']));
        sharedRadii=intersect(radii,dataset.radii);
        for r=1:numel(sharedRadii)
            idx=radii==sharedRadii(r);
            didx=dataset.radii==sharedRadii(r);
            classes{idx}=[classes{idx}(:); dataset.classes{didx}(:)];
            features{idx}=[features{idx}(:,:); dataset.features{didx}(:,:)];
        end
        rOnlyinData=setdiff(dataset.radii,radii);
        for r=1:numel(rOnlyinData)
            idx=numel(radii)+r;
            didx=dataset.radii==rOnlyinData(r);
            classes{idx}=dataset.classes{didx};
            features{idx}=dataset.features{didx};
        end
        radii=[radii, rOnlyinData];
    end
    set(hProgress, 'String', 'Performing Training...');
    drawnow();
    classifierTraining(features, classes, radii, filename, algo);
    set(hProgress, 'String', 'Finished Training');
    
end

function add(~,~)
    [infoFile, folder] = uigetfile('*.dat');
    newdatFile=fullfile(folder,infoFile);
    str=get(hFiles, 'String');
    if isempty(str)
        str={newdatFile};
    else
        str{end+1}=newdatFile;
    end
    set(hFiles, 'String', unique(str));
end

function remove(~,~)
    str=get(hFiles, 'String');
    val=get(hFiles, 'Value');
    str(val)=[];
    set(hFiles, 'String', str);
    set(hFiles, 'Value', []);
end

end