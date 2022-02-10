function bool = deepLearningAvailable()
%% Tests if all python packages required for deep learning are available
[~,pyExe]=pyversion;
[retVal,output]=system([pyExe ' python/manyUtils.py --function packages_available']);


if retVal~=0    % python threw some error
    bool=false;
    return
end
if endsWith(strip(output), 'True')
    bool=true;
else
    bool=false;
end

end

