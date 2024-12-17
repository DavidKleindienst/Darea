function InstallOrUpdateDarea()
%% Clones or Updates Darea from the Github repository
% Designed as a comfortable update script for users
% Not designed for usage by developers using git themselves.
% If you use it when some files were modified, they will be stashed automatically

ENVIRONMENT_NAME = 'Darea'; %Name of the conda environment in which the required python packages will be installed
                            %Chose a different name if "Darea" is already taken for some other
                            %environment
GIT_REPOSITORY = 'https://github.com/DavidKleindienst/Darea.git';

%These files can be changed by user, so changes need to be kept when updating
usermodified_files = {'Mags.txt', 'configDefault_options.dat'};

home_folder=getenv('HOME');
if isempty(home_folder) && ispc
    % On Windows, HOME env variable may not be set
    home_folder=fullfile('C:/Users', getenv('USERNAME'));
end
    
%Possible default paths where anaconda installation might be

ANACONDA_PATH_MAC = {'/Applications/anaconda/', ...
                    fullfile(home_folder, 'Anaconda3'), ...
                    fullfile(home_folder, 'opt/anaconda3')};
ANACONDA_PATH_WIN = {'C:/ProgramData/Anaconda3/', ...
                    fullfile(home_folder, 'anaconda3'), ...
                    'C:/ProgramData/miniforge3/', ...
                    fullfile(home_folder, 'miniforge3'),
                    fullfile(home_folder, 'AppData/local/miniforge3')};  
%No path is necessary for linux

install_note_file = '.install_note.txt';

    function bool=isCondaPath(path, os)
        if ~isfolder(path)
            bool=false;
            return;
        end    
        switch os
            case 'mac'
                bool = isfolder(fullfile(path, 'bin')) && isfolder(fullfile(path, 'condabin'));
            case 'win'
                bool = isfolder(fullfile(path, 'condabin')) && isfolder(fullfile(path, "Library"));
        end
    end

    function [isPath,path]=userGetAnacondaPath(os)
        question=['Conda installation could not be found automatically.\n' ...
                    'Conda can be installed by Anaconda, Miniconda or MiniForge\n' ...
                    'Would you like to manually select the Anaconda/MiniConda/MiniForge folder?\n'];
        switch os
            case {'mac', 'linux'}
                question = [question 'You may find the location of the conda folder by opening the terminal and typing "which conda" <enter>\n'];
            case 'win'
                question = [question 'You may find the location of the conda folder by opening the terminal and typing "where.exe conda" <enter>\n'];
        end
        question=[question 'Pressing "No" will abort the installation procedure'];

        answer = questdlg(sprintf(question),'Conda not found.', 'Yes','No', 'No');
        if ~strcmp(answer,'Yes')
            isPath=false; path=NaN;
            fprintf('Aborting installation...\n');
            return
        end
        path = uigetdir('','Please select conda folder');

        isPath=isfolder(path);
    end

    function updateDarea()
        [~,r] = system('git remote -v');

        if contains(r, GIT_REPOSITORY)
            !git stash
            !git pull origin master
            for f = 1:numel(usermodified_files)
                system(['git checkout stash@{0} -- ' usermodified_files{f}]);
            end
            fprintf('Updated Darea.\n')
        elseif contains(r, 'fatal: not a git repository')
            fprintf(['Darea was not installed using this script and can thus not be updated automatically.\n' ...
                    'Please copy this script to an empty folder and run it there to install Darea in a way ' ...
                    'that supports automatic updating\n']);
        elseif contains(r, 'is not recognized as an internal or external command\n')
            fprintf('Git is not installed. Please install git, restart MATLAB then run this script again\n')
        else
            fprintf('Unknown github repository, could not update\n');
        end
    end

    function success=checkPrerequisites()
        fprintf('Looking for git...\n');
        [a,~] = system('git --version');
        if a~=0
            fprintf('Git could not be found. Please make sure git is installed! Aborting...\n');
            success=false;
            return
        end
        fprintf('Found Git!\n');
        fprintf('Looking for conda...\n');
        if ismac
            os='mac';
            anaconda_path=ANACONDA_PATH_MAC;
        elseif isunix
            os='linux';
            %On linux conda command should work out of the box without
            %setting path
        elseif ispc
            anaconda_path=ANACONDA_PATH_WIN;
            os='win';
        else
            fprintf('Operating system unknown. Cannot install Darea.\n');
            success=false;
            return
        end
        if ~strcmp(os, 'linux')  %Not necessary for linux
            for p = 1:numel(anaconda_path)
                if isCondaPath(anaconda_path{p},os)
                    anaconda_path=anaconda_path{p};
                    break;
                end
            end
            if iscell(anaconda_path) % No valid path was found during for loop
                [isPath, anaconda_path]=userGetAnacondaPath(os);
                if ~isPath
                    success=false;
                    return
                end
            end
        end

        switch os
            case 'mac'
                setenv('PATH', [getenv('PATH') ':' fullfile(anaconda_path,'condabin')])
            case 'win'
                p = getenv('PATH');
                p = strsplit(p, ';');
                addToPath = {
                   anaconda_path
                   fullfile(anaconda_path, 'Library', 'mingw-w64', 'bin')
                   fullfile(anaconda_path, 'Library', 'usr', 'bin')
                   fullfile(anaconda_path, 'Library', 'bin')
                   fullfile(anaconda_path, 'Scripts')
                   fullfile(anaconda_path, 'bin')
                };
                p = [addToPath(:); p(:)];
                p = unique(p, 'stable');
                p = strjoin(p, ';');
                setenv('PATH', p);
        end

        [a, ~]=system('conda --version');
        if a~=0
            fprintf('Installation failed as Conda was not available.\n');
            success=false;
            return
        end
        fprintf('Found Conda!\n')
        success=true;
    end
    
    function success=downloadDarea()
        fprintf('Downloading Darea...\n');
        [s,r]=system(['git clone ' GIT_REPOSITORY]);
        if s~=0
            if contains(r, 'is not recognized as an internal or external command\n')
                fprintf('Git is not installed. Please install git, restart MATLAB and try again\n')
                success=false;
                return
            else
                fprintf('The following error occured when trying to Download Darea:\n%s\n',r);
                success=false;
                return
            end
        end
        movefile('Darea/*', './');
        if isfile('Darea/.gitignore')
            % On MacOS, movefile doesn't move hidden files unless explicitly asked
            movefile('Darea/.g*', './')
        end
        rmdir('Darea');
        fprintf('Successfully downloaded Darea!\n');
        success=true;
    end

    function [success,darea_env]=installPythonDependencies()
        fprintf('Trying to install dependencies...\n'); 
        [~, r]=system('conda env list');        
        r=split(r);
        index = find(cellfun(@(x)isequal(x,ENVIRONMENT_NAME), r));
        if isempty(index)
            fprintf('Preparing conda environment "%s" ...\n', ENVIRONMENT_NAME)
            fprintf('Checking for existing CUDA installation...\n')
            [a,~] = system('nvcc --version');
            if a==0
                fprintf('CUDA found, installing python packages with GPU support (this may take a while)...\n');
                command1=['conda create -y -n ' ENVIRONMENT_NAME ' python=3.9 pip cython cudnn'];
            else
                command1=['conda create -y -n ' ENVIRONMENT_NAME ' python=3.9 pip cython'];
                fprintf('CUDA was not found, installing python packages with CPU support only (this may take a while)...\n');
            end

            [a,r] = system(command1,'-echo');
            if a~=0
                fprintf('A problem occured during installation of required python packages by conda:\n');
                fprintf(r);
                fprintf('\n\nNeccessary packages were not installed.\n');
                success=false;
                return
            end
            [~, r]=system('conda env list');        
            r=split(r);
            index = find(cellfun(@(x)isequal(x,ENVIRONMENT_NAME), r));

            if isempty(index)
                fprintf('An unknown issue occured. Python packages seemingly were installed correctly, but Darea conda environment was not found.\n');
                success=false;
                return
            end
            
            darea_env=r{index+1};
            if ispc     %windows
                pip_path=replace(fullfile(darea_env, 'Scripts/pip.exe'),'\','/');
            else
                pip_path=fullfile(darea_env, 'bin/pip');
            end
            
            [a,r] = system([pip_path ' install -r requirements.txt --progress-bar off'], '-echo');
            if a~=0
                fprintf('A problem occured during installation of required python packages by pip:\n');
                fprintf(r);
                fprintf('\n\nNeccessary packages were not installed\n');
                success=false;
                return
            end

            fprintf('Successfully installed python packages\n');

        elseif isfolder(r{index+1})
            fprintf('Found existing Darea environment.\n');
            darea_env=r{index+1};
        else
            fprintf('Unknown problem occured. Darea environment should exist but the according path was not found');
            success=false;
            return
        end
        success=true;
    end

    function success=linkPythonToMatlab(darea_env)
        fprintf('Linking python environment to matlab...\n');
        if ispc     %windows
            darea_env=replace(fullfile(darea_env, 'python.exe'),'\','/');
        else
            darea_env=fullfile(darea_env, 'bin/python');
        end
        [~, exec, isLoaded]=pyversion();
        if strcmp(replace(exec,'\','/'),darea_env)
            fprintf('Python environment was already linked.\n Installation was successful!\');
        elseif isLoaded
            fprintf('Python environment could not be linked, because python was already loaded in matlab\n');
            fprintf('Please restart Matlab, then run InstallOrUpdateDarea again to complete the installation\n');
            success=false;
            return
        else
            pyversion(darea_env);
            [~, exec, ~]=pyversion();
            if ~strcmp(replace(exec,'\','/'),darea_env)
                fprintf('Unknown Error: python environment could not be linked to matlab.\n')
                success=false;
                return
            end
        end
        success=true;
    end

    function writeInstallNote(note)
        f=fopen(install_note_file, 'w');
        fprintf(f, note);
        fclose(f);
    end

if isfile('Run.m') && ~isfile(install_note_file)
    %already installed properly, update
    
    updateDarea();
else
    success=checkPrerequisites();
    if ~success; return; end
    
    if ~isfile('Run.m')
        %New Installation in empty folder
        success=downloadDarea();
        if ~success; return; end
        note='';
    else
        %Installation was attempted before but failed
        %Read install_note.txt to see what went wrong
        fid=fopen(install_note_file,'r');
        note = strip(fgets(fid));
        fclose(fid);
        delete(install_note_file);
        
        fprintf('Installation has not been completed successfully the last time this script ran\n')
        fprintf('Darea will now first be updated, then completion of the installation will be attempted.\n');
        %updateDarea();
    end
    
    if ~strcmp(note, 'test') && ~strcmp(note, 'link')
        [success, darea_env]=installPythonDependencies();
        if ~success
            writeInstallNote('Install');
            return
        end
    elseif strcmp(note, 'link')
        [~, r]=system('conda env list');        
        r=split(r);
        index = find(cellfun(@(x)isequal(x,ENVIRONMENT_NAME), r));
        if isempty(index)
            %Darea environment is not there, install it
            [success, darea_env]=installPythonDependencies();
            if ~success
                writeInstallNote('Install');
                return
            end
        else
            darea_env=r{index+1};
        end
    end
    
    if ~strcmp(note, 'test')
        success=linkPythonToMatlab(darea_env);
        if ~success
            writeInstallNote('link');
            return; 
        end
    end
    addpath('./util/');
    try
        success=testInstallation();
    catch e
        writeInstallNote('test');
        rethrow(e);
    end
    if ~success
        writeInstallNote('test');
        return
    end

        
end
end
