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
positionFigure =  [25, 50, 650, 545];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Train Demarcation Prediction'); 
set(mainFigure, 'CloseRequestFcn', @close);

bg=uibuttongroup('SelectionChangedFcn', @changeInterface);
hFolderSelect=uicontrol(bg,'Style','Radiobutton', 'Position', [100 480 350 20], ...
            'String', 'Train from folder which contains a prepared dataset');
hPrepareDataset=uicontrol(bg, 'Style', 'Radiobutton', 'Position', [100 460 350 20], ...
               'String', 'Prepare a dataset for training');
hTest=uicontrol(bg,'Style','Radiobutton', 'Position', [100 440 300 20], ...
            'String', 'Test trained network on dataset');
hTestDat=uicontrol(bg,'Style','Radiobutton', 'Position', [100 420 300 20], ...
            'String', 'Test trained network on project (not recommended)');
hFromDat=uicontrol(bg,'Style','Radiobutton', 'Position', [100 400 300 20], ...
            'String', 'Train from one or multiple projects (not recommended)');

folderTT='Select folder with prepared datasets';
hFolderTxt=uicontrol('Style', 'Text', 'String', 'Dataset folder:','HorizontalAlignment','left','Position', [25 360 100 25]);     
hFolderEdit=uicontrol('Style', 'Edit', 'String', 'Choose datset folder path', 'Tooltipstring',folderTT,...
                       'HorizontalAlignment','left','backgroundcolor','white','Position', [125 365 325 25]); 
hFolderButton = uicontrol('Style', 'pushbutton', 'String', 'Choose folder', 'Tooltipstring',folderTT,'Position', [475 365 100 25], 'Callback', @(~,~)openFolder(hFolderEdit));



inputFolderTT=sprintf('Select Input Folder');
hInputFolderTxt=uicontrol('Style', 'Text', 'String', 'Folder with analysed projects', 'Tooltipstring', inputFolderTT, 'Position', [25 360 150 25]);
hInputFolderEdit=uicontrol('Style', 'Edit', 'String', 'Choose input folder', 'Tooltipstring', inputFolderTT, 'Position', [175 365 275 25]);
hInputFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose folder', 'Tooltipstring', inputFolderTT, 'Position', [475 365 100 25], 'Callback', @(~,~)openFolder(hInputFolderEdit));

outputFolderTT=sprintf('Select Output Folder\nThe prepared dataset will be stored there\nThis should be an empty folder, or the folder where the same perepared datasets where saved to before');
hOutputFolderTxt=uicontrol('Style', 'Text', 'String', 'Prepare dataset here', 'Tooltipstring', outputFolderTT, 'Position', [25 330 150 25]);
hOutputFolderEdit=uicontrol('Style', 'Edit', 'String', 'Choose output folder', 'Tooltipstring', outputFolderTT, 'Position', [175 335 275 25]);
hOutputFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose folder', 'Tooltipstring', outputFolderTT, 'Position', [475 335 100 25], 'Callback', @(~,~)openFolder(hOutputFolderEdit));

datTestTT=sprintf('Select project File');
hDatTestTxt=uicontrol('Style', 'Text', 'String', 'Project file', 'Tooltipstring', datTestTT, 'Position', [25 360 150 25]);
hDatTestEdit=uicontrol('Style', 'Edit', 'String', 'Choose project file', 'Tooltipstring', datTestTT, 'Position', [175 365 275 25]);
hDatTestButton=uicontrol('Style', 'pushbutton', 'String', 'Choose file', 'Tooltipstring', datTestTT, 'Position', [475 365 100 25], 'Callback', @(~,~)openDatFile(hDatTestEdit));

resultFolderTT=sprintf('Select where to save results');
hResultsFolderTxt=uicontrol('Style', 'Text', 'String', 'Save results here', 'Tooltipstring', resultFolderTT, 'Position', [25 330 150 25]);
hResultsFolderEdit=uicontrol('Style', 'Edit', 'String', 'Choose results folder', 'Tooltipstring', resultFolderTT, 'Position', [175 335 275 25]);
hResultsFolderButton=uicontrol('Style', 'pushbutton', 'String', 'Choose folder', 'Tooltipstring', resultFolderTT, 'Position', [475 335 100 25], 'Callback', @(~,~)openFolder(hResultsFolderEdit));



filesTT='Select datfiles from which to train';
hFileTxt=uicontrol('Style', 'Text', 'String', 'Config Files', 'Position', [35 350 80 25], 'Tooltipstring', filesTT);
hFiles=uicontrol('Style', 'listbox', 'Position', [120 300 150 100], 'Tooltipstring', filesTT, 'Min', 0, 'Max', 3, 'Value', []);
if nargin>0
    set(hFiles, 'String', {datFile});
end
hAdd=uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [275 360 20 20], 'Callback', @add);
hRemove=uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [275 340 20 20], 'Callback', @remove);



featTT='Name the feature you would like to predict (e.g. PSD)';
hFeatText=uicontrol('Style', 'Text', 'String', 'Feature', 'Position', [25 260 60 25], 'Tooltipstring', featTT);
hFeatEdit=uicontrol('Style', 'Edit', 'Position', [90 260 130 25], 'Tooltipstring', featTT);
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
hContinueDD=uicontrol('Style', 'popup', 'String',trained_networks, 'Position', [155 190 160 25], 'Tooltipstring', continueFromTT);

saveAsTT=sprintf('Name of the newly trained network\nWhen picking a  name present in the continue training list, that one will be overwritten');
hSaveAsText=uicontrol('Style', 'Text', 'String', 'Save As', 'Position', [320 190 60 25], 'Tooltipstring', saveAsTT);
hSaveAsEdit=uicontrol('Style', 'Edit', 'Position', [380 190 80 25], 'Tooltipstring', saveAsTT);

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


hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [220 100 180 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');

hStart=uicontrol('Style', 'pushbutton', 'String', 'Train', 'Tooltipstring', 'Start Training', 'Position', [300 60 90 30], 'Callback', @start);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [430 60 90 30], 'Callback', @close);

visOnFolder=[hFolderTxt,hFolderEdit,hFolderButton,hFeatPopup,hFeatText,hEpochsText,hEpochsEdit,hBatchText, hBatchEdit, hLearnRateEdit, ...
            hLearnRateText,hContinueDD,hContinueText,hSaveAsText,hSaveAsEdit];
visOnPrepare=[hInputFolderTxt, hInputFolderEdit,hInputFolderButton,hOutputFolderTxt, hOutputFolderEdit,hOutputFolderButton, ...
            hRatiosText,hRatiosTr,hRatiosTrE,hRatiosVE,hRatiosV,hRatiosTe,hRatiosTeE];
visOnTest=[hFolderTxt,hFolderEdit,hFolderButton,hFeatPopup,hFeatText,hContinueDD,hTestFromText,hResultsFolderTxt,hResultsFolderEdit,hResultsFolderButton];
visOnDatTest=[hDatTestTxt,hDatTestEdit, hDatTestButton,hContinueDD,hTestFromText,hResultsFolderTxt,hResultsFolderEdit,hResultsFolderButton];
visOnDat=[hFileTxt,hFiles,hAdd,hRemove,hFeatEdit,hFeatText,hEpochsText,hEpochsEdit,hBatchText, hBatchEdit, hLearnRateEdit, ...
       hLearnRateText,hContinueDD,hContinueText,hSaveAsText,hSaveAsEdit,hRatiosText,hRatiosTr,hRatiosTrE,hRatiosVE,hRatiosV,hRatiosTe,hRatiosTeE];

allHandles=unique([visOnFolder,visOnPrepare,visOnTest,visOnDat,visOnDatTest]);
set(allHandles,'Visible', 'off');
set(visOnFolder,'Visible', 'on');

waitfor(mainFigure);

    function start(~,~)
        if isequal(bg.SelectedObject,hPrepareDataset)
            if ~isfolder(hInputFolderEdit.String)
                msgbox('The specified input folder does not exist');
                return;
            elseif ~isfolder(fileparts(hOutputFolderEdit.String))
                msgbox('The path to output folder is not valid');
                return;
            elseif isnan(defaults.train_val_test_ratios(3))
                msgbox('The ratios do not add up to 1');
                return;
            end
            hProgress.String='Preparing Dataset...';
            drawnow();
            CopyAndPrepareTrainingImages(hInputFolderEdit.String,hOutputFolderEdit.String,0);     
            hProgress.String='Finished preparing Dataset!';
        else
            % Training
            if isequal(bg.SelectedObject,hFolderSelect) || isequal(bg.SelectedObject,hTest)
                if ~isfolder(hFolderEdit.String)
                    msgbox('The specified folder does not exist');
                    return;
                end
                dataset=hFolderEdit.String;
                feature=getSelectedStringFromPopup(hFeatPopup);
            else
                dataset=hFiles.String;
                feature=hFeatEdit.String;
                if isnan(defaults.train_val_test_ratios(3))
                    msgbox('The ratios do not add up to 1');
                    return;
                end
            end
            
            if ~feature
                hProgress.String='You have to specify a name for the feature';
                return
            end
            continue_from=getSelectedStringFromPopup(hContinueDD);
            if isequal(bg.SelectedObject,hTest) || isequal(bg.SelectedObject,hTestDat)
                if strcmp(continue_from, 'None')
                    msgbox('You need to select a network to run the test from');
                    return;
                end
                outfolder=hResultsFolderEdit.String;
                if isequal(bg.SelectedObject,hTestDat)
                    feature='foreground';
                    dataset=hDatTestEdit.String;
                end
                save_Predictions=1; %Whether or not predicted demarcations should be saved
                %To do: askd user about that!
                test(dataset,feature,continue_from,outfolder,save_Predictions,hProgress);
            else
                train(dataset,feature,continue_from,hProgress,defaults,hSaveAsEdit.String); %1 means continue_training, replace with user selection
            end
        end
        figure(mainFigure);
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
            case hFolderSelect
                set(visOnFolder,'Visible', 'on');
                set(hContinueDD, 'Tooltipstring', continueFromTT);
            case hPrepareDataset
                set(visOnPrepare,'Visible','on');
            case hTest
                set(visOnTest,'Visible', 'on');
                set(hContinueDD, 'Tooltipstring', testFromTT);
            case hFromDat
                set(visOnDat,'Visible', 'on');
            case hTestDat
                set(visOnDatTest, 'Visible', 'on');
                set(hContinueDD, 'Tooltipstring', testFromTT);
        end
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

function close(~,~)
    delete(gcf);
end
function openFolder(hOb)

    folder = uigetdir();

    if isequal(hOb,hFolderEdit)
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
    % Updates the interface.
    set(hOb, 'String', folder); 

end
function openDatFile(hOb)
    [infoFile, folder] = uigetfile('*.dat');
    newdatFile=fullfile(folder,infoFile);

    set(hOb, 'String', newdatFile); 

end

end

