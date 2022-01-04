function showOverviewSection(folder,images)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% ToDo: let user choose this
contrast = true;

if isempty(images)
    return;
end

if numel(images)>1
    [index, ~] = listdlg('PromptString', 'Select the corresponding overview section',...
                        'ListString',images, 'SelectionMode','single');
    if isempty(index)
        return;
    end
    image = imread(fullfile(folder,images{index}));
else
    image = imread(fullfile(folder,images{1}));
end

if contrast
    image=imadjust(image);
end
   
figure;
imshow(image);


end

