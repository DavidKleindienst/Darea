function Colocalization = sendForColocalization(Data, Images, r1,r2, thresholdDistance, keepIm)
% Chooses the correct thresholddistance for each particle size and group depending on settings.
% Then sends the Data on to the Colocalization function

partidx=Data.radii==r1 | Data.radii==r2;

if ~iscell(thresholdDistance)   %Groups and Particles together
    Colocalization=getInfoColocalization(Images, r1, r2, thresholdDistance,  keepIm);
elseif size(thresholdDistance,1)>1 && size(thresholdDistance,2)>1   %Groups and Particles individual
    for g=1:Data.Groups.number
        Colocalization=cell(size(Images));
        indeces=find(Data.Groups.imgGroup==g);
        Colocalization(indeces)=getInfoColocalization(Images(indeces), r1, r2, [thresholdDistance{g,partidx}],  keepIm);
    end
elseif size(thresholdDistance,1)>1  %Groups individual
    for g=1:Data.Groups.number
        Colocalization=cell(size(Images));
        indeces=find(Data.Groups.imgGroup==g);
        Colocalization(indeces)=getInfoColocalization(Images(indeces), r1, r2, thresholdDistance{g},  keepIm);
    end
elseif size(thresholdDistance,2)>1  %Particles individual
    Colocalization=getInfoColocalization(Images, r1, r2, [thresholdDistance{partidx}],  keepIm);
else        %Happens if someone choses groupwise, but there's only one group
    Colocalization=getInfoColocalization(Images, r1, r2, thresholdDistance{1},  keepIm);
end


end

