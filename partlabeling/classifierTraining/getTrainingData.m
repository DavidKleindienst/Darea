function [outputparticleFeatures,outputparticleClass, partRadii]=getTrainingData(datFiles, sens,margin, showInfos)

if nargin<4
    showInfos=false;
end


partRadii=[];
for f=1:numel(datFiles)
   %Find which particles sizes to analyze
   settings=readDefaults();
   settings=updateDefaults(getOptionsName(datFiles{f}), settings);
   partRadii=[partRadii, settings.particleTypes./2];
end
partRadii=unique(partRadii);
%For storing results
outputparticleFeatures=cell(1,numel(partRadii));
outputparticleClass=cell(1,numel(partRadii));
for p=1:numel(partRadii)
    outputparticleFeatures{p}=[];
    outputparticleClass{p}=[];
end


for f=1:numel(datFiles)

    settings=readDefaults();
    settings=updateDefaults(getOptionsName(datFiles{f}), settings);
    path=fileparts(datFiles{f});
    % Get sensitivity and margin for each datFile
    % if not provided as input argument
    if isnan(sens)
        sensitivity=settings.sensitivity;
    elseif f==1
        sensitivity=sens;
    end
    if isnan(margin)
        marginNm=settings.marginNm;
    elseif f==1
        marginNm=margin;
    end
    [routes, scales, selAngles]=readConfig(datFiles{f});
    numImages=numel(routes);
    dilate=settings.dilate;
    %For Storing results:
    ImgParticleFeatures=cell(1,numImages);
    ImgParticleClass=cell(1,numImages);
    
    parfor imgIndex=1:numImages
        particleFeatures=cell(1,numel(partRadii));
        particleClass=cell(1,numel(partRadii));
        for p=1:numel(partRadii)
            particleFeatures{p}=[];
            particleClass{p}=[];
        end
        imageName = routes{imgIndex};
        if showInfos; fprintf(['\nNow processing ' imageName '\n']); end
        scale = scales(imgIndex);
        fullImageName = fullfile(path,imageName);
         %% Reads the image and the mask.
        if isnan(selAngles)
            angle=NaN;
            imageFullName = [fullImageName '.tif'];
        else
            angle=selAngles(imgIndex);
            imageFullName=fullImageName;
        end
        imageSelFullName= [fullImageName '_mod.tif'];
        [maskSection, image] = getBaseImages(imageFullName,imageSelFullName,angle, round(dilate/scale));

        maskSection = ~maskSection;
        imR=imref2d(size(image),scale,scale);

        resultsFile = [fullImageName 'dots.csv'];

        %% read particle Positions from File
        datacsv = csvread(resultsFile);
        allrealparticleCenters = datacsv(:,1:2);
        allrealparticleRadii = datacsv(:,4);
        for p=1:numel(partRadii)
            realparticleCenters=allrealparticleCenters(allrealparticleRadii==partRadii(p),:);
            [detectedCenters, detectedRadii, ~, detFeatures] = detectParticles(image, maskSection, imR, scale, sensitivity, partRadii(p), marginNm, false,false);
            chosenParticles=[];

            particleClassImg=zeros(numel(detectedRadii),1); % Contains the labels: 0-> false positive; 1 -> true particle
            for i=1:numel(detectedRadii)
                centerDistMargin=partRadii(p)/3;
                if distToNearestPoint2Sets(detectedCenters(i,:),realparticleCenters)<=centerDistMargin && detectedRadii(i)<partRadii(p)+(marginNm*1.2) && detectedRadii(i)>partRadii(p)-(marginNm*1.2)

                   [~,closestPart]=min(distToNearestPoint2Sets(realparticleCenters,detectedCenters(i,:)));
                   if showInfos && numel(chosenParticles)>0 && ismember(realparticleCenters(closestPart,:),chosenParticles,'rows')
                       fprintf(['A ' num2str(partRadii(p)) 'nm particle was chosen twice.\n']);
                       if 0 %debug
                           figure; imshow(image,imR);
                           hold on
                           viscircles(realparticleCenters(closestPart,:),2,'LineWidth',2, 'EdgeColor', 'blue');
                           viscircles(detectedCenters(i,:),detectedRadii(i), 'LineWidth',2, 'EdgeColor', 'red');
                           viscircles(detectedCenters(particleClassImg==1,:),detectedRadii(particleClassImg==1),'LineWidth',2, 'EdgeColor', 'green');
                           hold off
                           pause(0.2)
                       end
                   end
                   particleClassImg(i)=1; 
                   chosenParticles=[chosenParticles; realparticleCenters(closestPart,:)];
                end

            end
            if showInfos
                if numel(chosenParticles)>0
                    if ~all(ismember(realparticleCenters,chosenParticles, 'rows'))
                        fprintf([num2str(sum(ismember(realparticleCenters,chosenParticles, 'rows')==0)) ' ' num2str(partRadii(p)) 'nm particles were not chosen.\n']);
                    end
                elseif numel(realparticleCenters)>0
                    fprintf(['No ' num2str(partRadii(p)) 'nm particles were chosen.\n']);

                end
            end
            if 0    %debugging, parfor needs to be made to for to use this
                figure; imshow(image, imR);
                hold on
                viscircles(realparticleCenters,zeros(size(realparticleCenters,1),1)+2,'LineWidth',2,'EdgeColor','blue');
                viscircles(detectedCenters,detectedRadii,'LineWidth',2,'EdgeColor','red');
                hold off
                pause(0.2);
            end
            if 0    %debugging, parfor needs to be made to for to use this
                figure; imshow(image,imR);
                hold on
                viscircles(realparticleCenters,zeros(size(realparticleCenters,1),1)+2,'LineWidth',2,'EdgeColor','blue');
                viscircles(detectedCenters(particleClassImg==1,:),detectedRadii(particleClassImg==1,:),'LineWidth',2,'EdgeColor','red');
                hold off
                pause(0.2);
            end


            particleFeatures{p}=[particleFeatures{p}; detFeatures];
            particleClass{p}=[particleClass{p}; particleClassImg];

        end
        ImgParticleFeatures{imgIndex}=particleFeatures;
        ImgParticleClass{imgIndex}=particleClass;
    end
    

    for p=1:numel(partRadii)
        for imgIndex=1:numImages
            outputparticleFeatures{p}=[outputparticleFeatures{p};ImgParticleFeatures{imgIndex}{p}];
            outputparticleClass{p}=[outputparticleClass{p};ImgParticleClass{imgIndex}{p}];
        end
    end
    
end

end

