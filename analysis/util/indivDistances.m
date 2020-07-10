function indivDistances(Data,Distance,fileName,dist_names,indeces, b)
%% Saves Distances for each individual particles in a csv file
% Input Arguments:
% Data - Data obtained from running analysis
% Distance: the specific infoDistance struct (is actually a subfield of Data)
% fileName: path to the csv file to save in
% dist_names: Names of each type of distance.
% indeces: Array of indeces of images to be considered
% b: index to specify the type of distance in a methodB array
Images=Data.Orig.Images;
fid=fopen(fileName,'w');
fprintf(fid, '%s;%s;%s', 'Image Id', 'Image Route', 'Particle Id');


for x=2:numel(Data.distfields) % Don't do it for allDistances, because more than one Distance per particle
    
    if isnan(Data.methodB{b}{2}) || Data.isPairedField(x)
        % first argument: distances of one class of particles those have
        % distances from edge
        % second argument: if this field is one between classes of
        % particles
        fprintf(fid, ';%s', dist_names{x});
    end
end
fprintf(fid,'\n');

for i=1:numel(indeces)
    imNr=indeces(i);
    fprintf(fid,'%i;%s;Mean',Images{indeces(i)}.id, Images{indeces(i)}.route);
    for p=0:length(Distance{b}{imNr}.distances)
        if p>0; fprintf(fid,';;%i',p); end
        for x=2:numel(Data.distfields)
            if isnan(Data.methodB{b}{2}) || Data.isPairedField(x)
                % first argument: distances of one class of particles those have
                % distances from edge
                % second argument: if this field is one between classes of
                % particles
                if p==0
                    %Add a mean row
                    fprintf(fid, ';%g', mean(Distance{b}{imNr}.(Data.distfields{x})) );
                else
                    fprintf(fid, ';%g', Distance{b}{imNr}.(Data.distfields{x})(p));
                end
            end
        end
        fprintf(fid,'\n');
    end
end
fclose(fid);
end

