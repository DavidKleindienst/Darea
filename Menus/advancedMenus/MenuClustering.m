
function Options=MenuClustering(settings, groupnames)
% Opens advanced option menu for Clustering
   Options=settings;
   positionMenu=[225 250 450 340];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Clustering Options', 'resize', 'Off', 'menubar', 'None', 'CloseRequestFcn', @close);
    
   ClustDistTooltip=sprintf('Select whether the Distance between two Clusters will be calculated from Outline to Outline or as distance between the two nearest Particles.\nIn any case, if one particle of one Cluster is within the outline of the other Cluster, the distance is 0!');
   hClusterDistanceText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Distance between two Clusters', 'Position', [25 272 150 25], 'Tooltipstring', ClustDistTooltip);
   hClusterDistancePopup=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [180 275 135 25], 'String', {'Outline to Outline', 'Particle to Particle', 'Center of Gravity'}, 'Value', settings.ClusterOptions.ClusterDistanceMethod, 'Tooltipstring', ClustDistTooltip);
   
   ClusteringTooltip=sprintf('Does not have any influence if ClusteringDistance is given in nm');
   hClusteringText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Calculate ClusterDistance for', 'Position', [25 242 150 25], 'Tooltipstring', ClusteringTooltip);
   hClusteringPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'String', {'All groups and particle sizes together', 'Each particle size individually', 'Each group individually', 'Each group and particle size individually'}, ...
                                'Position', [180 245 240 25], 'Value', settings.ClusterOptions.Clustering, 'Tooltipstring', ClusteringTooltip, 'Callback', @clustCalcChange);
   
   
   hClusteringByGroupText=uicontrol('Style', 'Text', 'String', 'Relevant Groups for calculating Clustering Distance', 'Position', [25 202 150 25]);
   hClusteringGroups=uicontrol('Style', 'listbox', 'String', groupnames, 'min', 0, 'max', numel(groupnames), 'Position', [190 100 130 130]);
   set(hClusteringGroups, 'Value', settings.chosenGroups);
   clustCalcChange(0,0);
   
   NotVisibleWhenNm=[hClusteringText, hClusteringPopup, hClusteringByGroupText, hClusteringGroups];
   if strcmp(settings.maxDist{1},'nm')
       for e=1:numel(NotVisibleWhenNm)
           set(NotVisibleWhenNm(e), 'Visible', 'off');
       end
   end
   
   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);

   
   % Waits for the figure to close to end the function.
    waitfor(Menu);
   
    function clustCalcChange(~,~)
        if numel(groupnames)==1 || hClusteringPopup.Value<3  
            set(hClusteringByGroupText, 'Visible', 'off');
            set(hClusteringGroups, 'Visible', 'off');
        else
            set(hClusteringByGroupText, 'Visible', 'on');
            set(hClusteringGroups, 'Visible', 'on');
        end
    end
   
    function close(~,~)
        Options=settings;
        delete(gcf)  
    end
    function updateOptions(~,~)
        Options.ClusterOptions.Clustering=get(hClusteringPopup, 'Value');
        Options.ClusterOptions.ClusterDistanceMethod=get(hClusterDistancePopup, 'Value');
        if strcmp(get(hClusteringGroups,'Visible'),'on')
            Options.chosenGroups=hClusteringGroups.Value;
        end
        delete(gcf)
    end
   
end

