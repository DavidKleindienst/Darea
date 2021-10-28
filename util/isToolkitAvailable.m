function bool = isToolkitAvailable(toolkitname)
%% Checks if the toolkit toolkitname is installed

persistent ver_array
if isempty(ver_array)
    ver_array=struct2array(ver);
end

bool=contains(ver_array, toolkitname);

end

