function safeMkdir(dir)
%% Makes folder dir if it doesnt already exist

if ~isfolder(dir)
    mkdir(dir)
end

end

