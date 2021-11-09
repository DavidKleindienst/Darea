function TrainMenu(datFile)
%TRAINMENU Summary of this function goes here
%   Detailed explanation goes here

if ~downloadWeights()
    return;
    %This function needs pre-trained weights
end

defaults=readDefaults();
if nargin>0
    defaults=updateDefaults(getOptionsName(datFile), defaults);
end
positionFigure =  [25, 50, 650, 565];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Train Demarcation Prediction'); 
set(mainFigure, 'CloseRequestFcn', @close);

bg=uibuttongroup('SelectionChangedFcn', @changeInterface);

hTrainFromDataset=uicontrol(bg,'Style','Radiobutton', 'Position', [60 500 460 20], ...
            'String', 'Train from prepared dataset');  
hPrepareDataset=uicontrol(bg, 'Style', 'Radiobutton', 'Position', [60 480 460 20], ...
               'String', 'Prepare a dataset for training from folder containing projects');
hPrepareDatasetFromConfig=uicontrol(bg, 'Style', 'Radiobutton', 'Position', [60 460 460 20], ...
               'String', 'Prepare a dataset for training from one or multiple projects');
hTestFromDataset=uicontrol(bg,'Style','Radiobutton', 'Position', [60 440 460 20], ...
            'String', 'Test trained network on dataset');
hTrainFromConfig=uicontrol(bg,'Style','Radiobutton', 'Position', [60 420 460 20], ...
            'String', 'Train from one or multiple projects');
hTestFromConfig=uicontrol(bg,'Style','Radiobutton', 'Position', [60 400 460 20], ...
            'String', 'Test trained network on project');


folderTT='Select folder with prepared datasets';
hFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose dataset folder path', ...
                    'Tooltipstring',folderTT, 'Position', [25 365 375 25], ...
                    'Callback',@(hOb,~)openFolder(hOb)); 

inputFolderTT=sprintf(['Choose the input folder which should contain one folder per feature.\n' ...
                      'Each feature folder should contain all the relevant project files']);
hInputFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose input folder', ...
    'Tooltipstring', inputFolderTT, 'Position', [25 265 275 25],'Callback', @(hOb,~)openFolder(hOb));
outputFolderTT=sprintf(['Select Output Folder\nThe prepared dataset will be stored there\n' ...
                'This should be an empty folder, or the folder where the same perepared datasets where saved to before']);
hOutputFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose output folder', ...
    'Tooltipstring', outputFolderTT, 'Position', [325 265 275 25],'Callback', @(hOb,~)openFolder(hOb));

datTestTT=sprintf('Select project File');
hDatTestButton=uicontrol('Style', 'pushbutton', 'String', 'Choose project file', ...
                'Tooltipstring', datTestTT, 'Position', [25 365 375 25], ...
                'Callback', @(hOb,~)openDatFile(hOb));

resultFolderTT=sprintf('Select where to save results');
hResultsFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose results folder', ...
                    'Tooltipstring', resultFolderTT, 'Position', [25 335 375 25], ...
                    'Callback', @(hOb,~)openFolder(hOb));

filesTT='Select datfiles from which to train';
hFileTxt=uicontrol('Style', 'Text', 'String', 'Config Files', 'Position', [35 350 80 25], 'Tooltipstring', filesTT);
hFiles=uicontrol('Style', 'listbox', 'Position', [120 300 350 100], 'Tooltipstring', filesTT, 'Min', 0, 'Max', 3, 'Value', []);
if nargin>0
    set(hFiles, 'String', {datFile});
end
hAdd=uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [480 360 20 20], 'Callback', @add);
hRemove=uicontrol('Style', 'pushbutton', 'String', '–', 'Position', [480 330 20 20], 'Callback', @remove);

featTT='Name the feature you would like to predict (e.g. PSD)';
hFeatText=uicontrol('Style', 'Text', 'String', 'Feature', 'Position', [25 260 60 25], 'Tooltipstring', featTT);
hFeatPopup=uicontrol('Style', 'popup', 'Position', [90 260 130 25], 'Tooltipstring', featTT, 'Enable', 'off', 'String',{''});


epochsTT=sprintf('How often the network will be trained on each image\nThe more epochs the longer it takes but the better the result\nPlease refer to the handbook for details');
hEpochsText=uicontrol('Style', 'Text', 'String', 'Epochs', 'Position', [25 230 60 25], 'Tooltipstring', epochsTT);
hEpochsEdit=uicontrol('Style', 'Edit', 'String', num2str(defaults.epochs), 'Position', [90 230 60 25], 'Tooltipstring', epochsTT, 'Callback', @updateEpochs);

batchSizeTT=sprintf('How many images to process at once. Depends on your GPU memory or RAM\nLeave the default or refer to the handbook for details');
hBatchText=uicontrol('Style','Text', 'String', 'BatchSize', 'Position', [200 230 60 25], 'Tooltipstring', batchSizeTT);
hBatchEdit=uicontrol('Style', 'Edit', 'String', num2str(defaults.batchSize), 'Position', [265 230 30 25], 'Tooltipstring', batchSizeTT, 'Callback', @updateBatchSize);


learnRateTT=sprintf('How fast the network should learn\nLeave the default or refer to the handbook for details');
hLearnRateText=uicontrol('Style', 'Text', 'String', 'Learn Rate', 'Position', [345 230 60 25], 'Tooltipstring', learnRateTT);
hLearnRateEdit=uicontrol('Style', 'Edit', 'String', num2str(defaults.learnRate), 'Position', [410 230 60 25], 'Tooltipstring', learnRateTT, 'Callback', @updateLearnRate);


trained_networks=getTrainedNetworks();
trained_networks=[{'None'}, trained_networks];
continueFromTT=sprintf('Training may be continued from a previous checkpoint.\nThis may lead to faster and or better Training\nPick from which network to train or chosse None');
testFromTT='Select Network to perform test from';
hContinueText=uicontrol('Style', 'Text', 'String', 'Continue Training from', 'Position', [25 190 120 25], 'Tooltipstring',continueFromTT);
hTestFromText=uicontrol('Style', 'Text', 'String', 'Test network', 'Position', [25 190 120 25], 'Tooltipstring',testFromTT);
hContinueDD=uicontrol('Style', 'popup', 'String',trained_networks, 'Position', ...
                [155 190 160 25], 'Tooltipstring', continueFromTT, 'Callback', @selectNetwork);

saveAsTT=sprintf('Name of the newly trained network\nWhen picking a  name present in the continue training list, that one will be overwritten');
hSaveAsText=uicontrol('Style', 'Text', 'String', 'Save As', 'Position', [320 190 60 25], 'Tooltipstring', saveAsTT);
hSaveAsEdit=uicontrol('Style', 'Edit', 'Position', [380 190 80 25], 'Tooltipstring', saveAsTT, 'Callback', @checkSaveName);

ratioTT=sprintf(['Which fraction of images should be used for training, validation and test.\n'...
                'The numbers have to add up to 1. So we copute test from your other inputs.\n' ...
                'Training: Images on which the network will be trained on\n' ...
                'Validation: During training the networks performance will be regularly checked against this dataset and the best performing network will be saved' ...
                'Test: This dataset can be used later for running a test to see how well it performs on unrelated images']);
hRatiosText=uicontrol('Style', 'Text', 'String', 'Fraction of images used for:', 'Position', [25 160 100 25], 'Tooltipstring', ratioTT);
hRatiosTr=uicontrol('Style', 'Text', 'String', 'Training', 'Position', [125 160 50 25], 'Tooltipstring', ratioTT);
hRatiosTrE=uicontrol('Style', 'Edit', 'String', num2str(defaults.train_val_test_ratios(1)), 'Position', [175 160 35 25], 'Tooltipstring', ratioTT, 'Callback', @ratioChange);
hRatiosV=uicontrol('Style', 'Text', 'String', 'Validation', 'Position', [210 160 50 25], 'Tooltipstring', ratioTT);
hRatiosVE=uicontrol('Style', 'Edit', 'String', num2str(defaults.train_val_test_ratios(2)), 'Position', [260 160 35 25], 'Tooltipstring', ratioTT, 'Callback', @ratioChange);
hRatiosTe=uicontrol('Style', 'Text', 'String', 'Test', 'Position', [295 160 40 25], 'Tooltipstring', ratioTT);
hRatiosTeE=uicontrol('Style', 'Edit', 'String', num2str(defaults.train_val_test_ratios(3)), 'Position', [335 160 45 25], 'Tooltipstring', ratioTT, 'Enable', 'off');


if defaults.allowNonSquareImages
    sizeEnable='on';
else
    sizeEnable='off';
end
hPreparedImageSizeTT=sprintf(['Image will be downscaled to this size. Needs to be a multiple of 32\n', ...
                    'If image is a rectangle but size is a square the largest possible middle square will be cropped', ...
                    'Please refer to the handbook for more detailed information']);
hPrepImageSizeText=uicontrol('Style', 'Text', 'String', 'Image Size', 'Tooltipstring', hPreparedImageSizeTT, ...
                        'Position', [25 120 100 25]);
hPrepImageEdit1=uicontrol('Style', 'Edit', 'String', num2str(defaults.imageSize(1)), 'Tooltipstring', hPreparedImageSizeTT, ...
                    'Position', [125 125 50 25], 'Callback', @changeImageSize);
hPrepImageSizeX=uicontrol('Style', 'Text', 'String', 'x', 'Tooltipstring', hPreparedImageSizeTT, 'Position', [175 120 15 25]);
hPrepImageEdit2=uicontrol('Style', 'Edit', 'String', num2str(defaults.imageSize(2)), 'Tooltipstring', hPreparedImageSizeTT, ...
                    'Position', [190 125 50 25], 'Callback', @changeImageSize, 'Enable', sizeEnable);

hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [220 70 180 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');

hStart=uicontrol('Style', 'pushbutton', 'String', 'Train', 'Tooltipstring', 'Start Training', 'Position', [300 30 90 30], 'Callback', @start);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [430 30 90 30], 'Callback', @close);

visOnFolder=[hFolderButton,hFeatPopup,hFeatText,hEpochsText,hEpochsEdit,hBatchText, hBatchEdit,...
            hLearnRateEdit, hLearnRateText,hContinueDD,hContinueText,hSaveAsText,hSaveAsEdit];
visOnPrepFromConf=[hFileTxt,hFiles,hAdd,hRemove, hOutputFolderButton, ...
            hRatiosText,hRatiosTr,hRatiosTrE,hRatiosVE,hRatiosV,hRatiosTe,hRatiosTeE,...
            hPrepImageSizeText,hPrepImageEdit1,hPrepImageSizeX,hPrepImageEdit2];
visOnPrepare=[hOutputFolderButton, hInputFolderButton, ...
            hRatiosText,hRatiosTr,hRatiosTrE,hRatiosVE,hRatiosV,hRatiosTe,hRatiosTeE,...
            hPrepImageSizeText,hPrepImageEdit1,hPrepImageSizeX,hPrepImageEdit2];
visOnTest=[hFolderButton,hFeatPopup,hFeatText,hContinueDD,hTestFromText,hResultsFolderButton];
visOnDatTest=[hDatTestButton,hContinueDD,hTestFromText,hResultsFolderButton, ...
            hPrepImageSizeText,hPrepImageEdit1,hPrepImageSizeX,hPrepImageEdit2];
visOnDat=[hFileTxt,hFiles,hAdd,hRemove,hEpochsText,hEpochsEdit, ...
       hBatchText, hBatchEdit, hLearnRateEdit, hLearnRateText,hContinueDD,hContinueText, ...
       hSaveAsText,hSaveAsEdit,hRatiosText,hRatiosTr,hRatiosTrE,hRatiosVE,hRatiosV,...
       hRatiosTe,hRatiosTeE, hPrepImageSizeText,hPrepImageEdit1,hPrepImageSizeX,hPrepImageEdit2];

allHandles=unique([visOnFolder,visOnPrepare,visOnTest,visOnDat,visOnDatTest, visOnPrepFromConf]);
set(allHandles,'Visible', 'off');
set(visOnFolder,'Visible', 'on');

waitfor(mainFigure);

    function start(~,~)
        if ~checkUserInputs()
            return;
        end
        switch bg.SelectedObject
            %Differentiate type of inputs to pull correct values from UI
            case {hPrepareDatasetFromConfig, hTrainFromConfig} 
                dataset=hFiles.String;
                feature='foreground';
            case hTestFromConfig
                dataset=hDatTestButton.String;
                feature='foreground';
            case hPrepareDataset
                dataset=hInputFolderButton.String;
            case {hTrainFromDataset, hTestFromDataset}
                dataset=hFolderButton.String;
                feature=getSelectedStringFromPopup(hFeatPopup);
        end
        switch bg.SelectedObject
            % Differentiate training, testing and preparation
            case hPrepareDatasetFromConfig
                hProgress.String='Preparing Dataset...';
                drawnow();
                if CopyAndPrepareTrainingImagesFromConfigs(dataset,hOutputFolderButton.String,feature,defaults)   
                    hProgress.String='Finished preparing Dataset!';
                else
                    hProgress.String='Dataset preparation failed!';
                end
            case hPrepareDataset
                hProgress.String='Preparing Dataset...';
                drawnow();
                if CopyAndPrepareTrainingImagesFromFolder(dataset,hOutputFolderButton.String,defaults)
                    hProgress.String='Finished preparing Dataset!';
                else
                    hProgress.String='Dataset preparation failed!';
                end
            case {hTrainFromConfig, hTrainFromDataset}
                continue_from=getSelectedStringFromPopup(hContinueDD);
                train(dataset,feature,continue_from,hProgress,defaults,hSaveAsEdit.String);
                trained_networks=getTrainedNetworks();
                trained_networks=[{'None'}, trained_networks];
                hContinueDD.String=trained_networks;
            case {hTestFromDataset, hTestFromConfig}
                continue_from=getSelectedStringFromPopup(hContinueDD);
                outfolder=hResultsFolderButton.String;
                if isequal(bg.SelectedObject,hTestFromConfig)
                    feature='foreground';
                    dataset=hDatTestButton.String;
                end
                save_Predictions=1; %Whether or not predicted demarcations should be saved
                %To do: ask user about that!
                test(dataset,feature,continue_from,outfolder,save_Predictions,hProgress);
        end
        figure(mainFigure);   
    end
    function bool=isContainedIn(A,B)
        %Checks if object A isequal to any object in cell array B
        bool=false;
        for b=1:numel(B)
            if isequal(A, B{b})
                bool=true;
                return;
            end
        end
    end
    function selectNetwork(hOb, ~)
        % On Training, if a network is selected to continue from
        % imageSize has to be same then for that network
        switch bg.SelectedObject
            case {hTrainFromConfig, hTrainFromDataset, hTestFromConfig}
                if hOb.Value==1
                    %No network selected
                    enableImageEdits()
                    return;
                end
                imageSize=getNetworkImageSize(getSelectedStringFromPopup(hOb));
                defaults.imageSize=imageSize;
                hPrepImageEdit1.String=num2str(imageSize(1));
                hPrepImageEdit2.String=num2str(imageSize(2));
                set(hPrepImageEdit1, 'enable', 'off');
                set(hPrepImageEdit2, 'enable', 'off');
                
            otherwise
                return;                
        end
    end
    function enableImageEdits()
        set(hPrepImageEdit1, 'enable', 'on');
        if defaults.allowNonSquareImages
            set(hPrepImageEdit2, 'enable', 'off');
        end
    end
    function bool=checkUserInputs()
        %Returns true if everything is fine
        bool=true;
        if isContainedIn(bg.SelectedObject, {hPrepareDataset,hPrepareDatasetFromConfig}) ...
                    && ~isfolder(hOutputFolderButton.String)
            msgbox('The path to output folder is not valid');
            bool=false;
        end
        
        if isContainedIn(bg.SelectedObject,{hPrepareDatasetFromConfig,hTrainFromConfig}) ...
                    && isnan(defaults.train_val_test_ratios(3))
            msgbox('The train/val/test ratios do not add up to 1');
            bool=false;
        end
        if isContainedIn(bg.SelectedObject,{hTrainFromDataset,hTestFromDataset}) 
            if ~isfolder(hFolderButton.String)
                msgbox('The specified folder does not exist');
                bool=false;
            elseif ~strcmp(getSelectedStringFromPopup(hContinueDD), 'None')
                imSizeNetwork=getNetworkImageSize(getSelectedStringFromPopup(hContinueDD));
                imSizeDataset=getImageSizeFromInfoFile(fullfile(hFolderButton.String, 'dataset.info'));
                
                if ~isequal(imSizeNetwork, imSizeDataset)
                    bool=false;
                    if isequal(bg.SelectedObject,hTrainFromDataset)
                        name='Training';
                    else
                        name='Testing';
                    end
                    msgbox(sprintf(['The selected network requires a different image ' ...
                        'size (%ix%i) than the one in the selected dataset (%ix%i).\n' ...
                        '%s can therefore not be performed with this combination of dataset and network'], ...
                        imSizeNetwork(1), imSizeNetwork(2), imSizeDataset(1), imSizeDataset(2),name));
                end
            end 
        end
        if isContainedIn(bg.SelectedObject,{hTestFromConfig,hTestFromDataset}) 
            if strcmp(getSelectedStringFromPopup(hContinueDD), 'None')
                msgbox('You need to select a network to run the test from');
                bool=false;
            end
            if ~isfolder(hResultsFolderButton.String)
                msgbox('The path to results folder is not valid');
                bool=false;
            end
        end
        if isContainedIn(bg.SelectedObject, {hTrainFromConfig,hTrainFromDataset})
            name=hSaveAsEdit.String;
            if isempty(name)
                msgbox('Please select a name to save network as');
                bool=false;
            elseif strcmp(name, 'None')
                msgbox('Save network name may not be "None"')
                bool=false;
            end
        end
    end
    function changeImageSize(hOb, ~)
        val=str2double(hOb.String);
        if isnan(val)
            %Illegal Input
            switch hOb
                case hPrepImageEdit1
                    hOb.String=num2str(defaults.imageSize(1));
                case hPrepImageEdit2
                    hOb.String=num2str(defaults.imageSize(2));    
            end
            return
        end
        % Only multiples of 32 are allowed. If it is not, pick the nearest valid value
        if mod(val, 32)~=0
            val=32*round(val/32);
            hOb.String=num2str(val);
        end
        switch hOb
            case hPrepImageEdit1
                defaults.imageSize(1)=val;
                if ~defaults.allowNonSquareImages
                    hPrepImageEdit2.String=num2str(val);
                    defaults.imageSize(2)=val;
                end
            case hPrepImageEdit2
                defaults.imageSize(2)=val;
        end
    end
    function ratioChange(hOb,~)
        switch hOb
            case hRatiosTrE
                nr=1;
            case hRatiosVE
                nr=2;
        end
        defaults.train_val_test_ratios(nr)=shouldBeNumber(defaults.train_val_test_ratios(nr),hOb,1,[0,1]);
        if defaults.train_val_test_ratios(1)+defaults.train_val_test_ratios(2)>1
            defaults.train_val_test_ratios(3)=NaN;
            hRatiosTeE.String='Error';
            return
        end
        defaults.train_val_test_ratios(3)=1-(defaults.train_val_test_ratios(1)+defaults.train_val_test_ratios(2));
        hRatiosTeE.String=num2str(defaults.train_val_test_ratios(3));
    end
    function updateEpochs(hOb,~)
        defaults.epochs=shouldBeNumber(defaults.epochs,hOb,0,[1,inf]);
    end
    function updateLearnRate(hOb,~)
        defaults.learnRate=shouldBeNumber(defaults.learnRate,hOb,1,[0,1]);
    end
    function updateBatchSize(hOb,~)
        defaults.batchSize=shouldBeNumber(defaults.batchSize,hOb,0,[1,inf]);
    end

    function changeInterface(~,event)
        set(allHandles,'Visible', 'off');
        switch event.NewValue
            case hTrainFromDataset
                set(visOnFolder,'Visible', 'on');
                set(hContinueDD, 'Tooltipstring', continueFromTT);
                hStart.String='Train';
            case hPrepareDataset
                set(visOnPrepare,'Visible','on');
                hStart.String='Prepare';
            case hPrepareDatasetFromConfig
                set(visOnPrepFromConf, 'Visible', 'on');
                hStart.String='Prepare';
            case hTestFromDataset
                set(visOnTest,'Visible', 'on');
                set(hContinueDD, 'Tooltipstring', testFromTT);
                hStart.String='Test';
            case hTrainFromConfig
                set(visOnDat,'Visible', 'on');
                hStart.String='Train';
            case hTestFromConfig
                set(visOnDatTest, 'Visible', 'on');
                set(hContinueDD, 'Tooltipstring', testFromTT);
                hStart.String='Test';
        end
    end

    function checkSaveName(hOb, ~)
        while startsWith(hOb.String, '.')
            hOb.String=hOb.String(2:end);
        end
        hOb.String=strrep(hOb.String, '/', '_');
        hOb.String=strrep(hOb.String, '\', '_');
    end
    function add(~,~)
        global lastfolder
        if isempty(lastfolder)
            lastfolder=cd;
        end
        [infoFile, folder] = uigetfile('*.dat', 'Choose project file', lastfolder);
        if ~ischar(folder)
            return;
        end
        lastfolder=folder;
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

    function close(~,~)
        delete(gcf);
    end
    function openFolder(hOb)
        global lastfolder
        if isempty(lastfolder)
            lastfolder=cd;
        end
        folder = uigetdir(lastfolder);
        if ~ischar(folder)
            return;
        end
        lastfolder=folder;

        if isequal(hOb,hFolderButton)
            %Get features in dataset
            feat=dir(folder);
            feat={feat.name};
            feat=feat(~startsWith(feat,'.'));
            feat=feat(isfolder(fullfile(folder,feat)));
            if isempty(feat)
                %No features found
                hOb.String='Error. No features found in this dataset';
                hFeatPopup.Enable='off';
                return;
            end
            hFeatPopup.Enable='on';
            hFeatPopup.String=feat;
        end
        
        if isContainedIn(bg.SelectedObject, {hPrepareDataset, hPrepareDatasetFromConfig}) ...
                    && isequal(hOb, hOutputFolderButton)
            if ~isfile(fullfile(folder, 'dataset.info')) && isfile(fullfile(fileparts(folder), 'dataset.info')) ...
                        && isfile(fullfile(folder, 'configs.csv'))
                %User should have selected one folderlevel higher, correct this
                folder=fileparts(folder);
            end
            if isfile(fullfile(folder, 'dataset.info'))
                imageSize=getImageSizeFromInfoFile(fullfile(folder, 'dataset.info'));
                defaults.imageSize=imageSize;
                hPrepImageEdit1.String=num2str(imageSize(1));
                hPrepImageEdit2.String=num2str(imageSize(2));
                set(hPrepImageEdit1, 'enable', 'off');
                set(hPrepImageEdit2, 'enable', 'off');
            else
                enableImageEdits()
            end
                
        end
        % Updates the interface.
        set(hOb, 'String', folder); 

    end
    function openDatFile(hOb)
        global lastfolder
        if isempty(lastfolder)
            lastfolder=cd;
        end
        [infoFile, folder] = uigetfile('*.dat', 'Choose project file', lastfolder);
        if ~ischar(folder)
            return;
        end
        lastfolder=folder;
        newdatFile=fullfile(folder,infoFile);
        set(hOb, 'String', newdatFile); 
    end

end

