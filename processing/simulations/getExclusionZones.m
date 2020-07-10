function area = getExclusionZones(area,zoneCenters,radius,type)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if strcmp(type,'random')
    return;
end

exclusionZones=ones(size(area));
[cols, rows]=meshgrid(1:size(area,1),1:size(area,2));
for z=1:size(zoneCenters,1)
    circlePixels = (rows - zoneCenters(z,2)).^2 + (cols - zoneCenters(z,1)).^2 <= radius.^2;
    exclusionZones(circlePixels)=0;
end

if strcmp(type,'inside')
    %Particles are distributed inside exclusion zones
    area=max(area, exclusionZones);
elseif strcmp(type, 'outside')
    %Particles are excluded from exclusion zones
    area=max(area,~exclusionZones);
elseif strcmp(type, 'only')
    area=exclusionZones;
else
    fprintf('Error: Particle - Exclusion zone relationship %s not known. Used random\nThis is a bug!\n', exclZoneType);
end

end

