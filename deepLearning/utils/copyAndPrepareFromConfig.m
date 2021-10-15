function nrImages=copyAndPrepareFromConfig(path,config,targetfolder,fid,settings, offset)
%COPYANDPREPAREFROMDAT Summary of this function goes here
%   Detailed explanation goes here
%   When wanting to add images to a folder, set offset to the last previous
%   image number

if nargin<4
    fid=NaN;
end
if nargin<5
    settings=readDefaults(fullfile(path,config));
end
if nargin<6
    offset=0;
end
if ~isfolder(targetfolder) || ~isfile(fullfile(targetfolder,'class_dict.csv'))
    prepareFolderForTrainDataset(targetfolder,'.',settings.backgroundColor)
end
routes=readConfig(fullfile(path,config));
%If its for particle prediction, config is "feature/config.dat"
%Move feature to path so the images are properly found
%and replace the / with __ so converted images can be saved in correct
%folder
path=fullfile(path,fileparts(config));
config=replaceSlash(config);

ratios=settings.train_val_test_ratios; 
targetsize=settings.imageSize;

%Find all duplicates of images
duplicates=routes(endsWith(routes,'_dupl'));
%Get routes of the original images of these duplicates
duplicated_images=unique(cellfun(@(x) erase(x, '_dupl'), duplicates, 'UniformOutput', false));

classes=tdfread(fullfile(targetfolder,'class_dict.csv'),',');
class_names=cellstr(classes.name);
class_colors=classes.r; %Class_dict has rgb values, but we always make them identical (i.e. grayscale)
f=fopen(fullfile(targetfolder,'class_dict.csv'),'a');
if settings.splitDemarcationsByGroup
    [groupnames, groupImages]=readGroups(fullfile(path,config));
    %Reduce groups only to the one grouping which will be used for distinguishing features
    groupImages=groupImages(:,strcmp(groupnames,settings.featureName));
    %groupImages gives the group for each route
    groups=unique(groupImages);
    if any(strcmp(groups,'Background'))
        error('Groups for the demarcation feature must not be called Background');
    end
    nrGroups=numel(groups);
    foregroundColor=zeros(1,nrGroups);
    for g=1:nrGroups
        if ismember(groups{g},class_names)
            %feature is in file already, choose same foregroundcolor
            foregroundColor(g)=class_colors(strcmp(class_names,groups{g}));
        else
            %Not in file already, choose the next foregroundcolor and write to file
            foregroundColor(g)=settings.foregroundColors(numel(class_colors)+g-1);
            fprintf(f,'\n%s,%i,%i,%i', groups{g}, foregroundColor(g),foregroundColor(g),foregroundColor(g));
        end
    end
    
    foregroundColor=settings.foregroundColors(1:nrGroups);
else
    feature=settings.featureName;
    if strcmp(feature, 'Background')
        error('Your feature must not be called Background');
    end
    groupIdx=NaN;
    if ismember(feature,class_names)
        %feature is in file already, choose same foregroundcolor
        foregroundColor=class_colors(strcmp(class_names,feature));
    else
        %Not in file already, choose the next foregroundcolor and write to file
        foregroundColor=settings.foregroundColors(numel(class_colors));
        fprintf(f,'\n%s,%i,%i,%i', feature, foregroundColor,foregroundColor,foregroundColor);
    end
    
end
fclose(f);
nrImages=numel(routes);
nbytes = fprintf('Preparing image 0 / %i', nrImages);

for i=1:nrImages
    if ismember(routes{i},duplicates)
        %They will be included later, fusing it into the original
        continue;
    end
    fprintf(repmat('\b',1,nbytes))
    nbytes = fprintf('Preparing image %i / %i\n', i, nrImages);
    rv=rand();
    if rv<=ratios(1); type='train'; elseif rv<=ratios(1)+ratios(2)
       type='val'; else; type='test'; end
    fn=[config(1:end-4),'_' num2str(i+offset,'%04.f'),'.tif'];
    
    %% Reads the image and the mask.
    imageFullName = fullfile(path,[routes{i} '.tif']);
    imageSelFullName= fullfile(path,[routes{i} '_mod.tif']);
    if settings.splitDemarcationsByGroup
        groupIdx=find(strcmp(groups,groupImages{i}));
    end

    try
        [mask, image] = getBaseImages(imageFullName,imageSelFullName,NaN,0,1);
        %Always assume images without demarcation show only background (The last 1 in the function call)
        
    catch
        fprintf('Image %s does not exist, will be skipped\n', routes{i});
        continue;
    end
    
    if ismember(routes{i},duplicated_images)
        %Make a cell array of all masks 
        %image should anyway be the same for all of them (This is not checked for!)
        mask={mask};
        dupl_imgs=duplicates(startsWith(duplicates,routes{i}));

        for d=1:numel(dupl_imgs)
            imageFullName = fullfile(path,[dupl_imgs{d} '.tif']);
            imageSelFullName= fullfile(path,[dupl_imgs{d} '_mod.tif']);
            try 
                mask{end+1}=getBaseImages(imageFullName,imageSelFullName,NaN,0,1);
                if settings.splitDemarcationsByGroup
                    idx=strcmp(routes,dupl_imgs{d});
                    groupIdx(end+1)=find(strcmp(groups,groupImages{idx}));
                end
            catch
                fprintf('Image %s does not exist, will be skipped\n', dupl_imgs{d});
            end


        end

    end

    imsize=[size(image,1),size(image,2)];

    %For Demarcation prediction
    [image, label]=prepareImage(image,targetsize,mask,foregroundColor,settings.backgroundColor,0,groupIdx);

    imwrite(image,fullfile(targetfolder, type, fn));
    imwrite(label,fullfile(targetfolder, [type '_labels'],fn));
    if ~isnan(fid)
        fprintf(fid,'\n%s;%s;%s;%s',routes{i},fn,reverse_eval(imsize),type);
    end
    
end
end

