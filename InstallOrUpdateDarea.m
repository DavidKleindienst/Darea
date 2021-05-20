function InstallOrUpdateDarea()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if isfile('Run.m')
    %already installed, update

[~,r] = system('git remote -v');

    if contains(r, 'https://github.com/DavidKleindienst/Darea.git')
        !git pull origin master
    elseif contains(r, 'fatal: not a git repository')
        sprintf(['Darea was not installed using this script and can thus not be updated automatically.\n' ...
                'Please copy this script to an empty folder and run it there to install Darea in a way' ...
                'that supports automatic updating']);
    elseif contains(r, 'is not recognized as an internal or external command')
        sprintf('Git is not installed. Please install git, restart MATLAB then run this script again')
    else
        sprintf('Unknown github repository, could not update');
    end
else
    [~,r]=system('git clone https://github.com/DavidKleindienst/Darea.git');
    if contains(r, 'Cloning into')
        movefile('Darea/*', './');
        rmdir('Darea');
        sprintf('Installation was successful');
    elseif contains(r, 'is not recognized as an internal or external command')
        sprintf('Git is not installed. Please install git, restart MATLAB and try again')
    else
        sprintf('An unknown problem occur. Please make sure git is installed, restart MATLAB and try again');
    end
        
end
