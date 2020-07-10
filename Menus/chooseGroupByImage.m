function [groupings, results]=chooseGroupByImage(groupnames, datFile)
    stop=0;
    results=NaN;
    showDem=0;
    groupings=[];
    choicefig=figure('OuterPosition', [80 100 500 300], 'menubar', 'none', 'resize','off', 'Name', 'Select Groups', 'CloseRequestFcn', @close);
    
    uicontrol('Style', 'Text', 'String', 'Please select Grouping for which you would to choose by going through images', 'Position', [25 240 250 35], 'FontWeight','bold');
       
    hGroupings=uicontrol('Style', 'Listbox', 'min', 0, 'max', numel(groupnames), 'String', groupnames, 'Position', [75 120 150 100]);
    
    hDemarcation=uicontrol('Style','checkbox', 'String', 'Show demarcation', 'Position', [25 85 120 25]);
    
    uicontrol('Style', 'pushbutton', 'String', 'Ok', 'Tooltipstring', 'Save', 'Position', [180 40 90 30], 'Callback', @proceed);
    uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [290 40 90 30], 'Callback', @close);

    waitfor(choicefig);
    if ~stop
        groupfig=figure('OuterPosition', [80 100 500 300], 'menubar', 'none', 'resize','off', 'Name', 'Select Groups');
        uicontrol('Style', 'Text', 'String', sprintf('Please name all possible groups you would like to assing for each groupings\nSeperate Groups by ";"'), 'Position', [25 190 330 80],'FontWeight','bold');
        hGrpNameText=gobjects(1,numel(groupings));
        hGrpNameEdit=gobjects(1,numel(groupings));
        hGrpsMissingError=uicontrol('Style', 'Text', 'Position', [130 100 200 25], 'String', 'Please specify at least two possibilities (seperated by ";") per group', 'Visible', 'off', 'FontWeight', 'bold', 'Foregroundcolor', 'red');
        for g=1:numel(groupings)
            hGrpNameText(g)=uicontrol('Style','Text', 'String', groupings{g}, 'Position', [25 180-(g-1)*30 75 25]);
            hGrpNameEdit(g)=uicontrol('Style', 'Edit', 'Position', [110 180-(g-1)*30 200 25]);
        end
        uicontrol('Style', 'pushbutton', 'String', 'Ok', 'Tooltipstring', 'Save', 'Position', [180 40 90 30], 'Callback', @proceedToChooser);
        uicontrol('Style', 'pushbutton', 'String', 'Close', 'Tooltipstring', 'Exit without saving', 'Position', [290 40 90 30], 'Callback', @close);

        waitfor(groupfig);
    end

    function close(~,~)
        stop=1;
        delete(choicefig);
        delete(groupfig);
        
        return
    end

    function proceed(~,~)
        groupings=hGroupings.String(hGroupings.Value);
        showDem=hDemarcation.Value;
        delete(choicefig);
    end
    
    function proceedToChooser(~,~)
        %take choices
        maxVal=2;
        for g=1:numel(groupings)
            if isempty(hGrpNameEdit(g).String)
                set(hGrpsMissingError, 'Visible', 'on')
                return
            end
            grps=split(hGrpNameEdit(g).String, ';');
            if numel(grps)<2
                set(hGrpsMissingError, 'Visible', 'on')
                return
            end
            maxVal=max(maxVal,numel(grps));
        end
        choices=cell(numel(groupings),maxVal);
        for g=1:numel(groupings)
            grps=split(hGrpNameEdit(g).String, ';');
            for c=1:numel(grps)
                choices{g,c}=grps{c};
            end
        end
        results=imageChooser('Choose Group for each Image', 'Letters in brackets are hotkeys', choices, true, datFile,showDem);
        delete(groupfig);
        
        
    end

end