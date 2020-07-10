function fuseDuplImages(datFile)
%Fuses masks of two dupl images (this is usually necessary when more than
%one ROI is on a image, and they should be analyzed seperately)

routes=readConfig(datFile);
%Get routes of all duplicates
all_dupls=routes(endsWith(routes,'_dupl'));
%Get routes of the original images of these duplicates
images=unique(cellfun(@(x) erase(x, '_dupl'), all_dupls, 'UniformOutput', false));

for i=1:numel(images)
    dupls=all_dupls(startsWith(all_dupls, images{i}));
    mod_img_path=getFullRoutes(images(i),datFile,'_mod.tif');
    mod=imread(mod_img_path{1});
    d_mod_paths=getFullRoutes(dupls,datFile,'_mod.tif');
    d_mod_paths=d_mod_paths(isfile(d_mod_paths));
    d_orig_paths=getFullRoutes(dupls,datFile,'.tif');
    d_orig_paths=d_orig_paths(isfile(d_mod_paths));

    for j=1:numel(d_mod_paths)
        mod2=imread(d_mod_paths{j});
        mod(mod2<65535)=mod2(mod2<65535);
        
        % Delete now unneccessary images
        delete(d_mod_paths{j});
        delete(d_orig_paths{j});
    end
    imwrite(mod,mod_img_path{1});
    
    dot_path=getFullRoutes(images(i), datFile, 'dots.csv');
    d_dots_paths=getFullRoutes(dupls, datFile, 'dots.csv');
    [centers, radii, teorRadii]=readDotsFile(dot_path{1});

    for j=1:numel(d_dots_paths)
        [c, r, tr, numP]=readDotsFile(d_dots_paths{j});

        for p=1:numP
            if numel(radii)==0 || min(pdist2(c(p,:), centers))>1
                %Probably not the same particle
                centers(end+1,:)=c(p,:);
                radii(end+1)=r(p);
                teorRadii(end+1)=tr(p);
            end
        end
        delete(d_dots_paths{j});
    end
    delete(dot_path{1});
    f=fopen(dot_path{1}, 'w');
    for p=1:numel(radii)
        fprintf(f, '%g, %g, %g, %g\n', centers(p,1), centers(p,2), radii(p), teorRadii(p));
    end
    fclose(f);
end

%Remove Dupl Entries from datFile
indeces=find(endsWith(routes,'_dupl'));
indeces=sort(indeces,'descend');
for i=1:numel(indeces)
    py.makeProjectFile.removeImage(datFile,py.int(indeces(i)-1));
end
end