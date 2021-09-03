function train(imDataset,feature,continue_from,hProgress,settings,saveName)

delTmp=0;
if iscell(imDataset)
    %Cell array of datFiles
    %->Convert and then train
    set(hProgress, 'String', 'Preparing dataset for training');
    drawnow();
    path='tmp';
    prepareFolderForTrainDataset(path,feature,settings.backgroundColor);

    delTmp=1;
    for c=1:numel(imDataset)
        [pa, fil, ext]=fileparts(imDataset{c});
        copyAndPrepareFromConfig(pa, [fil ext], fullfile(path,feature),NaN,settings);
    end
elseif isfolder(imDataset)
    %Folder with prepared images
    if isfolder(fullfile(imDataset,feature))
        path=imDataset;
    else
        [folder, subfolder]=fileparts(imDataset);
        if strcmp(subfolder,feature)
            path=folder;
        else
            hProgress.String='Selected folder does not contain dataset for that feature. Aborted.';
            return
        end
    end
else
    %not recognized
    set(hProgress,'String', 'Unexpected format of dataset. Aborted');
    return;
end
savePath='tmp_checkpoints';
safeMkdir(savePath);
learnRate=num2str(settings.learnRate);     %0.0001 works well
batchSize=num2str(settings.batchSize);    %Should be 1 for GPU, higher for CPU training
epochs=num2str(settings.epochs);      %400 for extensive training (GPU highly recommended); at least 20 for quick training
%Assemble python arguments
if strcmp(continue_from,'None')
    continue_training='0';
else
    continue_training='1';
end
args=[... 
        ' --dataset ', feature, ' --dataset_path ', convPath(path), ...
        ' --batch_size ', batchSize,  ' --learn_rate ', learnRate, ' --num_epochs ', epochs ...
        ' --continue_training ', continue_training, ' --continue_from ', continue_from ' --save_path ', convPath(savePath) ... 
        ' --h_flip ', '1', ' --v_flip ', '1', ' --brightness ', '0.5', ' --checkpoint_step ', '10000' ...
        ' --save_best ', '1',' --num_val_images ', '-1',' --darea_call ', '1'];
set(hProgress, 'String', 'Performing Training');
drawnow();
[~,pyExe]=pyversion; 
cmd=[pyExe ' python/SemanticSegmentationSuite/train.py' args];
retVal=system(cmd);
if retVal~=0
    set(hProgress, 'String', 'Python ended with error, aborting training');
    fprintf('Python ended with error, aborting training\n')
    fprintf('The python command executed was:\n%s',cmd')
else
    set(hProgress, 'String', 'Training completed successfully' );
    drawnow();
    if isfile(fullfile(savePath, [feature '.ckpt.index']))
        ckfiles=dir(savePath);
        ckfiles={ckfiles.name};
        ckfiles=ckfiles(contains(ckfiles,'.ckpt'));
        ckfiles=ckfiles(contains(ckfiles,feature));
        outfiles=cellfun(@(x) strrep(x, feature, saveName),ckfiles, 'UniformOutput', false);
        for f=1:numel(ckfiles)
            copyfile(fullfile(savePath,ckfiles{f}),fullfile('deepLearning/checkpoints', outfiles{f}));
        end
    end
end
rmdir('tmp_checkpoints', 's');
if delTmp
    rmdir('tmp','s');
end
%Reset pythons working directory to DareIt main folder (gets changed when making predictions)
py.os.chdir(pwd);

end