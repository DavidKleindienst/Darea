
function Options=MenuCumProb(Default, Data, settings)
% Opens advanced option menu for simulations
   
   positionMenu=[225 250 650 450];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Cumulative Probability Options', 'menubar', 'None', 'CloseRequestFcn', @close);
   
   hMakePlotsText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Make Plots for:', 'Position', [25 380 100 25]);
   hMakeNNDAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'NNDs', 'Value', Default.makeNND, 'Position', [50 360 50 25], 'Tooltipstring', 'Check if Cumulative Probability plots of Nearest Neighbour Distances should be generated');
   hMakeAllDistAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'All Distances', 'Value', Default.makeAllDist, 'Position', [105 360 100 25], 'Tooltipstring', 'Check if Cumulative Probability plots for all Distances should be generated');
   hMakeClusterAnalysis=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'String', 'Cluster Parameters', 'Value', Default.makeCluster, 'Position', [205 360 125 25], 'Tooltipstring', 'Check if Cumulative Probability plots of Cluster parameters should be generated');
   
   hSelectTraces=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Select Traces', 'Position', [335 360 100 25], 'Callback', @selectTraces, 'Tooltipstring', 'Select which traces will be displayed in the figure');
   
   
   hColorText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Colorscheme', 'Position', [35 320 70 25], 'Tooltipstring', 'Select colors that will be used in the graphs');
   numberColors=size(Default.colorscheme, 1);
   hColorButtons=cell(1,numberColors);
   for i=1:numberColors
       hColorButtons{i}=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'BackgroundColor', Default.colorscheme(i,:), 'Position', [100+i*20 330 18 15], 'Callback', @(hObject,~)selectColor(hObject, i), 'Tooltipstring', 'Select colors that will be used in the graphs');
   end
   
 
   hLineStyleText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [35 290 70 25], 'String', 'Line Styles', 'Tooltipstring', sprintf('Choose Linestyles used.\nEach dropdown menu corresponds to one line.\nIf fewer styles than neccessary are selected, all further lines will have the same style as last selected one')); 
   hLineStyles=cell(1,7);
   for i=1:7
       hLineStyles{i}=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [18+i*78 285 84 35], 'String', {'', 'solid', 'dashed', 'dotted', 'dash-dot'}, 'Tooltipstring', sprintf('Choose Linestyles used.\nEach dropdown menu corresponds to one line.\nIf fewer styles than neccessary are selected, all further lines will have the same style as last selected one'));
   end
   if isfield(Default, 'LineStyleOrder')
       for i=1:numel(Default.LineStyleOrder)
          switch Default.LineStyleOrder{i}
              case '-'
                  set(hLineStyles{i}, 'Value', 2);
              case '--'
                  set(hLineStyles{i}, 'Value', 3);
              case ':'
                  set(hLineStyles{i}, 'Value', 4);
              case '-.'
                  set(hLineStyles{i}, 'Value', 5);
              otherwise
                  set(hLineStyles{i}, 'Value', 1);
          end
       end
   else
       set(hLineStyles{1}, 'Value', 2);
   end
   
   hLineWidthText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Line Width', 'Position', [35 260 70 25], 'Tooltipstring', 'Select width of the plotted lines');
   hLineWidthEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [100 267 30 21], 'Callback', @checkLineWidth, 'String', 'auto', 'Tooltipstring', 'Enter line width in pt here. If this field is left empty, automated determination of line widht is applied');
   if isfield(Default, 'LineWidth')
       set(hLineWidthEdit, 'String', num2str(Default.LineWidth));
   end
   hLineWidthError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [35 235 100 35], 'FontWeight', 'bold', 'ForegroundColor', 'red', 'String', 'Please choose a valid input', 'Visible', 'off');
   
   hFontSelection=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'Position', [155 265 100 25], 'String', 'Select Font', 'Callback', @selectFont, 'Tooltipstring', 'Select the font which will be used in the figures');
   hFontExample=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [259 235 100 50], 'HorizontalAlignment', 'left', 'String', 'Example', 'Tooltipstring', 'Example Text showing how the chosen Font looks.');
   if isfield(Default, 'FontSize')
       set(hFontExample, 'FontSize', Default.FontSize, 'FontName', Default.FontName, 'FontAngle', Default.FontAngle, 'FontWeight', Default.FontWeight, 'FontUnits', Default.FontUnits);
   end
   
   hTitleFontText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [400 260 130 25], 'String', 'Title fontsize multiplier', 'Tooltipstring', 'The fontsize of the title is regular font size*this value.');
   hTitleFontEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [530 267 30 21], 'String', 'auto', 'Tooltipstring', 'The fontsize of the title is regular font size*this value.', 'Callback', @titleFont);
   if isfield(Default, 'TitleFontSizeMultiplier')
       set(hTitleFontEdit, 'String', num2str(Default.TitleFontSizeMultiplier));
   end
   hTitleFontError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [400 235 100 35], 'FontWeight', 'bold', 'ForegroundColor', 'red', 'String', 'Please choose a valid input', 'Visible', 'off');

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
   xlabeltooltip=sprintf('Choose label of the axis with the NNDs\nHas no effect on plots for Cluster parameters.\nFor choosing these labels, use the "Choose Cluster Parameter names" button');
   hXLabelText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [460 200 50 25], 'String', 'Label', 'Tooltipstring', xlabeltooltip);
   hXLabelEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [510 207 130 25], 'String', Default.xlabeling, 'Tooltipstring', xlabeltooltip);

   
   
   
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
   ylabeltooltip='Choose label of the axis along which the Cumulative Probability is drawn';
   hYLabelText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [460 140 50 25], 'String', 'Label', 'Tooltipstring', ylabeltooltip);
   hYLabelEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [510 147 130 21], 'String', Default.ylabeling, 'Tooltipstring', ylabeltooltip);

   
   %%%
   
   hBox=uicontrol('Parent', Menu, 'Style', 'Checkbox', 'Position', [35 90 85 25], 'String', 'Display Box', 'Tooltipstring', 'Displays a box around the plot', 'Callback', @choseBox);
   if strcmp(Default.Box, 'on')
       set(hBox, 'Value', 1);
   end
   hGridText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [130 82 70 25], 'String', 'Grid linestyle', 'Tooltipstring', 'Choose the linestyle of the grid. Choose none if no grid should be displayed');
   hGridPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [200 85 84 25], 'Callback', @gridLineStyle, 'String', {'none', 'solid', 'dashed', 'dotted', 'dash-dot'}, 'Value', 2, 'Tooltipstring', 'Choose the linestyle of the grid. Choose none if no grid should be displayed');
   if isfield(Default, 'GridLineStyle')
       switch Default.GridLineStyle
           case 'none'
               set(hGridPopup, 'Value', 1);
           case '-'
               set(hGridPopup, 'Value', 2);
           case '--'
               set(hGridPopup, 'Value', 3);
           case ':'
               set(hGridPopup, 'Value', 4);
           case '-.'
               set(hGridPopup, 'Value', 5);
       end
   end
   
   hAxisLWText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [285 90 90 25], 'String', 'Axis Line Width', 'Tooltipstring', 'Choose thickness of the Axis (and some other lines)');
   hAxisLWEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [370, 97 30 21], 'String', 'auto', 'Callback', @axisLW, 'Tooltipstring', 'Choose thickness of the Axis (and some other lines)');
   if isfield(Default, 'AxisLineWidth')
       set(hAxisLWEdit, 'String', num2str(Default.AxisLineWidth));
   end
   hAxisLWError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [285 75 120 25], 'String', 'Only numbers, auto and empty is allowed', 'ForegroundColor', 'red', 'Fontweight', 'bold', 'Visible', 'off');
   
   hLegendBox=uicontrol('Parent', Menu, 'Style', 'CheckBox', 'Position', [410 100 100 25], 'String', 'Legend Box', 'Callback', @setLegendBox, 'Tooltipstring', 'Display a box around the figure legend');
   hLegendLWText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [490 90 80 25], 'String', 'LineWidth', 'Tooltipstring', 'Thickness of the legend box');
   hLegendLWEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [565 97 25 21], 'String', num2str(Default.LegendLineWidth), 'Callback', @legendLW, 'Tooltipstring', 'Thickness of the legend box');
   hLegendError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [490 65 105 25], 'String', 'Invalid Input', 'ForegroundColor', 'red', 'FontWeight', 'bold', 'Visible', 'off', 'Tooltipstring', 'Has to be a number>0');
   if strcmp(Default.LegendBox, 'on')
       set(hLegendBox, 'Value', 1);
   end
   if get(hLegendBox, 'Value')==0
       set(hLegendLWText, 'Visible', 'off');
       set(hLegendLWEdit, 'Visible', 'off');
   end
   
   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
   hErrorPresent=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [175 50 265 15], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'String', 'Cannot continue because Errors are present', 'Visible', 'Off');

   Options=Default;
   set(findall(Menu, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

   % Waits for the figure to close to end the function.
   waitfor(Menu);
 
%%%%%%
%% Functions start here
   
    function selectColor(hObject, colorNumber)
        color=uisetcolor(get(hObject, 'BackgroundColor'));
        Options.colorscheme(colorNumber,:)=color;
        set(hObject, 'BackgroundColor', color);
    end
    function checkLineWidth(hObject,~)
        set(hLineWidthError, 'Visible', 'off');
        string=get(hObject, 'String');
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
            list=cellfun(@str2num,list);            %Try to convert to numbers, if other characters are present
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
    function axisLW(hObject, ~)
        set(hAxisLWError, 'Visible', 'Off');
        string=get(hObject,'String');
        string=strrep(string, ' ', '');
        if isempty(string) || strcmp(string, '') || strcmp(string, 'auto') || strcmp(string, 'Auto') || strcmp(string, 'AUTO')
            if isfield(Options, 'AxisLineWidth')
                Options=rmfield(Options, 'AxisLineWidth');
            end
        elseif isempty(str2num(string))
            set(hAxisLWError, 'Visible', 'On');
        else
            Options.AxisLineWidth=str2num(string);
        end
     
    end
    function legendLW(hObject, ~)
        set(hLegendError, 'Visible', 'Off');
        string=get(hObject,'String');
        string=strrep(string, ' ', '');
        if isempty(str2double(string))
            set(hLegendError, 'Visible', 'On');
        else
            Options.LegendLineWidth=str2double(string);
        end
    end
    function setLegendBox(hObj, ~)
        if get(hObj, 'Value')==1
            set(hLegendLWText, 'Visible', 'on');
            set(hLegendLWEdit, 'Visible', 'on');
            Options.LegendBox='on';
        else
            set(hLegendLWText, 'Visible', 'off');
            set(hLegendLWEdit, 'Visible', 'off', 'String', num2str(Options.LegendLineWidth));
            set(hLegendError, 'Visible', 'off');
            Options.LegendBox='off';
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
    function gridLineStyle(hObject,~)
        switch get(hObject, 'Value')
            case 1
                Options.GridLineStyle='none';
            case 2
                Options.GridLineStyle='-';
            case 3
                Options.GridLineStyle='--';
            case 4
                Options.GridLineStyle=':';
            case 5
                Options.GridLineStyle='-.';
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

    function selectTraces(~,~)
        [Options.unwantedGroupTraces, Options.unwantedNNDTraces, Options.unwantedClusterTraces, Options.unwantedSimulationTraces]...
            =MenuTraces({Options.unwantedGroupTraces, Options.unwantedNNDTraces, Options.unwantedClusterTraces, Options.unwantedSimulationTraces}, Data, settings);
    end

    function logical=anyError()
       if strcmp(get(hXLimError, 'Visible'), 'on') || strcmp(get(hYLimError, 'Visible'), 'on') || strcmp(get(hLineWidthError, 'Visible'), 'on') ...
               || strcmp(get(hXTickError, 'Visible'), 'on') || strcmp(get(hYTickError, 'Visible'), 'on') || strcmp(get(hTitleFontError, 'Visible'), 'on') ...
               || strcmp(get(hLegendError, 'Visible'), 'on') || strcmp(get(hAxisLWError, 'Visible'), 'on')
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
            set(hErrorPresent, 'Visible', 'On');
        else
            set(hErrorPresent, 'Visible', 'Off');
            Options.xlabeling=get(hXLabelEdit, 'String');
            Options.ylabeling=get(hYLabelEdit, 'String');
            Options.makeNND=get(hMakeNNDAnalysis, 'Value');
            Options.makeAllDist=get(hMakeAllDistAnalysis, 'Value');
            Options.makeCluster=get(hMakeClusterAnalysis, 'Value');
            Options.LineStyleOrder=cell(1,numel(hLineStyles));
            for i=1:numel(hLineStyles)
                switch get(hLineStyles{i}, 'Value')
                    case 2
                        Options.LineStyleOrder{i}='-';
                    case 3
                        Options.LineStyleOrder{i}='--';
                    case 4
                        Options.LineStyleOrder{i}=':';
                    case 5
                        Options.LineStyleOrder{i}='-.';
                end
            end
            Options.LineStyleOrder=Options.LineStyleOrder(~cellfun('isempty',Options.LineStyleOrder));    %Remove all empty cells
            if isempty(Options.LineStyleOrder)
                Options=rmfield('LineStyleOrder');
            end
            delete(gcf)
        end
    end
   
end

