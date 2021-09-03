function convertPredictionsToMod(predFolder,imList,targetSizes,overwrite)
%% Converts demarcation predictions to _mod files
nrImg=numel(imList);
assert(nrImg==numel(targetSizes))
if isfile(fullfile(predFolder,  '1.tif')) || isfile(fullfile(predFolder, '1_1.tif'))
    parfor (img=1:nrImg, getCurrentPoolSize())
        
        %Assumes images in predFolder are just numbered (as made by prepareForPrediction.m)
        if isfile(fullfile(predFolder, [int2str(img) '_1.tif']))
            if ~overwrite && isfile([imList{img} '_mod_1.tif'])
                %Skip image if it exists and should not be overwritten
                continue;
            end
            %Predictions for multiple angles exist for this image
            i=1
            while isfile(fullfile(predFolder, [int2str(img) '_' int2str(i) '.tif']))
                image=imread(fullfile(predFolder, [int2str(img) '_' int2str(i) '.tif']));
                image=convertPredtoMask(image,targetSizes{img});
                imwrite(image,[imList{img} '_mod_' str2int(i) '.tif']);
                i = i + 1;
            end
            
        else
            if ~overwrite && isfile([imList{img} '_mod.tif'])
                %Skip image if it exists and should not be overwritten
                continue;
            end
            image=imread(fullfile(predFolder, [int2str(img) '.tif']));
            image=convertPredtoMask(image,targetSizes{img});
            imwrite(image,[imList{img} '_mod.tif']);
        end
    end
else
    %not simply numbered files, get files list!
    %This part of the function is not used when using GUI and may be
    %unnecessary
    files=dir(predFolder);
    files={files.name};
    files=files(~startsWith(files,'.'));
    files=files(endsWith(files,'_pred.tif'));
    assert(numel(files)==nrImg);
    parfor (img=1:nrImg, getCurrentPoolSize())
        if ~overwrite && isfile(imList{img})
            %Skip image if it exists and should not be overwritten
            continue;
        end
        image=imread(fullfile(predFolder, files{img}));
        image=convertPredtoMask(image,targetSizes{img});
        imwrite(image,imList{img});
    end
end

end

