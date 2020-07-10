function getParticlesAllImages(datFile,useDemarcation, overwrite, useClassifier, settings)

[routes, scales]=readConfig(datFile);
routes=getFullRoutes(routes,datFile);
parfor (i=1:numel(routes), getCurrentPoolSize())
    imName=[routes{i} '.tif'];
    dotFile=[routes{i} 'dots.csv'];
    if ~overwrite && isfile(dotFile)
        continue
    end
    if useDemarcation
        maskName=[routes{i} '_mod.tif'];
        [mask, image]=getBaseImages(imName, maskName, round(settings.dilate/scales(i)));
        mask = ~mask;
    else
        image=imread(imName);
        mask=NaN;
    end
    imR=imref2d(size(image),scales(i),scales(i));
    fid=fopen(dotFile,'w');
    for p=1:numel(settings.particleTypes)
        
        radius=settings.particleTypes(p)/2;
        [c, r]=detectParticles(image,mask,imR,scales(i),settings.sensitivity,radius,settings.marginNm,false,useClassifier);
        %print to file!
        sprintf('Found %f %f particles', numel(r), radius);
        for part=1:numel(r)
            fprintf(fid, '%f, %f, %f, %f\n', c(part,1), c(part,2), r(part), radius);
        end
    end
    fclose(fid);
end

end