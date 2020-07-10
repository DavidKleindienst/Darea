function features = getTrainedNetworks()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
features=dir('deepLearning/checkpoints');
features={features.name};
features=features(contains(features,'.ckpt.'));
features=unique(cellfun(@(C)extractBefore(C,'.'),features,'UniformOutput',false));
end

