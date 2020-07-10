function classifierTraining(features,classes, radii, filename, algorithm)
%CLASSIFIERTRAINING Summary of this function goes here
%   Detailed explanation goes here
assert(numel(features)==numel(radii) && numel(classes)==numel(radii));
for r=1:numel(radii)
    str=sprintf('nm%g', 2*radii(r));
    str=strrep(str,'.','_'); %In case diameter is a float
    switch algorithm
        case 'naiveBayes'
            classifier.(str)=fitcnb(features{r},classes{r});
        case 'randomForest'
            classifier.(str)=TreeBagger(16, features{r},classes{r});
        otherwise
            fprintf('Algorithm %s is not known', algorithm);
            return
    end
end
s=readDefaults();
save(fullfile(s.classifierPath, [filename '.mat']), '-struct', 'classifier');
save(fullfile(s.classifierPath, [filename '_data.mat']), 'features','classes', 'radii');