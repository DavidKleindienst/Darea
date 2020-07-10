function preprocessingMenu(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


positionFigure =  [150, 150, 350, 305];
mainFigure = figure('OuterPosition', positionFigure, 'menubar', 'none', 'resize','off', 'Name', 'Preprocessing'); 
set(mainFigure, 'CloseRequestFcn', @close);

hWarning=uicontrol('Style', 'Text', 'String', 'Warning: Running this function will modify your images', ...
                'FontWeight', 'bold', 'Position', [75 240 200 30]);

hConvert=uicontrol('Style', 'checkbox', 'String', 'Convert Images to 16 bit', 'Position', [25 200 200 25]);
hInvert=uicontrol('Style', 'checkbox', 'String', 'Invert Images', 'Position', [25 170 200 25]);
hContrast=uicontrol('Style', 'checkbox', 'String', 'Auto-adjust contrast', 'Position', [25 140 200 25]);

hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [75 80 200 35], 'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');

hStart=uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [75 50 60 25], 'Callback', @start);
hClose=uicontrol('Style', 'pushbutton', 'String', 'Close', 'Position', [215 50 60 25], 'Callback', @close);

waitfor(mainFigure);

    function close(~,~)
        delete(mainFigure);
    end

    function start(~,~)
        try
            preprocess(datFile,hConvert.Value,hInvert.Value,hContrast.Value,hProgress);
            hProgress.String='Finished preprocessing';
        catch expt
            hProgress.String='Preprocessing failed';
            rethrow(expt);
        end
    end
end

