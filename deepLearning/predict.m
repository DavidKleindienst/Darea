function predict(config, network,hProgress, overwrite)
%% Carries out all preparations for prediction and calls python function to do predictions
%First Converts all images and saves in tmp folder
%Then assembles all pyargs 
%Then calls python predict script from Semantic Segmentation Suite (https://github.com/GeorgeSeif/Semantic-Segmentation-Suite)
%Then converts back the prediction outputs and saves them in original folder
%Then deletes all tmp files

if nargin<4
    overwrite=NaN;
end
imageSize=getNetworkImageSize(network);
delTmp=true;    %Whether to delete temporary folder. (Only disable for bugfixing)
%Prepare temporary Folders
tmpFolder='tmp/';
imFolder=fullfile(tmpFolder,'images/');
predFolder=fullfile(tmpFolder,'predictions/');
safeMkdir(tmpFolder);
safeMkdir(imFolder);
safeMkdir(predFolder);

%Get input image List
set(hProgress, 'String', 'Reading config file...');
drawnow();
path=fileparts(config);
[routes, ~, selAngles]=readConfig(config);
files=cellfun(@(x) fullfile(path,x),routes, 'UniformOutput', false);
modfilesExist=cellfun(@(x) isfile([x '_mod.tif']) | isfile([x '_mod_1.tif']),files);
if isnan(overwrite) && any(modfilesExist)
    answer = questdlg('At least one of the _mod files already exists. Do you want to overwrite them?', ...
        'Overwrite images?', ...
        'yes','no','no');
    if strcmp(answer,'yes')
        overwrite=true;
    else
        overwrite=false;
    end
elseif isnan(overwrite)
    overwrite=true;
end
if ~overwrite
    files=files(~modfilesExist);
end

if isempty(files)
    fprintf('No Images to predict on. Aborting...');
    set(hProgress,'String','No Images to predict on. Aborted.');
    return
end

%Convert Images
set(hProgress, 'String', 'Preparing Images...');
drawnow();
imSizes=prepareForPrediction(files, imFolder,selAngles, imageSize);

%Do Prediction with python
set(hProgress, 'String', 'Predicting demarcations...');
drawnow();
args=[' --image "', convPath(imFolder), ...
        '" --outpath "', convPath(predFolder), ...
        '" --file_suffix ', '.tif', ' --dataset "', convPath('deepLearning/checkpoints/') ...
        '" --checkpoint_path "', convPath(['deepLearning/checkpoints/' network '.ckpt']), ...
        '" --darea_call ', '1'];
[~,pyExe]=pyversion;
cmd=[pyExe ' python/SemanticSegmentationSuite/predict.py' args];
retVal=system(cmd);
if retVal~=0
    set(hProgress, 'String', 'Python ended with error, aborting prediction');
    fprintf('Python ended with error, aborting prediction\n')
    fprintf('The python command executed was:\n%s',cmd')
    pause(0.02);
    if delTmp
        rmdir(tmpFolder,'s');
    end
    return
end
%This has issues with double instance of on Mac
%conda install nomkl 
%abolishes the error, but may decrease performance significantly.
%No sure how to best improve this...

%Backconvert Images
set(hProgress, 'String', 'Converting predictions...');
drawnow();
convertPredictionsToMod(predFolder, files, imSizes, overwrite);

if delTmp
    rmdir(tmpFolder,'s');
end
set(hProgress, 'String', 'Finished Prediction');
fprintf('Finished Prediction\n');
%Reset pythons working directory to DareIt main folder (gets changed when making predictions)
py.os.chdir(pwd);
end