function compareFoundParticles(config1,config2,outfile,onlyParticlesWithin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Particles less than factor*radius nm from each other will be counted as
%identical
factor=2/3;

if nargin<4
    onlyParticlesWithin=1;
end

settings=readDefaults(config1);
settings2=readDefaults(config2);
assert(isequal(settings.particleTypes,settings2.particleTypes));
particleRadii=settings.particleTypes./2;
routes=readConfig(config1);
imageSet1=getInfoImages(config1,settings.dilate,onlyParticlesWithin);
imageSet2=getInfoImages(config2,settings2.dilate,onlyParticlesWithin);
nrImg=numel(imageSet1);
assert(nrImg==numel(imageSet2));
fid=fopen(outfile,'w');
fprintf(fid,'Image');
for p=1:numel(particleRadii)
    fprintf(fid,';Nr_%gnmParticlesSet1;Nr_%gnmParticlesSet2;Nr_shared%gnmParticles;OnlySet1_%gnm;OnlySet2_%gnm;IoU_%gnm',repelem(particleRadii(p)*2,6));
end
for i=1:nrImg
    fprintf(fid,'\n%s',routes{i});
    for p=1:numel(particleRadii)
        radius=particleRadii(p);
        part1=imageSet1{i}.centers(imageSet1{i}.teorRadii==radius,:);
        part2=imageSet2{i}.centers(imageSet2{i}.teorRadii==radius,:);
        if isempty(part1)&&isempty(part2)
            intersect=0;
            iou=1;
        elseif isempty(part1)||isempty(part2)
            intersect=0;
            iou=0;
        else
            dist1=distToNearestPoint2Sets(part1,part2,1);
            dist2=distToNearestPoint2Sets(part2,part1,1);
            dist1(dist1<radius*factor)=0;
            dist2(dist2<radius*factor)=0;
            intersect=sum(dist1==0);
            
            assert(intersect==sum(dist2==0));
            in1=sum(dist1~=0);
            in2=sum(dist2~=0);
            iou=intersect/(numel(dist1)+sum(dist2~=0));
        end
        fprintf(fid,';%g;%g;%g;%g;%g;%g',size(part1,1),size(part2,1),intersect,in1,in2,iou);
    end
end
fclose(fid);



end

