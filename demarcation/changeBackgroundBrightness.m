function filteredImages= changeBackgroundBrightness(originalImage,filteredImages,defaults)


for i=1:numel(filteredImages)
    if strcmp(filteredImages{i}.fct,'select') || strcmp(filteredImages{i}.fct,'finalize')
        components=filteredImages{i}.compImage;
        image=originalImage;
        image(components==0)=image(components==0)*defaults.BackgroundBrightness;
        filteredImages{i}.image=image;
    end
end

end

