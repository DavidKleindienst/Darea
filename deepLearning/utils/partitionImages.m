function [pximdsTrain, pximdsTest] = partitionImages(pximds)
% Partition data by randomly selecting 60% of the data for training. The
% rest is used for testing.
% Set initial random state for example reproducibility.
rng(0); 
numFiles = numel(pximds.Images);
shuffledIndices = randperm(numFiles);

% Use 66% of the images for training.
N = round(0.66 * numFiles);
trainingIdx = shuffledIndices(1:N);

% Use the rest for testing.
testIdx = shuffledIndices(N+1:end);

pximdsTrain=partitionByIndex(pximds,trainingIdx);
pximdsTest=partitionByIndex(pximds,testIdx);
end