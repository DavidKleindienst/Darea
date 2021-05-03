function [routes,scales,selectedAngles,groups,imNames] = readConfig(filepath,fileextension,choice,invertChoice)
%% Reads the .dat Configuration File
% fileextension: fileextension of the result files, this parameter
% is only needed when imNames (i.e. List of Images marked with asterisk if 
% the result file exists) is wanted.
% If you used imageChooser to subselect some of the images you can supply
% choice to only return images marked by this choice
% If invertChoice is set to true, all images except those marked by this
% choice will be returned

%TODo: Think about extending choice so that an array of choices can be
%supplied

if nargin<2; fileextension=NaN; end
if nargin<3; choice=NaN; end
if nargin<4; invertChoice=false; end
selectPath=[filepath(1:end-4) '_selected.dat'];
path=fileparts(filepath);
infoData = tdfread(filepath,',');
isSerEM = isfield(infoData, 'ANGLES');

if ~any(isnan(choice)) && isfile(selectPath)
    selection=tdfread(selectPath);
    if ~all(all(infoData.ROUTE==selection.Image))
        fprintf('Selection File does not correspond to config file, so selection was ignored')
    else
        %Modify infoData so that only selected rows are there
        stringLength=size(selection.Choice,2);
        fields=fieldnames(infoData);
        for idx=1:numel(fields)
            field=fields{idx};
            if invertChoice
                infoData.(field)=infoData.(field)(all(selection.Choice~=pad(choice,stringLength),2),:);
            else
                infoData.(field)=infoData.(field)(all(selection.Choice==pad(choice,stringLength),2),:);
            end
        end
    end
end
numImages = size(infoData.ROUTE,1);
% Creates the data structures storing the information about the images.
routes = cell(numImages,1);
imNames = cell(numImages,1);
scales = zeros(numImages,1);
groups = cell(numImages,1);
if isSerEM
    selectedAngles=zeros(numImages,1);
else
    selectedAngles=NaN;
end

% Processes each image.
for imgIndex=1:numImages
    routes{imgIndex} = strtrim(num2str(infoData.ROUTE(imgIndex,:))); %if its already a string,
    groups{imgIndex} = strtrim(num2str(infoData.GROUP(imgIndex,:))); %num2str will do nothing
    
    if ~isnan(fileextension)
        % This takes a bit of time, so run only when needed
        if isfile(fullfile(path, [routes{imgIndex} fileextension]))
            % If a result file exists, mark image name with a star, 
            % so user knows he has already worked on this image
            imNames{imgIndex}=sprintf([routes{imgIndex} '\t *']);
        else
            imNames{imgIndex}=routes{imgIndex};
        end
    end
    if isfield(infoData, 'CALIBRATION')
        calibration = infoData.CALIBRATION(imgIndex);
        magnification = infoData.MAGNIFICATION(imgIndex);
        scales(imgIndex) = calibration * 10/magnification;
    else
        scales(imgIndex) = infoData.PIXELSIZE(imgIndex);
    end
    if isSerEM
        selectedAngles(imgIndex) = infoData.SELECTED(imgIndex);
    end
end

if nargout>=4 && any(isnan(fileextension))
    imNames=routes;
end

    
end

