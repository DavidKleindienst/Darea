function infoCounting = getInfoCounting(infoImages, showProgress)
%% For each image, counts the number of particle of each radii. First it checks the number of 
% different theoretical radii used, and then counts the number of particles
% of each radii for each image.

%   infoImages: cell array with the information relative to each image.
%
%   infoImages{}.id:                      Id of the image.
%   infoImages{}.route:                   Route to the files relative to the image.
%   infoImages{}.area:                    Area of interest (squared nanometers).
%   infoImages{}.numParticles:            Number of particles.
%   infoImages{}.centers:                 Locations of the particles (nanometers).
%   infoImages{}.radii:                   Actual radii of the particles (nanometers).
%   infoImages{}.teorRadii:               Teorethical radii of the particles.

%   showProgress: If true, it shows progress by console.

%   infoCounting: Struct containing the results.
%
%   infoCounting.categories                Array containing the different theoretical radii considered.
%   infoCounting.counts                    Matrix  containing the counts (vector) for each image and radius considered.

numImages = size(infoImages, 1);

%% Extracts the categories.
if showProgress
    fprintf('\n Counting particles.\n');
end
teorRadii = [];

for nImage=1:numImages
    teorRadii = [teorRadii ; infoImages{nImage}.teorRadii];
end

infoCounting.categories = unique(teorRadii);
% Sorts them in ascending order
infoCounting.categories = sort(infoCounting.categories);
numCategories = numel(infoCounting.categories);
if showProgress
    fprintf('\n\t Theoretical radii considered: [  ');
    strCategories=sprintf('%.1f  ', infoCounting.categories);
    fprintf('%s]\n', strCategories)
end

%% Initializes the matrix containing the counts and densities
infoCounting.counts = zeros(numImages,numCategories);
%% Makes the counts
for nImage=1:numImages
    % Counts each category
    for nCategory=1:numCategories
        infoCounting.counts(nImage,nCategory) = sum(infoImages{nImage}.teorRadii==infoCounting.categories(nCategory));
    end
end
    if showProgress   
        fprintf('\n Process finished. %d particles counted in %d images.\n\n',sum(infoCounting.counts(:)), numImages); 
    end
end

