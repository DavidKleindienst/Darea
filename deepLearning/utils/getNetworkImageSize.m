function imageSize = getNetworkImageSize(network_name)

infoFile = fullfile('deepLearning/checkpoints', [network_name '.info']);
if ~isfile(infoFile)
    error('Image size for network %s was not found because file %s does not exist', ...
        network_name, infoFile);
end
imageSize=getImageSizeFromInfoFile(infoFile);

if isnan(imageSize)
    error('Image size for network %s was not found in file %s', ...
        network_name, infoFile);
end
end

