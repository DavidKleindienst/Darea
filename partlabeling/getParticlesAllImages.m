function getParticlesAllImages(datFile,useDemarcation, overwrite, useClassifier, settings)
[routes, scales,selAngles]=readConfig(datFile);
routes=getFullRoutes(routes,datFile);

%Avoid broadcasting all settings array

%for i=1:numel(routes)
parfor (i=1:numel(routes), getCurrentPoolSize())
    
    tic;
    if isnan(selAngles) | selAngles(i)>0
        dotFile=[routes{i} 'dots.csv'];
        if ~overwrite && isfile(dotFile)
            continue
        end
        if isnan(selAngles)
            getParticlesImage(routes{i},NaN,scales(i),dotFile,...
                               useDemarcation,useClassifier,settings)
        else
            getParticlesImage(routes{i},selAngles(i),scales(i),dotFile,...
                               useDemarcation,useClassifier,settings)
        end 
    else
        [~,angles]=readMdoc([routes{i} '.mdoc']);
        for a=1:numel(angles)
            dotFile=[routes{i} 'dots_' int2str(a) '.csv'];
            if ~overwrite && isfile(dotFile)
                continue
            end
            getParticlesImage(routes{i},a,scales(i),dotFile,...
                               useDemarcation,useClassifier,settings)
        end
    end
    time_taken=toc;
    fprintf(['Predicted particles on image ' routes{i} ' in ' num2str(time_taken) ' seconds.\n']);
end

end