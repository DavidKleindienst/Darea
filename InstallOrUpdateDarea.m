function InstallOrUpdateDarea()
%% Clones or Updates Darea from the Github repository
% Designed as a comfortable update script for users
% Not designed for usage by developers using git themselves.
% If you use it when some files were modified, they will be stashed automatically

if isfile('Run.m')
    %already installed, update

[~,r] = system('git remote -v');

    if contains(r, 'https://github.com/DavidKleindienst/Darea.git')
        !git stash
        !git pull origin master
        fprintf('Updated Darea.')
    elseif contains(r, 'fatal: not a git repository')
        fprintf(['Darea was not installed using this script and can thus not be updated automatically.\n' ...
                'Please copy this script to an empty folder and run it there to install Darea in a way' ...
                'that supports automatic updating\n']);
    elseif contains(r, 'is not recognized as an internal or external command\n')
        fprintf('Git is not installed. Please install git, restart MATLAB then run this script again\n')
    else
        fprintf('Unknown github repository, could not update\n');
    end
else
    [~,r]=system('git clone https://github.com/DavidKleindienst/Darea.git');
    if contains(r, 'Cloning into')
        movefile('Darea/*', './');
        if isfile('Darea/.gitignore')
            % On MacOS, movefile doesn't move hidden files unless explicitly asked
            movefile('Darea/.g*', './')
        end
        isfile('Darea/.gitignore')
        isfile('.gitignore')
        rmdir('Darea');
        fprintf('Installation was successful\n');
    elseif contains(r, 'is not recognized as an internal or external command\n')
        fprintf('Git is not installed. Please install git, restart MATLAB and try again\n')
    else
        fprintf('An unknown problem occur. Please make sure git is installed, restart MATLAB and try again\n');
    end
        
end
