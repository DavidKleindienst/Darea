function preprocessingMenu(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


positionFigure =  [150, 150, 350, 305];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Preprocessing'); 
set(mainFigure, 'CloseRequestFcn', @close);

hWarning=uicontrol('Style', 'Text', 'String', 'Warning: Running this function will irreversibly change your images', ...
                'FontWeight', 'bold', 'Position', [75 240 200 30]);

hConvert=uicontrol('Style', 'checkbox', 'String', 'Convert Images to 16 bit', 'Position', [25 200 200 25]);
hInvert=uicontrol('Style', 'checkbox', 'String', 'Invert Images', 'Position', [25 170 200 25]);
hContrast=uicontrol('Style', 'checkbox', 'String', 'Auto-adjust contrast', 'Position', [25 140 200 25]);
hDownscale=uicontrol('Style', 'checkbox', 'String', 'Downscale Image', 'Position', [25 110 200 25], ...
                    'Callback', @downscaleClick);
                
downscalePx=[2048,2048];
hX=uicontrol('Style', 'Edit', 'String', num2str(downscalePx(1)), 'Position', [150 110 60 25],...
            'Callback', @downscaleVal);
hx=uicontrol('Style', 'Text', 'String', 'x', 'Position', [215 110 10 25]);
hY=uicontrol('Style', 'Edit', 'String', num2str(downscalePx(2)), 'Position', [225 110 60 25],...
            'Callback', @downscaleVal);
hPx=uicontrol('Style', 'Text', 'String', 'pixel', 'Position', [285 110 60 25]);

dsVis=[hX,hY,hx,hPx];
set(dsVis, 'Visible', 'off');
                
hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [75 80 200 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');

hStart=uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [75 25 60 25], 'Callback', @start);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Position', [215 25 60 25], 'Callback', @close);

waitfor(mainFigure);

    function close(~,~)
        delete(mainFigure);
    end
    function downscaleVal(hOb,~)
        if isequal(hOb,hX)
            i=1;
        else
            i=2;
        end
        downscalePx(i)=shouldBeNumber(downscalePx(i),hOb,false,[0,inf]);
    end
    function downscaleClick(~,~)
        if hDownscale.Value
            set(dsVis, 'Visible', 'on');
        else
            set(dsVis, 'Visible', 'off');
        end
    end
    function start(~,~)
        hProgress.String='Starting preprocessing...';
        drawnow();
        try
            preprocess(datFile,hConvert.Value,hInvert.Value,hContrast.Value,hDownscale.Value,downscalePx,hProgress);
            hProgress.String='Finished preprocessing';
        catch expt
            hProgress.String='Preprocessing failed';
            rethrow(expt);
        end
    end
end

