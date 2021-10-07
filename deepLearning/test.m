function test(imDataset,feature,network,outfolder,savePredictions,hProgress,settings)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
delTmp=1;

if isfile(imDataset)
    if nargin < 7
        settings=readDefaults(imDataset);
    end
    settings.imageSize=getNetworkImageSize(network);
    crop_height=settings.imageSize(1);
    crop_width=settings.imageSize(2);
    %datFile
    %->Convert and then test
    set(hProgress, 'String', 'Preparing dataset for test');
    drawnow();
    path='tmp';
    settings.train_val_test_ratios=[0,0,1]; %All images used for testing
    prepareFolderForTrainDataset(path,feature,settings.backgroundColor);
%     class_fid=fopen(fullfile(path,feature,'class_dict.csv'),'a');
%     fprintf(class_fid, '\nBackground,%i,%i,%i', settings.foregroundColors(1), ...
%             settings.foregroundColors(1),settings.foregroundColors(1));
%     fclose(class_fid);
    routes=readConfig(imDataset);
    fid=fopen('tmp/info.csv','w');
    fprintf(fid,'OriginalRoute;Name;ImageSize;Type');

    [pa, fil, ext]=fileparts(imDataset);

    copyAndPrepareFromConfig(pa, [fil ext], fullfile(path,feature),fid,settings);
    fclose(fid);
    imSizes=getImSizesFromCSV('tmp/info.csv');

elseif isfolder(imDataset)
    %Folder with prepared images
    imageSize=getNetworkImageSize(network);
    crop_height=imageSize(1);
    crop_width=imageSize(2);
    if isfolder(fullfile(imDataset,feature))
        path=imDataset;
    else
        [folder, subfolder]=fileparts(imDataset);
        if strcmp(subfolder,feature) && isfolder(imDataset)
            path=folder;
        else
            hProgress.String='Selected folder does not contain dataset for that feature. Aborted.';
            return
        end
    end
    %% Define routes here!!
    info=tdfread(fullfile(path,feature,'configs.csv'),';');
    configs=cellstr(info.Name);
    imSizes={};
    routes={};
    for c=1:numel(configs)
        info=tdfread(fullfile(path,feature,[configs{c}(1:end-4) '.csv']),';');
        types=cellstr(info.Type);
        oroutes=cellstr(info.OriginalRoute);
        sizes=cellstr(info.ImageSize);
        sizes=sizes(strcmp(types,'test'));
        sizes=cellfun(@eval,sizes, 'UniformOutput', false);
        oroutes=oroutes(strcmp(types,'test'));
        routes=[routes;oroutes];
        imSizes=[imSizes;sizes];
    end
    %ToDo: Define crop_height and crop_width
else
    %not recognized
    set(hProgress,'String', 'Unexpected format of dataset. Aborted');
    return;
end
savePath='tmpResults';

safeMkdir(savePath);

args=[... 
        ' --dataset ', convPath(fullfile(path,feature)), ...
        ' --checkpoint_path ', convPath(['deepLearning/checkpoints/' network '.ckpt']), ...
        ' --output_path ', convPath(savePath), ' --darea_call ', '1', ...
        ' --crop_height ', num2str(crop_height), ' --crop_width ', num2str(crop_width)];
set(hProgress, 'String', 'Performing Test');
drawnow();
[~,pyExe]=pyversion; 
cmd=[pyExe ' python/SemanticSegmentationSuite/test.py' args];
retVal=system(cmd);
if retVal~=0
    %Python failed
    set(hProgress, 'String', 'Python ended with error, aborting prediction');
    fprintf('Python ended with error, aborting prediction\n')
    fprintf('The python command executed was:\n%s',cmd')
    drawnow();
    return;
end
%Test successful
set(hProgress, 'String', 'Saving results.');
drawnow();
    

safeMkdir(outfolder)
outfolder=fullfile(outfolder,feature);
safeMkdir(outfolder);
copyfile('tmpResults/test.csv', fullfile(outfolder,'test_results.csv'));

if savePredictions
    routes=cellfun(@(x) [x '.tif'],routes, 'UniformOutput', false);
    routes=cellfun(@(x) fullfile(outfolder,x),routes, 'UniformOutput',false);
    subfolders=unique(cellfun(@(x)fileparts(x), routes, 'UniformOutput', false));
    for i=1:numel(subfolders)
        safeMkdir(subfolders{i});
    end

    convertPredictionsToMod('tmpResults/', routes, imSizes, 1);
end

rmdir('tmpResults', 's');
if delTmp
    rmdir('tmp','s');
end
%Reset pythons working directory to DareIt main folder (gets changed when making predictions)
py.os.chdir(pwd);
set(hProgress, 'String', 'Testing finished!');

    function sizes=getImSizesFromCSV(csv)
        iminfo=tdfread(csv,';');
        sizes=cellstr(iminfo.ImageSize);
        sizes=cellfun(@(x) eval(x),sizes,'UniformOutput',false);
    end

end

