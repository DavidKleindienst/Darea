function prepareFolderForTrainDataset(folder,feature,backgroundColor)
%PREPAREFOLDERFORTRAINDATASET Summary of this function goes here
%   Detailed explanation goes here
safeMkdir(folder);
targetfolder=fullfile(folder,feature);
safeMkdir(targetfolder);
learning_folders={'train','train_labels','val','val_labels','test','test_labels'};
for t=1:numel(learning_folders)
    safeMkdir(fullfile(targetfolder,learning_folders{t}));
end
if  ~isfile(fullfile(targetfolder,'class_dict.csv'))
    fid=fopen(fullfile(targetfolder,'class_dict.csv'), 'w');
    fprintf(fid,'name,r,g,b\nBackground,%i,%i,%i', backgroundColor,backgroundColor,backgroundColor);
    fclose(fid);
end
end

