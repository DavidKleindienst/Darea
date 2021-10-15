function convertPredictionsToMod(predFolder,imList,targetSizes,overwrite)
%% Converts demarcation predictions to _mod files

imListNoDupl=imList(~endsWith(imList,'_dupl'));
assert(numel(imListNoDupl)==numel(targetSizes))
nrImg=numel(imList);

%Duplicated images do not exist as prediction, but need to be copied to
%So dupl_offset needs to be subtracted from targetSizes indes and
%predFolder_filename, but not imList index
dupl_offset=0; 
if isfile(fullfile(predFolder,  '1.tif')) || isfile(fullfile(predFolder, '1_1.tif'))
    nbytes = fprintf('Converting prediction 0 / %i', nrImg);
    for img=1:nrImg
        fprintf(repmat('\b',1,nbytes))
        nbytes = fprintf('Converting prediction %i / %i\n', img, nrImg);
        if endsWith(imList{img}, '_dupl')
            dupl_offset=dupl_offset+1;
        end
        %Assumes images in predFolder are just numbered (as made by prepareForPrediction.m)
        if isfile(fullfile(predFolder, [int2str(img) '_1.tif']))
            %Predictions for multiple angles exist for this image
            if ~overwrite && isfile([imList{img} '_mod_1.tif'])
                %Skip image if it exists and should not be overwritten
                continue;
            end
            i=1;
            while isfile(fullfile(predFolder, [int2str(img-dupl_offset) '_' int2str(i) '.tif']))
                image=imread(fullfile(predFolder, [int2str(img-dupl_offset) '_' int2str(i) '.tif']));
                image=convertPredtoMask(image,targetSizes{img-dupl_offset});
                imwrite(image,[imList{img} '_mod_' str2int(i) '.tif']);
                i = i + 1;
            end
            
        else
            if ~overwrite && isfile([imList{img} '_mod.tif'])
                %Skip image if it exists and should not be overwritten
                continue;
            end
            image=imread(fullfile(predFolder, [int2str(img-dupl_offset) '.tif']));
            image=convertPredtoMask(image,targetSizes{img-dupl_offset});
            imwrite(image,[imList{img} '_mod.tif']);
        end
    end
else
    %not simply numbered files, get files list!

    files=dir(predFolder);
    files={files.name};
    files=files(~startsWith(files,'.'));
    files=files(endsWith(files,'_pred.tif'));
    assert(numel(files)==numel(imListNoDupl));
    nbytes = fprintf('Converting image 0 / %i', nrImg);
    for img=1:nrImg
        fprintf(repmat('\b',1,nbytes))
        nbytes = fprintf('Converting image %i / %i\n', img, nrImg);
        if endsWith(imList{img}, '_dupl')
            dupl_offset=dupl_offset+1;
        end
        if ~overwrite && isfile([imList{img} '_mod.tif'])
            %Skip image if it exists and should not be overwritten
            continue;
        end
        image=imread(fullfile(predFolder, files{img-dupl_offset}));
        image=convertPredtoMask(image,targetSizes{img-dupl_offset});
        imwrite(image,[imList{img} '_mod.tif']);
    end
end

end

