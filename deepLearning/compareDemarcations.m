function compareDemarcations(config1,config2,outfile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
settings=readDefaults(config1);
safeMkdir('tmp');
routes=readConfig(config1);
imageSet1=cellfun(@(x) fullfile(fileparts(config1),[x '_mod.tif']),routes,'UniformOutput',false);
routes=readConfig(config2);
imageSet2=cellfun(@(x) fullfile(fileparts(config2),[x '_mod.tif']),routes,'UniformOutput',false);
nrImg=numel(imageSet1);
assert(nrImg==numel(imageSet2));
class_dict='deepLearning/checkpoints/class_dict.csv';
fid=fopen(outfile,'w');
fprintf(fid,'Image;test_accuracy;precision;recall;f1 score;mean iou;Background accuracy;Demarcation accuracy;Background iou;Demarcation iou');
for i=1:nrImg
    name1=['tmp/1_' replaceSlash(imageSet1{i})];
    name2=['tmp/2_' replaceSlash(imageSet2{i})];
    dem=getBaseImages(NaN,imageSet1{i},0);
    [~, dem]=prepareImage(NaN,settings.imageSize,dem,settings.foregroundColor(1),settings.backgroundColor(1));
    imwrite(dem, name1);
    dem=getBaseImages(NaN,imageSet2{i},0);
    [~, dem]=prepareImage(NaN,settings.imageSize,dem,settings.foregroundColor(1),settings.backgroundColor(1));
    imwrite(dem,name2);
    
    results=py.utils.utils.evaluate_segmentation_on_files(name1,name2,class_dict);
    ious=double(results{7});
    fprintf(fid,'\n%s;%g;%g;%g;%g;%g;%g;%g;%g;%g',routes{i},results{1},results{3},results{4},results{5},results{6},results{2}{1},results{2}{2},ious(1),ious(2));
end
rmdir('tmp/','s');

fclose(fid);