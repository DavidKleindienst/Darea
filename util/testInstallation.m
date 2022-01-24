function success=testInstallation()
    fprintf('Testing installation...\n');
    addpath('./Menus/');
    setPath();
    test=py.manyUtils.all_packages_available();
    retVal = py.manyUtils.test_tensorflow_installation();
    retVal = cell(retVal);  %retval is returned as python tuple, convert to cell
    cpu=retVal{1}; gpu=retVal{2};
    if  ~test || ~cpu
        fprintf('A problem was found during the test. The python environment was not installed correctly.\n');
        success=false; c
    elseif ~gpu
        fprintf('Darea was successfully installed without GPU support!\n');
        fprintf('All deep-learning computations will be performed on the CPU (slow),\n')
        fprintf('because either no appropriate graphic card is available, or CUDA was not installed.\n')
        success=true; 
    else
        fprintf('Darea was sucessfully installed with GPU support\n');
        success=true; 
    end
end