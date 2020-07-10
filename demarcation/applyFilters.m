function filteredImages = applyFilters(image,scale,defaults,filteredImages,modImage)
%APPLYFILTERS Summary of this function goes here
%   Detailed explanation goes here
if nargin<5
    modImage=NaN;
end
if nargin<4
    filteredImages={};
end

filteredImages{1}.image=image;
filteredImages{1}.name='Original Image';
filteredImages{1}.fct='polygon';
i=1;
%image=rgb2gray(image);

if ~isnan(modImage)
    modComponents=imbinarize(modImage,0.97); 
    modComponents=abs(bwareaopen(modComponents,100)-1); %Abs -1 because of dark foreground
    demarc=image;
    demarc(modComponents==0)=image(modComponents==0)*defaults.BackgroundBrightness;
    
    filteredImages{2}.image=demarc;
    filteredImages{2}.name='saved Component';
    filteredImages{2}.fct='select';
    filteredImages{2}.compImage=modComponents;
    i=i+2;
end

if defaults.showFilters %Not really useful, also takes lot of time (so off by default)
    %GradientWeight
    gw=gradientweight(image,defaults.gw_sigma,'WeightCutoff',defaults.gw_cutoff);
    filteredImages{i+1}.image=gw;
    filteredImages{i+1}.name='Gradient Weight';
    filteredImages{i+1}.fct='polygon';

    %Kind of percentile filter
    fgw=ordfilt2(gw,7,ones(7,7));
    filteredImages{i+2}.image=fgw;
    filteredImages{i+2}.name='Filtered Gradient Weight';
    filteredImages{i+2}.fct='polygon';

    %Get egdes and remove too small one
    edges=bwareaopen(edge(fgw),floor(12/scale)); %30 should be replaced by a scaled value
    filteredImages{i+3}.image=edges;
    filteredImages{i+3}.name='Edges';
    filteredImages{i+3}.fct='polygon';

    se=strel('disk',7);     %7 should be replaced by scaled value
    se2=strel('disk',7);
    components=imdilate(edges,se);
    components=imclose(components,se2);
    image(components==0)=image(components==0)*defaults.BackgroundBrightness;
    filteredImages{i+4}.image=image;
    filteredImages{i+4}.name='Connected components';
    filteredImages{i+4}.fct='select';
    filteredImages{i+4}.compImage=components;
end
end

