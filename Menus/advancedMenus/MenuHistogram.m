
function Options=MenuHistogram(Default)
% Opens advanced option menu for simulations
   positionMenu=[225 250 650 500];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Histogram Options', 'resize', 'Off', 'menubar', 'None', 'CloseRequestFcn', @close);
   hMakePlotsText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Make Histograms for:', 'Position', [25 430 100 25]);
   hMakeNNDAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'NNDs', 'Value', Default.makeNND, 'Position', [50 410 50 25], 'Tooltipstring', 'Check if Histograms of Nearest Neighbour Distances should be generated');
   hMakeAllDistAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'All Distances', 'Value', Default.makeAllDist, 'Position', [105 410 100 25], 'Tooltipstring', 'Check if Histogramms for all Distances should be generated');
   hMakeClusterAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'Cluster Parameters', 'Value', Default.makeCluster, 'Position', [210 410 125 25], 'Tooltipstring', 'Check if Histograms of Cluster parameters should be generated');

   hNormalizationText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Normalization', 'Position', [440 405 90 25], 'Tooltipstring', sprintf('Chose Type of normalization.\nCount=Absolute number of observation\nProbability=Probability of observation (i.e. sum of all bar heights=1)'));
   hNormalizationPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'String', {'Counts', 'Probability'}, 'Callback', @choseNormalization, 'Position', [530 405 100 25], 'Tooltipstring', sprintf('Chose Type of normalization.\nCount=Absolute number of observation\nProbability=Probability of observation (i.e. sum of all bar heights=1)'));
   set(hNormalizationpopup, 'Value', find(~cellfun('isempty', strfind(get(hNormalizationpopup,'String'),Default.Normalization))));
   
   hOrientationText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Orientation', 'Position', [440 365 90 25], 'Tooltipstring', sprintf('Choose whether histogram bars should be vertical or horizontal.'));
   hOrientationPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'String', {'Vertical', 'Horizontal'}, 'Callback', @choseOrientation, 'Position', [530 370 100 25], 'Tooltipstring', sprintf('Choose whether histogram bars should be vertical or horizontal.'));
   if isfield(Default, 'Orientation')
      set(hOrientationPopup, 'Value', find(~cellfun('isempty', strfind(get(hOrientationPopup,'String'), Default.Orientation))));
   end
   
   hFaceColorText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Face Color', 'Position', [25 370 85 25], 'Tooltipstring', 'Choose color of the bars making up the histogram');
   hFaceColorButton=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'BackgroundColor', Default.FaceColor, 'Position', [105 380 25 15], 'Callback', @(hObj, ~)selectColor(hObj, 'face'), 'Tooltipstring', 'Choose color of the bars making up the histogram');
   hEdgeColorText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Edge Color', 'Position', [150 370 85 25], 'Tooltipstring', 'Choose color of the edges of the bars');
   hEdgeColorButton=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'BackgroundColor', Default.EdgeColor, 'Position', [230 380 25 15], 'Callback', @(hObj, ~)selectColor(hObj, 'edge'), 'Tooltipstring', 'Choose color of the edges of the bars');
   hLineWidthText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Edge Width', 'Position', [265 370 85 25], 'Tooltipstring', 'Choose line width for the edges');
   hLineWidthEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', 'auto', 'Position', [350 377 30 21], 'Tooltipstring', 'Choose line width for the edges', 'Callback', @lineWidth);
   if isfield(Default, 'LineWidth')
       set(hLineWidthEdit, 'String', num2str(Default.LineWidth));
   end
   hLineWidthError=uicontrol('Parent', Menu, 'Style', 'Text', 'Visible', 'off', 'String', 'Only numbers are valid input', 'Position', [270 395 120 25], 'ForegroundColor', 'red', 'FontWeight', 'bold');
  
   hFaceOpacityText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Face Opacity', 'Position', [25 340 95 25], 'Tooltipstring', 'Choose Opacity of the bars (0=Invisible, 1=Opaque)');
   hFaceSliderLabel=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', num2str(Default.FaceAlpha), 'Position', [140 325 30 20]);
   hFaceOpacitySlider=uicontrol('Parent', Menu, 'Style', 'slider', 'Min', 0, 'Max', 1, 'Value', Default.FaceAlpha, 'Position', [115 340 75 25], 'Callback', @(hObj, ~)selectOpacity(hObj, 'face', hFaceSliderLabel), 'Tooltipstring', 'Choose Opacity of the bars (0=Invisible, 1=Opaque)');
   set(hFaceSliderLabel, 'Callback', @(hObj, ~)enterOpacity(hObj, 'face', hFaceOpacitySlider));
   hFaceOpacityError=uicontrol('Parent', Menu, 'Style', 'Text', 'Visible', 'off', 'ForegroundColor', 'red', 'Position', [25 320 100 25], 'FontWeight', 'bold');
   
   hEdgeOpacityText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Edge Opacity', 'Position', [215 340 95 25], 'Tooltipstring', 'Choose Opacity of the edges (0=Invisible, 1=Opaque)');
   hEdgeSliderLabel=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', num2str(Default.EdgeAlpha), 'Position', [330 325 30 20]);
   hEdgeOpacitySlider=uicontrol('Parent', Menu, 'Style', 'slider', 'Min', 0, 'Max', 1, 'Value', Default.EdgeAlpha, 'Position', [305 340 75 25], 'Callback', @(hObj, ~)selectOpacity(hObj, 'edge', hEdgeSliderLabel), 'Tooltipstring', 'Choose Opacity of the edges (0=Invisible, 1=Opaque)');
   set(hEdgeSliderLabel, 'Callback', @(hObj, ~)enterOpacity(hObj, 'edge', hEdgeOpacitySlider));
   hEdgeOpacityError=uicontrol('Parent', Menu, 'Style', 'Text', 'Visible', 'off', 'ForegroundColor', 'red', 'Position', [215 320 100 25], 'FontWeight', 'bold');

   
   hFontSelection=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'Position', [25 265 100 25], 'String', 'Select Font', 'Callback', @selectFont, 'Tooltipstring', 'Select the font which will be used in the figures');
   hFontExample=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [129 235 100 50], 'HorizontalAlignment', 'left', 'String', 'Example', 'Tooltipstring', 'Example Text showing how the chosen Font looks.');
   if isfield(Default, 'FontSize')
       set(hFontExample, 'FontSize', Default.FontSize, 'FontName', Default.FontName, 'FontAngle', Default.FontAngle, 'FontWeight', Default.FontWeight, 'FontUnits', Default.FontUnits);
   end
   
   hTitleFontText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [200 260 130 25], 'String', 'Title fontsize multiplier', 'Tooltipstring', 'The fontsize of the title is regular font size*this value.');
   hTitleFontEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [330 267 30 21], 'String', 'auto', 'Tooltipstring', 'The fontsize of the title is regular font size*this value.', 'Callback', @titleFont);
   if isfield(Default, 'TitleFontSizeMultiplier')
       set(hTitleFontEdit, 'String', num2str(Default.TitleFontSizeMultiplier));
   end
   hTitleFontError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [200 235 100 35], 'FontWeight', 'bold', 'ForegroundColor', 'red', 'String', 'Please choose a valid input', 'Visible', 'off');
   bintooltip=sprintf('Choose algorithm by which bin width and number is determined.\nAuto: Bin width covers data range and reveals shape of distribution.\nCustom: Choose bin width in nm\nScott:Ideal for distributions close to normal.\nFreedman: Freedmen-Diaconis rule: Less sensitive to outliers. Good for heavy-tailed distributions\nIntegers: Creates a bin for each integer. Should be great for Particle number or Cluster number.\nSturges: Sturges rule: Number of bins=1+Log2(numel(X).\nSqrt: number of bins=SQRT(NUMEL(X)).');
   hBinsText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Bin algorithm', 'Position', [395 290 65 25], 'Tooltipstring', bintooltip);
   hBinsPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [460 290 130 25], 'Callback', @binAlgorithm, 'Tooltipstring', bintooltip, 'String', {'Auto', 'Custom', 'Scott', 'Freedman', 'Integers', 'Sturges', 'Sqrt'});
   hBinsWidthText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Bin width', 'Position', [395 260 65 25], 'Tooltipstring', 'Choose bin width in nm', 'Visible', 'off');
   hBinsWidthEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', 'auto', 'Position', [460 267 30 21], 'Callback', @binWidth, 'Tooltipstring', 'Choose bin width in nm', 'Visible', 'off');
   hBinWidthError=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Invalid Input', 'Position', [490 265 60 25], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'Visible', 'off');
   if isfield(Default, 'binWidth')
       if strcmp(Default.binWidth, 'auto')
           set(hBinsPopup, 'Value', 1);
       else
           set(hBinsPopup, 'Value', 2);
           set(hBinsWidthText, 'Visible', 'on');
           set(hBinsWidthEdit, 'String', num2str(Default.binWidth), 'Visible', 'on');
       end  
   elseif isfield(Default, 'binAlgorithm')
       switch Default.binAlgorithm
           case 'auto'
               set(hBinsPopup, 'Value', 1);
           case 'scott'
               set(hBinsPopup, 'Value', 3);
           case 'fd'
               set(hBinsPopup, 'Value', 4);
           case 'integers'
               set(hBinsPopup, 'Value', 5);
           case 'sturges'
               set(hBinsPopup, 'Value', 6);
           case 'sqrt'
               set(hBinsPopup, 'Value', 7);
       end
   end
   %X-Axis parameters
   hXAxisText=uicontrol('Parent', Menu, 'FontWeight', 'bold', 'Style', 'Text', 'String', 'X-Axis settings:', 'Position', [15 220 100 25]);
   hXMinText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'From', 'Position', [35 200 30 25], 'Tooltipstring', 'Lower limit of x-Axis');
   hXLimEdit=cell(2,1);
   hXLimEdit{1}=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [65 207 30 21], 'Tooltipstring', 'Lower limit of x-Axis. Automatically determined if left empty', 'Callback', @(~, ~)limitCheck(1, 'x'));
   hXMaxText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'to', 'Position', [95 200 30 25], 'Tooltipstring', 'Upper limit of x-Axis');
   hXLimEdit{2}=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [120 207 30 21], 'Tooltipstring', 'Upper limit of x-Axis. Automatically determined if left empty', 'Callback', @(~, ~)limitCheck(2, 'x'));
   if isfield(Default, 'XLim')
       set(hXLimEdit{1}, 'String', num2str(Default.XLim(1)));
       set(hXLimEdit{2}, 'String', num2str(Default.XLim(2)));
   else
       set(hXLimEdit{1}, 'String', 'auto');
       set(hXLimEdit{2}, 'String', 'auto');
   end
   hXLimError=uicontrol('Parent', Menu, 'Style', 'Text', 'Visible', 'Off', 'Position', [35 180 140 25], 'ForegroundColor', 'red', 'FontWeight', 'bold');
   
   hXTickText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [170 200 45 25], 'String', 'Ticks', 'Tooltipstring', 'Specifies where on the x-Axis the ticks are located.');
   hXTickEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [210 207 100 21], 'String', 'auto', 'Tooltipstring', sprintf('Please specify the values seperated by ; in ascending order\nE.g. "2.5;5;7.5;10"'), 'Callback', @(hObject, ~)getTicks(hObject, 'x'));
   hXTickError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [155 180 160 25], 'Visible', 'Off', 'ForegroundColor', 'red', 'FontWeight', 'bold');
   if isfield(Default, 'XTick')
       string='';
       for i=1:numel(Default.XTick)
           string=[string num2str(Default.XTick(i))];
           if i~=numel(Default.XTick)
               string=[string ';'];
           end
       end
       set(hXTickEdit, 'String', string);  
   end
   hXMinor=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'Position', [335 205 130 25], 'String', 'Display minor ticks', 'Tooltipstring', 'Displays smaller ticks between the ticks specified', 'Callback', @(hObject, ~)minorTick(hObject,'x'));
   if isfield(Default, 'XMinorTick')
        set(hXMinor, 'Value', 1);
   end
   hXLabelText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [460 200 50 25], 'String', 'Label');
   hXLabelEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [510 207 130 25], 'String', Default.xlabeling);
   
   
   
   %Y-Axis Parameters
   hYAxisText=uicontrol('Parent', Menu, 'FontWeight', 'bold', 'Style', 'Text', 'String', 'Y-Axis settings:', 'Position', [15 160 100 25]);
   hYMinText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'From', 'Position', [35 140 30 25], 'Tooltipstring', 'Lower limit of y-Axis');
   hYLimEdit=cell(2,1);
   hYLimEdit{1}=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [65 147 30 21], 'Tooltipstring', 'Lower limit of y-Axis. Automatically determined if left empty', 'Callback', @(~, ~)limitCheck(1, 'y'));
   hYMaxText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'to', 'Position', [95 140 30 25], 'Tooltipstring', 'Upper limit of y-Axis');
   hYLimEdit{2}=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [120 147 30 21], 'Tooltipstring', 'Upper limit of y-Axis. Automatically determined if left empty', 'Callback', @(~, ~)limitCheck(2, 'y'));
   if isfield(Default, 'YLim')
       set(hYLimEdit{1}, 'String', num2str(Default.YLim(1)));
       set(hYLimEdit{2}, 'String', num2str(Default.YLim(2)));
   else
       set(hYLimEdit{1}, 'String', 'auto');
       set(hYLimEdit{2}, 'String', 'auto');
   end
   hYLimError=uicontrol('Parent', Menu, 'Style', 'Text', 'Visible', 'Off', 'Position', [35 120 140 25], 'ForegroundColor', 'red', 'FontWeight', 'bold');

   hYTickText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [170 140 45 25], 'String', 'Ticks', 'Tooltipstring', 'Specifies where on the y-Axis the ticks are located.');
   hYTickEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [210 147 100 21], 'String', 'auto', 'Tooltipstring', sprintf('Please specify the values seperated by ; in ascending order\nE.g. "2.5;5;7.5;10"'), 'Callback', @(hObject, ~)getTicks(hObject, 'y'));
   hYTickError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [155 120 160 25], 'Visible', 'Off', 'ForegroundColor', 'red', 'FontWeight', 'bold');
   if isfield(Default, 'YTick')
       string='';
       for i=1:numel(Default.YTick)
           string=[string num2str(Default.YTick(i))];
           if i~=numel(Default.YTick)
               string=[string ';'];
           end
       end
       set(hYTickEdit, 'String', string);  
   end
   hYMinor=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'Position', [335 145 130 25], 'String', 'Display minor ticks', 'Tooltipstring', 'Displays smaller ticks between the ticks specified', 'Callback', @(hObject, ~)minorTick(hObject,'y'));
   if isfield(Default, 'YMinorTick')
        set(hYMinor, 'Value', 1);
   end
   
   hYLabelText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [460 140 50 25], 'String', 'Label');
   hYLabelEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [510 147 130 21], 'String', Default.ylabeling);
   
   xlabeltooltip=sprintf('Choose label of the axis with the NNDs\nHas no effect on plots for Cluster parameters.\nFor choosing these labels, use the "Choose Cluster Parameter names" button');
   ylabeltooltip='Choose label of the axis along which Counts or probability are drawn';
   if strcmp(Default.Orientation, 'vertical')
       set(hXLabelText, 'Tooltipstring', xlabeltooltip);
       set(hXLabelEdit, 'Tooltipstring', xlabeltooltip);
       set(hYLabelText, 'Tooltipstring', ylabeltooltip);
       set(hYLabelEdit, 'Tooltipstring', ylabeltooltip);
   else
       set(hXLabelText, 'Tooltipstring', ylabeltooltip);
       set(hXLabelEdit, 'Tooltipstring', ylabeltooltip);
       set(hYLabelText, 'Tooltipstring', xlabeltooltip);
       set(hYLabelEdit, 'Tooltipstring', xlabeltooltip);
   end
   
   
   %%%
   
   hBox=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'Position', [35 100 85 25], 'String', 'Display Box', 'Tooltipstring', 'Displays a box around the plot', 'Callback', @choseBox);
   if strcmp(Default.Box, 'on')
       set(hBox, 'Value', 1);
   end
   hAxisLWText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [125 90 90 25], 'String', 'Axis Line Width', 'Tooltipstring', 'Choose thickness of the Axis (and some other lines)');
   hAxisLWEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [215, 97 30 21], 'String', 'auto', 'Callback', @axisLW, 'Tooltipstring', 'Choose thickness of the Axis (and some other lines)');
   if isfield(Default, 'AxisLineWidth')
       set(hAxisLWEdit, 'String', numwstr(Default.AxisLineWidth));
   end
   hAxisLWError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [125 75 120 25], 'String', 'Only numbers, auto and empty is allowed', 'ForegroundColor', 'red', 'Fontweight', 'bold', 'Visible', 'off');
   
   
   
   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
   hErrorPresent=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [175 50 265 15], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'String', 'Cannot continue because Errors are present', 'Visible', 'Off');

   Options=Default;

   % Waits for the figure to close to end the function.
    waitfor(Menu);
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Functions
   
    function selectColor(hObj, ident)
        if strcmp(ident, 'face')
            Options.FaceColor=uisetcolor(get(hObj, 'BackgroundColor'));
            set(hObj, 'BackgroundColor', Options.FaceColor);
        else
            Options.EdgeColor=uisetcolor(get(hObj, 'BackgroundColor'));
            set(hObj, 'BackgroundColor', Options.EdgeColor);
        end
    end
    function lineWidth(hObj, ~)
        set(hLineWidthError, 'Visible', 'off');
        string=get(hObj, 'String');
        if strcmp(string, 'auto') || strcmp(string, 'Auto') || strcmp(string, 'AUTO') || isempty(string) || strcmp(string, ' ')
            if isfield(Options, 'LineWidth')
                Options=rmfield(Options, 'LineWidth');
            end
        elseif isempty(str2double(string))
            set(hLineWidthError, 'Visible', 'on');  
        else
            Options.LineWidth=str2double(string);
        end
    end
    function choseNormalization(hObj, ~) 
       switch get(hObj, 'Value')
           case 1
               Options.Normalization='count';
               %If the Default axis names are kept, change the correct axis name to Counts
               if strcmp(Options.Orientation, 'vertical') && strcmp(get(hYLabelEdit, 'String'), 'Probability')
                   set(hYLabelEdit, 'String', 'Counts');
               elseif strcmp(Options.Orientation, 'horizontal') && strcmp(get(hXLabelEdit, 'String'), 'Probability')
                   set(hXLabelEdit, 'String', 'Counts');
               end
           case 2
               Options.Normalization='probability';
               %If the Default axis names are kept, change the correct axis name to Probability
               if strcmp(Options.Orientation, 'vertical') && strcmp(get(hYLabelEdit, 'String'), 'Counts')
                   set(hYLabelEdit, 'String', 'Probability');
               elseif strcmp(Options.Orientation, 'horizontal') && strcmp(get(hXLabelEdit, 'String'), 'Counts')
                   set(hXLabelEdit, 'String', 'Probability');
               end
       end
    end
    function choseOrientation(hObj, ~)
       switch get(hObj, 'Value')
           case 1
               if strcmp(Options.Orientation, 'horizontal')     %if it was different before, switch axis label names
                   l=get(hXLabelEdit, 'String');
                   set(hXLabelEdit, 'String', get(hYLabelEdit, 'String'));
                   set(hYLabelEdit, 'String', l);
               end
               
               Options.Orientation='vertical';
               set(hXLabelText, 'Tooltipstring', xlabeltooltip);
               set(hXLabelEdit, 'Tooltipstring', xlabeltooltip);        %Switch axis label tooltips appropriately 
               set(hYLabelText, 'Tooltipstring', ylabeltooltip);        
               set(hYLabelEdit, 'Tooltipstring', ylabeltooltip);
               
           case 2
               if strcmp(Options.Orientation, 'vertical')
                   l=get(hXLabelEdit, 'String');
                   set(hXLabelEdit, 'String', get(hYLabelEdit, 'String'));
                   set(hYLabelEdit, 'String', l);
               end
               
               Options.Orientation='horizontal';
               set(hXLabelText, 'Tooltipstring', ylabeltooltip);
               set(hXLabelEdit, 'Tooltipstring', ylabeltooltip);
               set(hYLabelText, 'Tooltipstring', xlabeltooltip);
               set(hYLabelEdit, 'Tooltipstring', xlabeltooltip);
       end
    end
    function selectOpacity(hObj, ident, hLabel)
       val=get(hObj, 'Value');
       set(hLabel, 'String', num2str(val));
       if strcmp(ident, 'face')
           Options.FaceAlpha=val;
       else
           Options.EdgeAlpha=val;
       end
    end
    function enterOpacity(hObj, ident, hSlider)
        val=str2double(get(hObj, 'String'));
        if strcmp(ident, 'face')
            Error=hFaceOpacityError;
        else
            Error=hEdgeOpacityError;
        end
        if isempty(val)
            set(Error, 'Visible', 'on', 'String', 'Only numbers are valid input');
        elseif val<0 || val>1
            set(Error, 'Visible', 'on', 'String', 'Use only values between 0 and 1!');
        else
            set(hSlider, 'Value', val);
            set(Error, 'Visible', 'off');
            if strcmp(ident, 'face')
                Options.FaceAlpha=val;
            else
                Options.EdgeAlpha=val;
            end
        end
    end

    function titleFont(hObject, ~)
        set(hTitleFontError, 'Visible', 'Off');
        string=get(hObject,'String');
        string=strrep(string, ' ', '');
        if isempty(string) || strcmp(string, '') || strcmp(string, 'auto') || strcmp(string, 'Auto') || strcmp(string, 'AUTO')
            if isfield(Options, 'TitleFontSizeMultiplier')
                Options=rmfield(Options, 'TitleFontSizeMultiplier');
            end
        elseif isempty(str2double(string))
            set(hTitleFontError, 'Visible', 'On');
        else
            Options.TitleFontSizeMultiplier=str2double(string);
        end
    end
    function binWidth(~,~)
        string=get(hBinsWidthEdit, 'String');
        string=strrep(string, ' ', '');
        if isempty(string) || strcmp(string, '') || strcmp(string, 'auto') || strcmp(string, 'Auto') || strcmp(string, 'AUTO')
            Options.binWidth='auto';
        elseif isempty(str2double(string))
            set(hBinWidthError, 'Visible', 'on');
        else
            Options.binWidth=str2double(string);
        end    

    end
    function binAlgorithm(hObj, ~)
        switch get(hObj, 'Value')
            case 1
                Options.binAlgorithm='auto';
            case 2
                if isfield(Options, 'binAlgorithm')
                    Options=rmfield(Options, 'binAlgorithm');
                end
                set(hBinsWidthText, 'Visible', 'on');
                set(hBinsWidthEdit, 'Visible', 'on');
                binWidth();
                
            case 3
                Options.binAlgorithm='scott';
            case 4
                Options.binAlgorithm='fd';
            case 5 
                Options.binAlgorithm='integers';
            case 6 
                Options.binAlgorithm='sturges';
            case 7
                Options.binAlgorithm='sqrt';
        end
        if get(hObj, 'Value')~=2
            set(hBinsWidthText, 'Visible', 'off');
            set(hBinsWidthEdit, 'Visible', 'off');
            set(hBinWidthError, 'Visible', 'off');
            if isfield(Options, 'binWidth')
                Options=rmfield(Options, 'binWidth');
            end
        end
    end

    function axisLW(hObject, ~)
        set(hAxisLWError, 'Visible', 'Off');
        string=get(hObject,'String');
        string=strrep(string, ' ', '');
        if isempty(string) || strcmp(string, '') || strcmp(string, 'auto') || strcmp(string, 'Auto') || strcmp(string, 'AUTO')
            if isfield(Options, 'AxisLineWidth')
                Options=rmfield(Options, 'AxisLineWidth');
            end
        elseif isempty(str2double(string))
            set(hAxisLWError, 'Visible', 'On');
        else
            Options.AxisLineWidth=str2double(string);
        end
     
    end 
    function limitCheck(ident, xy)
        if strcmp(xy, 'x')
            Error=hXLimError;
            hObject=hXLimEdit;
        else
            Error=hYLimError;
            hObject=hYLimEdit;
        end
        set(Error, 'Visible', 'off');

        if ident==1
            other=2;
        else 
            other=1;
        end
        thisstring=get(hObject{ident}, 'String');
        otherstring=get(hObject{other}, 'String');
        if strcmp(thisstring, 'auto') || strcmp(thisstring, 'Auto') || strcmp(thisstring, 'AUTO') || isempty(thisstring) || strcmp(thisstring, ' ')
            if strcmp(otherstring, 'auto') || strcmp(otherstring, 'Auto') || strcmp(otherstring, 'AUTO') || isempty(otherstring) || strcmp(otherstring, ' ')
                if strcmp(xy, 'x') && isfield(Options, 'XLim')
                    Options=rmfield(Options, 'XLim');
                elseif strcmp(xy, 'y') && isfield(Options, 'YLim')
                    Options=rmfield(Options, 'YLim');
                end
            else
                set(Error, 'Visible', 'On', 'String', 'Both fields must be empty or contain numbers');
            end
        elseif isempty(str2double(thisstring))
            set(Error, 'Visible', 'on', 'String', 'Only numbers, auto and empty is allowed');
        elseif strcmp(otherstring, 'auto') || strcmp(otherstring, 'Auto') || strcmp(otherstring, 'AUTO') || isempty(otherstring) || strcmp(otherstring, ' ')
            set(Error, 'Visible', 'on', 'String', 'Both fields must be empty or contain numbers');
        elseif isempty(str2double(otherstring))
            set(Error, 'Visible', 'on', 'String', 'Only numbers, auto and empty is allowed');
        else
            if str2double(get(hObject{1}, 'String'))<str2double(get(hObject{2}, 'String'))
                if strcmp(xy, 'x')
                    Options.XLim=[str2double(get(hObject{1}, 'String')), str2double(get(hObject{2}, 'String'))];
                else
                    Options.YLim=[str2double(get(hObject{1}, 'String')), str2double(get(hObject{2}, 'String'))];
                end
            else
                set(Error, 'Visible', 'on', 'String', 'Left number must be smaller than right');
            end
        end
    end
    function getTicks(hObject, xy)
        if strcmp(xy, 'x')
            Error=hXTickError;
        else
            Error=hYTickError;
        end
        set(Error, 'Visible', 'Off');
        string=strrep(get(hObject, 'String'), ' ', '');     %Remove spaces
        
        if isempty(string) || strcmp(string, '') || strcmp(string, 'auto') || strcmp(string, 'Auto') || strcmp(string, 'AUTO')
            if strcmp(xy,'x') && isfield(Options, 'XTick')  %If theres no input or input is auto
                Options=rmfield(Options, 'XTick');          %remove corresponding field
            elseif strcmp(xy,'y') && isfield(Options, 'YTick')
                Options=rmfield(Options, 'YTick');
            end
            return
        end
        if strcmp(string(end), ';')
            string=string(1:end-1);     %Remove last character if it is a ;
        end
        list=strsplit(string, ';');
        try
            list=cellfun(@str2double,list);            %Try to convert to numbers, if other characters are present
        catch                                       %show error.
            set(Error, 'Visible', 'On', 'String', 'Invalid Input');
            return
        end
        logicals=[];
        for i=2:numel(list)
            logicals=[logicals, list(i)<=list(i-1)];        %Test if order of numbers is ascending
        end
        if any(logicals)                                    %If not, show error
            set(Error, 'Visible', 'On', 'String', 'The numbers must be in ascending order');
        else
            if strcmp(xy, 'x')
                Options.XTick=list;
            else
                Options.YTick=list;
            end

        end
        
        
    end
    function minorTick(hObject, xy)
        if get(hObject, 'Value')==1
            if strcmp(xy, 'x')
                Options.XMinorTick='on';
            else
                Options.YMinorTick='on';
            end
        else
            if strcmp(xy, 'x')
                Options=rmfield(Options, 'XMinorTick');
            else
                Options=rmfield(Options, 'YMinorTick');
            end
        end
    end


    function selectFont(~,~)
       if isfield(Options, 'FontSize') || isfield(Options, 'FontName') || isfield(Options, 'FontWeight') || isfield(Options, 'FontAngle') || isfield(Options, 'FontUnits')
           fonts=uisetfont(Options);
       else
           fonts=uisetfont();
       end
       if isstruct(fonts)
           Options.FontName=fonts.FontName;
           Options.FontWeight=fonts.FontWeight;
           Options.FontAngle=fonts.FontAngle;
           Options.FontUnits=fonts.FontUnits;
           Options.FontSize=fonts.FontSize;
           set(hFontExample, 'FontSize', Options.FontSize, 'FontName', Options.FontName, 'FontAngle', Options.FontAngle, 'FontWeight', Options.FontWeight, 'FontUnits', Options.FontUnits);

       end
    end
   
    function choseBox(hObject, ~)
       switch get(hObject, 'Value')
           case 0
               Options.Box='off';
           case 1
               Options.Box='on';
       end
    end



    function logical=anyError()
        if strcmp(get(hLineWidthError, 'Visible'), 'on') || strcmp(get(hEdgeOpacityError, 'Visible'), 'on') || strcmp(get(hFaceOpacityError, 'Visible'), 'on') ...
                || strcmp(get(hXLimError, 'Visible'), 'on') || strcmp(get(hYLimError, 'Visible'), 'on') || strcmp(get(hXTickError, 'Visible'), 'on') ...
                || strcmp(get(hYTickError, 'Visible'), 'on') || strcmp(get(hTitleFontError, 'Visible'), 'on') || strcmp(get(hAxisLWError, 'Visible'), 'on')
            logical=1;
        else
            logical=0;
        end  
    end
    
    function close(~,~)
        Options=Default;
        delete(gcf)  
    end
    function updateOptions(~,~)
        if anyError()
            set(hErrorPresent, 'Visible', 'on');
        else  
            Options.makeNND=get(hMakeNNDAnalysis, 'Value');
            Options.makeAllDist=get(hMakeAllDistAnalysis, 'Value');
            Options.makeCluster=get(hMakeClusterAnalysis, 'Value');
            Options.xlabeling=get(hXLabelEdit, 'String');
            Options.ylabeling=get(hYLabelEdit, 'String');
            delete(gcf)
        end
    end
   
end

