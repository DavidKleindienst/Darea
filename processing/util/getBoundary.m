function boundary = getBoundary(area,scale,fuseBoundaries,imgIndex,imageName)
%GETBOUNDARY Summary of this function goes here
%   fuseBoundaries: If true, all boundaries will be fused and a point
%                   matrix will be returned
%                   If false a cell array of point matrices will be
%                   returned
if nargin<4
    %These are for troubleshooting during Analysis only,
    %So can be ignored if not supplied
    imgIndex='';
    imageName='';
end
if size(area,3)==3
    %pseudo rgb image, get rid of last dimension
    area=area(:,:,1);
end
if sum(area,'all')>0 && sum(~area,'all')>10
    boundaries=bwboundaries(area');    % Gives coordinates of 0s on edge of area
    boundaries(1)=[];
    boundaries(cellfun('length',boundaries)<=10)=[]; %Delete all regions smaller than 10 px, because they are likely false detections

    if isempty(boundaries)
        %Maybe demarcation is at image border
        %Try expanding area by 4 px each side and redoing boundary computation
        area=[ones(4,size(area,2));area;ones(4,size(area,2))];
        area=[ones(size(area,1),4) area ones(size(area,1),4)];
        boundaries=bwboundaries(area');    % Gives coordinates of 0s on edge of area
        boundaries(1)=[];
        boundaries=cellfun(@(x)x-4,boundaries, 'UniformOutput',false); % Compensate for the 4 additional pixels
        boundaries(cellfun('length',boundaries)<=10)=[]; %Delete all regions smaller than 10 px, because they are likely false detections
    end
    boundary=[];
    %Douglas Peucker reduces the number of points in the boundary outline,
    %such that the error of the new boundary will be <=1px (thats the 1 in the argument)
    %at every position 
    boundaries=cellfun(@(x)DouglasPeucker(x,1),boundaries,'UniformOutput',false);
    boundaries=cellfun(@(x)x.*scale,boundaries,'UniformOutput',false);
    if ~fuseBoundaries
        boundary=boundaries;
        return
    end
    for i=1:numel(boundaries)
        boundary=[boundary;boundaries{i}];
    end
    if numel(boundaries)>2
        fprintf('Image %s has more than 2 regions. This might cause inaccuracies in distance from edge measurements.\n', imageName);
    end
    if isempty(boundary)
       %Something is wrong; output these for troubleshooting
       
       imgIndex
       boundaries
       error('Computation of boundary failed');
    end
else
    s=size(area);
    boundary=[1,1;1,s(2);s(1),s(2);s(1),1];
    boundary=boundary.*scale;
end
end

