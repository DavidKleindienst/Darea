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
        fprintf('All deep learning computations will be performed on the CPU (slow).\n')
        fprintf('This can be either because no appropriate graphics card is available, or CUDA and/or CUDNN have not been installed prior to running this installation.\n')
        success=true; 
    else
        fprintf('Darea was sucessfully installed with GPU support!\n');
        success=true; 
    end
end