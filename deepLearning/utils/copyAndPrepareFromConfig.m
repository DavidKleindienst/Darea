function copyAndPrepareFromConfig(path,config,targetfolder,fid,particleColors,settings)
%COPYANDPREPAREFROMDAT Summary of this function goes here
%   Detailed explanation goes here
if nargin<4
    fid=NaN;
end
if nargin<5
    particleColors=NaN;
end
if nargin<6
    settings=readDefaults(fullfile(path,config));
end
[routes,scales]=readConfig(fullfile(path,config));
%If its for particle prediction, config is "feature/config.dat"
%Move feature to path so the images are properly found
%and replace the / with __ so converted images can be saved in correct
%folder
path=fullfile(path,fileparts(config));
config=replaceSlash(config);

ratios=settings.train_val_test_ratios; 
targetsize=settings.imageSize;


for i=1:numel(routes)
    rv=rand();
    if rv<=ratios(1); type='train'; elseif rv<=ratios(1)+ratios(2)
       type='val'; else; type='test'; end
    fn=[config(1:end-4),'_' num2str(i,'%04.f'),'.tif'];

    %% Reads the image and the mask.
    imageFullName = fullfile(path,[routes{i} '.tif']);
    dotsName=fullfile(path,[routes{i} 'dots.csv']);
    imageSelFullName= fullfile(path,[routes{i} '_mod.tif']);
    flag=1;
    try
        if ~isstruct(particleColors)
            %Demarcation prediction
            [mask, image] = getBaseImages(imageFullName,imageSelFullName,0,settings.noROI_is_Background);
        else
            %Particle prediction
            [mask, image] = getBaseImages(imageFullName,imageSelFullName, round((settings.dilate+5)/scales(i)));
                %Dilate 5 nm more, so particle just on the edge will be visible to DL
            [dots.c,~,dots.r]=readDotsFile(dotsName);
            dots.c=round(dots.c./scales(i));
            dots.scale=scales(i);
        end
    catch
        fprintf('Image %s does not exist, will be skipped\n', routes{i});
        flag=0;
    end
    if flag
        imsize=[size(image,1),size(image,2)];
        if isstruct(particleColors)
            %For Particle prediction
            
            %% Dilation of MASK is missing here!!
            
            [image, label]=prepareImage(image,targetsize,mask,particleColors,settings.backgroundColor(1),1,dots);
        else
            %For Demarcation prediction
            [image, label]=prepareImage(image,targetsize,mask,settings.foregroundColor(1),settings.backgroundColor(1));
        end

        imwrite(image,fullfile(targetfolder, type, fn));
        imwrite(label,fullfile(targetfolder, [type '_labels'],fn));
        if ~isnan(fid)
            fprintf(fid,'\n%s;%s;%s;%s',routes{i},fn,reverse_eval(imsize),type);
        end
    end
end
end

