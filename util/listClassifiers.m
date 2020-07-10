function classifiers = listClassifiers()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
s=readDefaults();
f=dir(s.classifierPath);
classifiers={f.name};
classifiers=classifiers(endsWith(classifiers,'.mat'));
classifiers=classifiers(~endsWith(classifiers,'_data.mat'));
classifiers=cellfun(@(x) x(1:end-4), classifiers, 'UniformOutput', false);

end

