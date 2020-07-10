function [filepath, results] = imageChooserToFile(filepath,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

results=imageChooser(varargin);
if iscell(results)
    T=cell2table(results, 'VariableNames',{'Image', 'Choice'});
    writetable(T,filepath,'Delimiter','\t');
end


end

