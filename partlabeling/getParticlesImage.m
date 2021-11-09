function getParticlesImage(route,selAngle,scale,dotFile,useDemarcation,useClassifier,settings)
    
    if useDemarcation
        maskName=[route '_mod.tif'];
        [mask, image]=getBaseImages(imName, maskName,selAngle, round(dilate/scale));
        mask = ~mask;
    else
        image=readAndConvertImage(imName,selAngle);
        mask=NaN;
    end
    imR=imref2d(size(image),scale,scale);
    fid=fopen(dotFile,'w');
    for p=1:numel(settings.particleTypes)
        radius=particleTypes(p)/2;
        [c, r]=detectParticles(image,mask,imR,scale,settings.sensitivity,radius,settings.marginNm,false,useClassifier);
        %print to file!
        sprintf('Found %f %f particles', numel(r), radius);
        for part=1:numel(r)
            fprintf(fid, '%f, %f, %f, %f\n', c(part,1), c(part,2), r(part), radius);
        end
    end
    fclose(fid);
end