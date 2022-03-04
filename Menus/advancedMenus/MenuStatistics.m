
function Options=MenuStatistics(Default, Data, settings)
% Opens advanced option menu for simulations
   Options=Default;
   positionMenu=[225 250 430 450];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Statistics Options', 'menubar', 'None', 'CloseRequestFcn', @close);
   
   hMakeStatsText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Make Statistics for:', 'Position', [25 380 100 25]);
   hMakeNNDAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'NNDs', 'Value', Default.makeNND, 'Position', [35 360 50 25], 'Tooltipstring', 'Check if Statistics for Nearest Neighbour Distances should be generated');
   hMakeAllDistAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'All Distances', 'Value', Default.makeAllDist, 'Position', [90 360 100 25], 'Tooltipstring', 'Check if Statistics for All Distances should be generated');
   hMakeClusterAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'Cluster Parameters', 'Value', Default.makeCluster, 'Position', [180 360 125 25], 'Tooltipstring', 'Check if Statistics for Cluster Parameters should be generated');
   hMakeDescriptive=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'Descriptive Statistics', 'Position', [25 325 120 25], 'Value', Default.makeDescriptive, 'Tooltipstring', 'Check if descriptive Statistics should be generated');
   hMakeAnalytics=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'Analytic Statistics', 'Position', [145 325 120 25], 'Value', Default.makeAnalytics, 'Tooltipstring', 'Check if descriptive Statistics should be generated');

   hMake1by1=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'Image by Image', 'Position', [25 295 120 25], 'Callback', @select1by1, 'Value', Default.make1by1, 'Tooltipstring', sprintf('Check if Image-wise comparison should be performed.\ni.e.: Each image is compared to its simulation, and the percentage of significant p-values are reported'));
   statmTooltip=sprintf('Statistical Measure used for Image by Image Analysis');
   hStatMeasureText=uicontrol('Parent',Menu, 'Style', 'Text', 'String', 'Statistical Measure', 'Position', [150 295 65 25], 'Tooltipstring', statmTooltip);
   hStatMeasure=uicontrol('Parent', Menu, 'Style', 'popup', 'String', {'mean', 'median'}, 'Callback', @selectStatfct, 'Position', [215 295 90 25], 'Tooltipstring', statmTooltip);
   if isequaln(Default.statfct, @mean)
       set(hStatMeasure, 'Value', 1);
   elseif isequaln(Default.statfct, @median)
       set(hStatMeasure, 'Value', 2);
   end
   pvalTooltip=sprintf('P value below which an image will be considered significantly different from chance');
   hpValText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'p-Value', 'Position', [305 295 60 25], 'Tooltipstring', pvalTooltip);
   hpValEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', num2str(Default.pval), 'Position', [365 295 30 25], 'Callback', @selectpVal, 'Tooltipstring', pvalTooltip);
   hpValError=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'p-Value has to between 0 and 1', 'Position', [300 265 85 25], 'Foregroundcolor', 'red', 'FontWeight', 'bold', 'Visible', 'off');
   hPopmeans=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'ImageWise population means', 'Tooltipstring', sprintf('Compare population means to simulation in an Imagewise Manner'), ...
                            'Position', [25 265 165 25], 'Value', Default.ImageWisePopMeans);
   
   visby1by1=[hpValText, hpValEdit, hStatMeasure, hStatMeasureText]; %Fields that should only be visible when 1by1 is selected
   if ~Default.make1by1
        set(visby1by1, 'Visible', 'off');
   end
   
   htSNE=uicontrol('Parent', Menu, 'Style', 'checkbox', 'String', 'Make tSNE plots', 'Position', [25 230 130 25],'Value', Default.maketSNE, ...
            'Tooltipstring', sprintf('Pick if tSNE plots should be generated\n(tSNE is a dimensionality reduction technique useful for showing clusters in the data)'));
   hCorrel=uicontrol('Parent', Menu, 'Style', 'checkbox', 'String', 'Plot correlations', 'Position', [180 230 130 25], 'Value', Default.makeCorrel, ...
            'Tooltipstring', 'Plot correlations between particle number and area');
   hIndivValues=uicontrol('Parent', Menu, 'Style', 'checkbox', 'String', 'Individual Values', 'Position', [25 205 130 25], 'Value', Default.makeIndiv, ...
            'Tooltipstring', 'Show individual values (for each image or particle)');

   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
   hErrorPresent=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [175 50 265 15], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'String', 'Cannot continue because Errors are present', 'Visible', 'Off');

   set(findall(Menu, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

   % Waits for the figure to close to end the function.
    waitfor(Menu);
    
   
    function selectTraces(~,~)
        %% Opens another Menu to select which Data traces will be calculated
        [Options.unwantedGroupTraces, Options.unwantedNNDTraces, Options.unwantedClusterTraces, Options.unwantedSimulationTraces]...
            =MenuTraces({Options.unwantedGroupTraces, Options.unwantedNNDTraces, Options.unwantedClusterTraces, Options.unwantedSimulationTraces}, Data, settings);
    end
    

    function selectStatfct(hObj, ~)
        %% Select which statistical function will be used
        switch get(hObj, 'Value')
            case 1
                Options.statfct=@mean;
            case 2
                Options.statfct=@median;
        end
    end
    function selectpVal(hObj, ~)
        %% Select below which pvalue it should be considered significant
        val=str2double(get(hObj, 'String'));
        if isempty(val) || val<0 || val>1
            set(hpValError, 'Visible', 'on');
        else
            set(hpValError, 'Visible', 'off');
            Options.pval=val;
        end
    end
        
       
    function select1by1(hObj,~)
        %% Select if 1by1 comparison should be carried out
        val=get(hObj, 'Value');
        if val==0
            for v=visby1by1
                set(v, 'Visible', 'off');
            end
            set(hpValError, 'Visible', 'off');
        else
            for v=visby1by1
                set(v, 'Visible', 'on');
            end
            selectpVal(hpValEdit, NaN);
        end
    end
   
    function close(~,~)
        %% Closes the Window, discards changes
        Options=Default;
        delete(Menu)  
    end
    function logical=anyError()
        %% Checks if any Error message is present
        if strcmp(get(hpValError, 'Visible'), 'on')
            logical=1;
        else
            logical=0;
        end
    end
    function updateOptions(~,~)
        %% Saves the new settings and closes the window
        if anyError()   %If any error message is present, don't proceed and show an error
            set(hErrorPresent, 'Visible', 'on'); 
        else
            Options.makeAnalytics=get(hMakeAnalytics, 'Value');
            Options.makeDescriptive=get(hMakeDescriptive, 'Value');
            Options.makeNND=get(hMakeNNDAnalysis, 'Value');
            Options.makeAllDist=get(hMakeAllDistAnalysis, 'Value');
            Options.makeCluster=get(hMakeClusterAnalysis, 'Value');
            Options.make1by1=get(hMake1by1, 'Value');
            Options.ImageWisePopMeans=get(hPopmeans, 'Value');
            Options.maketSNE=htSNE.Value;
            Options.makeIndiv=hIndivValues.Value;
            Options.makeCorrel=hCorrel.Value;
            delete(Menu)
        end
    end
   
end

