function registeredImages= registerImages(images,defaults)
%REGISTERIMAGES Summary of this function goes here
%   Detailed explanation goes here

registeredImages=cell(1,numel(images));
registeredImages{1}=images{1}; %First image remains unchanged
defaults.transformType='rigid';    %Move this to defaults later
[optimizer, metric] = imregconfig('monomodal');

%Align images 1 by 1 to previous image
for i=2:numel(images)
    tic
    registeredImages{i}=imregister(images{i},registeredImages{i-1},defaults.transformType,optimizer,metric);
    toc
end

end

