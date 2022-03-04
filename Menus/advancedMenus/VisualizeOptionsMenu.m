%
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria - Klosterneuburg - Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

function Options = VisualizeOptionsMenu(Default, particleList, showExclusion)
%% Displays a Menu to select parameters for visualization of the image

   Options=Default;
   positionMenu=[225 250 550 440];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Options', 'menubar', 'None', 'CloseRequestFcn', @close);
   
   %Particle Appearance
   uicontrol('Style', 'Text', 'FontWeight','bold','Position',[15 370 180 20], 'String', 'Particle appearance','HorizontalAlignment', 'left');
   uicontrol('Style', 'Text', 'String', 'Color', 'Position', [25 310 60 25]);
   uicontrol('Style', 'Text', 'String', 'Filled', 'Position', [25 280 60 20]);
   
   nrPart=numel(particleList);
   hColors=gobjects(1,nrPart);
   hFilled=gobjects(1,nrPart);
   for a=1:nrPart
       uicontrol('Style', 'Text', 'String', particleList{a}, 'Position', [75+a*40 350 35 25]);
       hColors(a)=uicontrol('Style', 'pushbutton', 'BackgroundColor', Default.particleColor{a}, ...
                'Position', [80+a*40 320 25 15], 'Callback', @(x,~)selectColor('particle', x, a), 'Tooltipstring', 'Select particle color');
       hFilled(a)=uicontrol('Style','checkbox', 'Position', [80+a*40 290 25 15], 'Tooltipstring', 'Check if circle should be filled', ...
                    'Value',Default.fillParticle(a));
   end
   
   
   % Demarcation Options
   hDemarcationOptionsText=uicontrol('Parent', Menu, 'Style', 'Text','HorizontalAlignment','left', ...
                'FontWeight', 'bold', 'Position', [15 258 200 20], 'String', 'Demarcation Visualization Options');
   hMask=uicontrol('Style', 'Checkbox','String','Demarcation from Analysis', 'Position', [25 230 150 25], 'Value',Default.maskFromAnalysis, ...
                'Tooltipstring', sprintf('Shows the demarcation used in the analysis\nOtherwise shows the currently saved demarcation'));
   hDemVisText=uicontrol('Style', 'Text', 'String', 'Demarcation Style', 'Position', [25 200 90 25]);
   hDemarcationStyle=uicontrol('Style', 'Popup', 'String', {'None','Brightness','Line', 'Color'}, 'Position', [125 200 150 25], 'Callback', @styleVisibility);
   
   hRimVisText=uicontrol('Style', 'Text', 'String', 'Outer Rim Style', 'Position', [25 175 90 25]);
   hRimStyle=uicontrol('Style', 'Popup', 'String', {'None','Brightness','Line', 'Color'}, 'Position', [125 175 150 25], 'Callback', @styleVisibility);
   
   hBrightnessText=uicontrol('Style','text','String','BackgroundBrightness','Position' ,[280 230 105 25]);
   hBrightness=uicontrol('Style','slider','Min',0,'Max',1,'Value',Default.BackgroundBrightness,'Position',[400 230 140 25]);

   hDemLineStyle=uicontrol('Style', 'popup', 'String', {'solid', 'dashed', 'dotted', 'dash-dot'}, 'Position', [315 200 100 25]);
   hDemLineColor=uicontrol('Style', 'pushbutton', 'BackgroundColor', Default.lineDemColor, 'Position', [425 208 25 15], 'Callback', @(x,~)selectColor('lineDem', x), 'Tooltipstring', 'Select line color');
   hDemLineWidth=uicontrol('Style', 'Edit', 'String', num2str(Default.lineDemWidth), 'Position', [470 200 40 25], 'Callback',@checkNumber);
   hDemLineWidthT=uicontrol('Style', 'Text', 'String', 'pt', 'Position', [510 200 20 25]);
   
   hRimLineStyle=uicontrol('Style', 'popup', 'String', {'solid', 'dashed', 'dotted', 'dash-dot'}, 'Position', [315 175 100 25]);
   hRimLineColor=uicontrol('Style', 'pushbutton', 'BackgroundColor', Default.lineRimColor, 'Position', [425 183 25 15], 'Callback', @(x,~)selectColor('lineRim', x), 'Tooltipstring', 'Select line color');
   hRimLineWidth=uicontrol('Style', 'Edit', 'String', num2str(Default.lineRimWidth), 'Position', [470 175 40 25], 'Callback',@checkNumber);
   hRimLineWidthT=uicontrol('Style', 'Text', 'String', 'pt', 'Position', [510 175 20 25]);
   
   hDemColorColor=uicontrol('Style', 'pushbutton', 'BackgroundColor', Default.colorDemColor, 'Position', [300 208 25 15], 'Callback', @(x,~)selectColor('colorDem', x), 'Tooltipstring', 'Select overlay color');
   hDemColorTranspT=uicontrol('Style', 'Text', 'String', 'Transparency', 'Position', [335 200 80 25]);
   hDemColorTransp=uicontrol('Style', 'Edit', 'String', num2str(Default.transparencyDem), 'Position', [420 200 30 25], 'Callback',@checkNumber);
   
   hRimColorColor=uicontrol('Style', 'pushbutton', 'BackgroundColor', Default.colorRimColor, 'Position', [300 183 25 15], 'Callback', @(x,~)selectColor('colorRim', x), 'Tooltipstring', 'Select overlay color');
   hRimColorTranspT=uicontrol('Style', 'Text', 'String', 'Transparency', 'Position', [335 175 80 25]);
   hRimColorTransp=uicontrol('Style', 'Edit', 'String', num2str(Default.transparencyRim), 'Position', [420 175 30 25], 'Callback',@checkNumber);
   
   
   hExclVisText=uicontrol('Style', 'Text', 'String', 'Exclusion Zone Style', 'Position', [25 150 90 25]);
   hExclStyle=uicontrol('Style', 'Popup', 'String', {'None','Line'}, 'Position', [125 150 150 25], 'Callback', @styleVisibility);
   hExclLineStyle=uicontrol('Style', 'popup', 'String', {'solid', 'dashed', 'dotted', 'dash-dot'}, 'Position', [315 150 100 25]);
   hExclLineColor=uicontrol('Style', 'pushbutton', 'BackgroundColor', Default.lineExclColor, 'Position', [425 158 25 15], 'Callback', @(x,~)selectColor('lineExcl', x), 'Tooltipstring', 'Select line color');
   hExclLineWidth=uicontrol('Style', 'Edit', 'String', num2str(Default.lineExclWidth), 'Position', [470 150 40 25], 'Callback',@checkNumber);
   hExclLineWidthT=uicontrol('Style', 'Text', 'String', 'pt', 'Position', [510 150 20 25]);
    
   % For all popups select proper entry based on default values
   popups=[hDemarcationStyle, hRimStyle, hDemLineStyle, hRimLineStyle,hExclStyle hExclLineStyle];
   defVals={Default.DemarcationStyle,Default.RimStyle, Default.lineDemStyle, Default.lineRimStyle, Default.ExclStyle, Default.lineExclStyle};
   assert(numel(popups)==numel(defVals));
   for i=1:numel(popups)
       set(popups(i), 'Value', find(cellfun(@(cell) isequaln(cell, defVals{i}), get(popups(i), 'String'))));
   end
   
   VisibleOnBrightness=[hBrightnessText,hBrightness];
   VisibleOnLineDem=[hDemLineStyle, hDemLineColor, hDemLineWidth, hDemLineWidthT];
   VisibleOnLineRim=[hRimLineStyle, hRimLineColor, hRimLineWidth, hRimLineWidthT];
   VisibleOnColorDem=[hDemColorColor,hDemColorTransp, hDemColorTranspT];
   VisibleOnColorRim=[hRimColorColor,hRimColorTransp, hRimColorTranspT];
   VisibleOnLineExcl=[hExclLineStyle, hExclLineColor, hExclLineWidth, hExclLineWidthT];

   if ~showExclusion
       hExclStyle.Value=1;
       set(VisibleOnLineExcl,'Visible','off');
       hExclStyle.Visible='off';
       hExclVisText.Visible='off';
   end
   
   %Options for Scalebar
   hScalebarOptionsText=uicontrol('Parent', Menu, 'Style', 'Text', 'FontWeight', 'bold', 'HorizontalAlignment','left', ...
                            'Position', [15 128 130 20], 'String', 'Scalebar Options');
   hScaleSizeText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [25 105 70 25], 'String', 'Length', 'Tooltipstring', 'Length of Scalebar in nm');
   hScaleSizeEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [90 105 50 25], 'String', num2str(Default.scaleLength), 'Tooltipstring', 'Length of Scalebar in nm', 'callback', @checkNumber);
   hScaleSizeError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [25 80 120 25], 'String', 'Select a positive number', 'Foregroundcolor', 'red', 'FontWeight', 'bold', 'Visible', 'off');
   
   hScalePosText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [140 105 70 25], 'String', 'Position', 'Tooltipstring', 'Select Position of Scalebar within Image');
   hScalePosSelect=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [210 105 120 25], 'String', {'northwest', 'northeast', 'southwest', 'southeast'}, 'Tooltipstring', 'Select Position of Scalebar within Image');
   hScaleOrientation=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [210 75 120 25], 'String', {'horizontal', 'vertical'}, 'Tooltipstring', 'Select Orientation of Scalebar within Image');
   set(hScalePosSelect, 'Value', find(cellfun(@(cell) isequaln(cell, Default.scalePos), get(hScalePosSelect, 'String'))));
   set(hScaleOrientation, 'Value', find(cellfun(@(cell) isequaln(cell, Default.scaleOrientation), get(hScaleOrientation, 'String'))));

   hScaleColorText=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [320 105 70 25], 'String', 'Color', 'Tooltipstring', 'Select scalebar color');
   hScaleColorSelect=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'BackgroundColor', Default.scaleColor, 'Position', [380 115 25 15], 'Callback', @(x,~)selectColor('scale',x), 'Tooltipstring', 'Select scalebar color');
   
   hScaleWidthText=uicontrol('Style', 'Text', 'Position', [410 105 50 25], 'String', 'Width', 'Tooltipstring', 'Line Width of the Scalebar in pt');
   hScaleWidth=uicontrol('Style', 'Edit', 'Position', [460 105 40 25], 'String', num2str(Default.scaleWidth), 'Tooltipstring', 'Line Width of the Scalebar in pt', 'Callback', @checkNumber);
   hScaleWidthpt=uicontrol('Style', 'Text', 'Position', [505 105 20 25], 'String', 'pt', 'Tooltipstring', 'Line Width of the Scalebar in pt');

   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
   styleVisibility(0,0);
   set(findall(Menu, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

   % Waits for the figure to close to end the function.
   waitfor(Menu);
    
    function styleVisibility(~,~)
        bright='off'; lineDem='off'; lineRim='off'; lineExcl='off'; colorDem='off'; colorRim='off';
        
        if hDemarcationStyle.Value==2 || hRimStyle.Value==2
            bright='on';
        end
        if strcmp(getSelectedStringFromPopup(hRimStyle), 'Line')
            lineRim='on';
        elseif strcmp(getSelectedStringFromPopup(hRimStyle), 'Color')
            colorRim='on';
        end
        if strcmp(getSelectedStringFromPopup(hDemarcationStyle), 'Line')
            lineDem='on';
        elseif strcmp(getSelectedStringFromPopup(hDemarcationStyle), 'Color')
            colorDem='on';
        end
        if strcmp(getSelectedStringFromPopup(hExclStyle), 'Line')
            lineExcl='on';
        end
        set(VisibleOnLineExcl,'Visible',lineExcl);
        set(VisibleOnBrightness,'Visible',bright);
        set(VisibleOnLineDem,'Visible',lineDem);
        set(VisibleOnColorDem,'Visible',colorDem);
        set(VisibleOnLineRim,'Visible',lineRim);
        set(VisibleOnColorRim,'Visible',colorRim);
    end
    function checkNumber(hObj,~)
        switch hObj
            case hScaleSizeEdit
                Options.scaleLength=shouldBeNumber(Options.scaleLength,hObj,1,[0,inf]);
            case hScaleWidth
                Options.scaleWidth=shouldBeNumber(Options.scaleWidth,hObj,1,[0,inf]);
            case hDemLineWidth
                Options.lineDemWidth=shouldBeNumber(Options.lineDemWidth,hObj,1,[0,inf]);
            case hRimLineWidth
                Options.lineRimWidth=shouldBeNumber(Options.lineRimWidth,hObj,1,[0,inf]);
            case hExclLineWidth
                Options.lineExclWidth=shouldBeNumber(Options.lineExclWidth,hObj,1,[0,inf]);
            case hDemColorTransp
                Options.transparencyDem=shouldBeNumber(Options.transparencyDem,hObj,1,[0,1]);
            case hRimColorTransp
                Options.transparencyRim=shouldBeNumber(Options.transparencyRim,hObj,1,[0,1]);
            otherwise
                error('%s is missing. This is a bug.', hObj);
        end
    end
    function selectColor(type,hObj, pNr)   %Select Scalebar color
        color=uisetcolor(get(hObj, 'BackgroundColor'));
        switch type
            case 'scale'
                Options.scaleColor=color;
            case 'lineDem'
                Options.lineDemColor=color;
            case 'lineRim'
                Options.lineRimColor=color;
            case 'lineExcl'
                Options.lineExclColor=color;
            case 'colorDem'
                Options.colorDemColor=color;
            case 'colorRim'
                Options.colorRimColor=color;
            case 'particle'
                Options.particleColor{pNr}=color;
                
        end
        set(hObj, 'BackgroundColor', color);
    end
    
   

    function close(~,~) %closes window
        Options=Default;
        delete(gcf)  
    end
    function updateOptions(~,~) %Updates settings and closes window

        Options.maskFromAnalysis=hMask.Value;
        Options.scalePos=getSelectedStringFromPopup(hScalePosSelect);
        Options.scaleOrientation=getSelectedStringFromPopup(hScaleOrientation);
        Options.DemarcationStyle=getSelectedStringFromPopup(hDemarcationStyle);
        Options.ExclStyle=getSelectedStringFromPopup(hExclStyle);
        Options.RimStyle=getSelectedStringFromPopup(hRimStyle);
        Options.BackgroundBrightness=hBrightness.Value;
        Options.lineDemStyle=getSelectedStringFromPopup(hDemLineStyle);
        Options.lineRimStyle=getSelectedStringFromPopup(hRimLineStyle);
        Options.lineExclStyle=getSelectedStringFromPopup(hExclLineStyle);
        Options.scaleWidth=str2double(hScaleWidth.String);
        Options.lineDemWidth=str2double(hDemLineWidth.String);
        Options.lineRimWidth=str2double(hRimLineWidth.String);
        Options.lineExclWidth=str2double(hExclLineWidth.String);
        Options.transparencyDem=str2double(hDemColorTransp.String);
        Options.transparencyRim=str2double(hRimColorTransp.String);
        if numel(hFilled)==1
            Options.fillParticle=[hFilled.Value];
        else
            Options.fillParticle=cell2mat(get(hFilled,'Value'))';
        end
        delete(gcf)
            
    end

   
end

