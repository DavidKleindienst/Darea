function predictMenu(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~downloadWeights()
    return;
    %This function needs pre-trained weights
end

if nargin==0
    [infoFile, folder] = uigetfile('*.dat');
    datFile=fullfile(folder,infoFile);
end

settings=readDefaults();
settings=updateDefaults(getOptionsName(datFile),settings);
% Find for which features we have trained networks
features=getTrainedNetworks();


positionFigure =  [25, 50, 650, 505];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Automated Demarcation'); 
set(mainFigure, 'CloseRequestFcn', @close);

featureTT='Select which feature should be predicted';
hPredDemarc=uicontrol('Style','checkbox', 'String', 'Predict Demarcation', 'Position', [35 430 150 25]);
hFeatureText=uicontrol('Style','Text','String','Predict:', 'Position', [50 400 75 25], 'Tooltipstring', featureTT);
hFeatureDD=uicontrol('Style','popup','String',features, 'Position', [130 400 100 25], 'Tooltipstring', featureTT);
hOverwrite=uicontrol('Style','checkbox', 'String', 'Overwrite existing demarcations', 'Position', [50 380 200 25]);


hPredParticles=uicontrol('Style', 'checkbox', 'String', 'Predict Particles', 'Position', [35 250 150 25]);
hOverwriteP=uicontrol('Style', 'checkbox', 'String', 'Overwrite existing particles', 'Position', [50 230 200 25]);

demTT=sprintf('Tick to limit particle prediction to demarcation only (much faster)\nOtherwise particles will be predicted on complete image (recommended when done at same time as demarcation prediction)');
hUseDemarc=uicontrol('Style', 'checkbox', 'String', 'Predict on Demarcation only', 'Position', [50 205 200 25], 'Tooltipstring', demTT);
    

uicontrol('Style', 'Text', 'String', 'Sensitivity', 'Position', [240 250 80 25]);
hSensitivity=uicontrol('Style', 'Edit', 'String', num2str(settings.sensitivity), 'Position', [320 250 80 25]);

uicontrol('Style', 'Text', 'String', 'Margin', 'Position', [240 220 80 25]);
hMargin=uicontrol('Style', 'Edit', 'String', num2str(settings.marginNm), 'Position', [320 220 80 25]);

%Classifier
classifiers=listClassifiers();
hClassifierText=uicontrol('Style', 'Text', 'String', 'Classifier', 'Position', [430 250 80 25], 'HorizontalAlignment', 'left');
defaultId=find(ismember(classifiers,settings.defaultClassifier));
hClassifier=uicontrol('Style', 'popup', 'String', classifiers, 'Value', defaultId, 'Position', [430 230 150 25]);

if numel(classifiers)<2
    %Don't show if only one classifier exists
    set(hClassifierText, 'Visible', 'off');
    set(hClassifier, 'Visible', 'off');
end

hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [220 100 180 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');

hStart=uicontrol('Style', 'pushbutton', 'String', 'Start', 'Tooltipstring', 'Start Prediction', 'Position', [300 60 90 30], 'Callback', @start);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [430 60 90 30], 'Callback', @close);

waitfor(mainFigure);


function start(~,~)
    if get(hPredParticles,'Value')
        %Start a parallel pool when predicting particles
        %It is started now already because it will save little bit of time
        %for image conversion for demarcation prediction
        try
            parpool();  
        end
    end
    if get(hPredDemarc, 'Value')
        feature=features{get(hFeatureDD,'Value')};
        set(hProgress, 'String', 'Starting Demarcation Prediction');
        drawnow();
        try
            predict(datFile,feature,hProgress,get(hOverwrite,'Value'),settings);
        catch expt
            set(hProgress, 'String', 'Demarcation Prediction failed');
            rethrow(expt);
        end
    end
    if get(hPredParticles, 'Value')
        settings.sensitivity=str2double(get(hSensitivity, 'String'));
        settings.marginNm=str2double(get(hMargin, 'String'));
        useClassifier=classifiers{get(hClassifier, 'Value')};
        set(hProgress, 'String', 'Predicting Particles');
        drawnow();
        getParticlesAllImages(datFile,get(hUseDemarc, 'Value'),get(hOverwriteP, 'Value'),useClassifier,settings);
    end
    set(hProgress, 'String', 'Finished Predictions');
end

function close(~,~)
    delete(gcf);
end


end

