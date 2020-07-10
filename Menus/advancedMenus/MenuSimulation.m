
function Options=MenuSimulation(Default,particleTypes)
% Opens advanced option menu for simulations
   Options=Default;
   positionMenu=[225 250 525 400];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Options for Simulation', 'resize', 'Off', 'menubar', 'None', 'CloseRequestFcn', @close);
   
   
   hMinDistText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Minimum Distance', 'Position', [25 325 110 25], 'Tooltipstring', 'Minimum Distance between two particles in nm');
   hMinDistEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', num2str(Default.mindistance), 'Position', [135 332 30 21], 'Tooltipstring', 'Minimum Distance between two particles in nm', 'Callback', @checkIsNumber);
   
   boundTooltip=sprintf('Specify lower and upper bound of the fitted NND\nBe careful with specifying these Parameters.\nIf it is not possible for a value to be between them, the analysis will never finish.');

   hSimFitBoundText=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'Fit', 'Position', [25 280 13 25], 'Tooltipstring', boundTooltip);
   hSimFitBoundText2=uicontrol('Parent', Menu, 'Style', 'Text', 'String', 'to be between', 'Position', [100 280 100 25], 'Tooltipstring', boundTooltip);
   hSimFitDistType=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [40 280 80 25], 'String', {'NNDs', 'all Distances'}, 'Tooltipstring', 'Select Type of Distance that should be fitted');
   hSimFitLowerEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [305 287 30 21], 'String', num2str(Default.bounds{1,2}), 'Tooltipstring', boundTooltip, 'Callback', @checkIsNumber);
   hSimFitLowerPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [190 280 115 25], 'String', {'nm', 'mean + x*SD', 'mean + x*SEM', 'xth Percentile', 'None', 'KS'}, 'Value', Default.bounds{1,1}, 'Tooltipstring', boundTooltip, 'Callback', @(hObj, ~)selectBound(hObj, hSimFitLowerEdit));
   hSimFitBoundText3=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [335 280 30 25], 'String', 'and', 'Tooltipstring', boundTooltip);
   hSimFitUpperEdit=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [475 287 30 21], 'String', num2str(Default.bounds{2,2}), 'Tooltipstring', boundTooltip, 'Callback', @checkIsNumber);
   hSimFitUpperPopup=uicontrol('Parent', Menu, 'Style', 'popup', 'Position', [360 280 115 25], 'String', {'nm', 'mean + x*SD', 'mean + x*SEM', 'xth Percentile', 'None', 'KS'}, 'Value', Default.bounds{2,1}, 'Tooltipstring', boundTooltip, 'Callback', @(hObj, ~)selectBound(hObj, hSimFitUpperEdit));

   set(hSimFitDistType, 'Value', find(cellfun(@(cell) isequaln(cell, Default.fitdisttype), get(hSimFitDistType, 'String'))));
   
   if Default.bounds{1,1}==5; set(hSimFitLowerEdit, 'Visible', 'off'); end
   if Default.bounds{2,1}==5; set(hSimFitUpperEdit, 'Visible', 'off'); end
   
   hSimulateOnText=uicontrol('Style','Text', 'String', 'Simulate on', 'Position', [25 240 80 25]);
   hSimulateOnDD=uicontrol('Style','popup','String',{'Demarcation','Demarcation and Rim'}, 'Position', [110 240 180 25],'Value', Default.simOnDilation+1);
   
   hTwoStep=uicontrol('Style', 'checkbox', 'String', 'Two-step simulation', 'Position', [25 210 180 25], 'Value', Default.twoStep, ...
                      'Tooltipstring', 'Use a two-step (1: Receptor, 2: Gold particle) simulation', 'Callback', @changeVisibility);
   hReceptorDistText=[uicontrol('Style','Text','Visible', Default.twoStep,'String', 'Mininmum Distance between receptors', 'Position', [190 205 180 25]), ...
                      uicontrol('Style','Text','Visible', Default.twoStep,'String', 'nm', 'Position', [405 205 30 25])];
   hReceptorDistEdit=uicontrol('Style','Edit','Visible', Default.twoStep, 'String', num2str(Default.minReceptorDistance), 'Position', [375 205 30 25]);
   
   rpDistTT=sprintf('Maximum Distance between simulated receptor and simulated gold particle\nSet to -1 to make it same as Outer Rim radius');
   hRPDistText=[uicontrol('Style','Text','Visible', Default.twoStep,'String', 'Distance between receptor and particle', 'Position', [190 180 180 25], ...
                            'Tooltipstring', rpDistTT), ...
                  uicontrol('Style','Text','Visible', Default.twoStep,'String', 'nm', 'Position', [435 180 30 25], 'Tooltipstring',rpDistTT)];
   hRPDistEdit=uicontrol('Style','Edit','Visible', Default.twoStep, 'String', num2str(Default.ReceptorParticleDistance(2)), ...
                        'Position', [375 180 60 25], 'Callback',@checkIsNumber, 'Tooltipstring', rpDistTT);
   strforsameasouterrim='(Same as Outer Rim radius)';
   checkIsNumber(hRPDistEdit);
   
   hExclusionZones=uicontrol('Style', 'checkbox', 'String', 'Exclusion Zones', 'Position', [25 150 180 25], 'Value', Default.exclZones, ...
                    'Tooltipstring', 'Whether or not exclusion zones should be simulated', 'Callback', @changeVisibility);
   nrTT=sprintf('');
   hNrText1=uicontrol('Style', 'Text', 'String', 'Number of Zones', 'Position', [180 145 100 25], 'Tooltipstring', nrTT);
   hNrEdit1=uicontrol('Style', 'Edit', 'String', num2str(Default.zoneNr{1}), 'Position', [280 150 40 25], 'Callback', @checkIsNumber, 'Tooltipstring', nrTT);
   hNrText2=uicontrol('Style', 'Text', 'String', '+', 'Position', [325 145 10 25], 'Tooltipstring', nrTT);
   hNrEdit2=uicontrol('Style', 'Edit', 'String', num2str(Default.zoneNr{2}), 'Position', [335 150 40 25], 'Callback', @checkIsNumber, 'Tooltipstring', nrTT);
   hNrText3=uicontrol('Style', 'Text', 'String', '*Area', 'Position', [370 145 50 25], 'Tooltipstring', nrTT);

   diameterTT='Diameter of each exclusion zone';
   hZDiameterText=uicontrol('Style', 'Text', 'String', 'Zone Diameter', 'Position', [100 120 100 25], 'Tooltipstring', diameterTT);
   hZDiameterEdit=uicontrol('Style', 'Edit', 'String', num2str(Default.zoneDiameter), 'Position', [200 120 40 25], ...
                    'Callback', @checkIsNumber, 'Tooltipstring', diameterTT);
   zDistTT='Minimum required Distance between two exclusion zones';
   hZDistText=uicontrol('Style', 'Text', 'String', 'Zone Distance', 'Position', [260 120 100 25], 'Tooltipstring', zDistTT);
   hZDistEdit=uicontrol('Style', 'Edit', 'String', num2str(Default.zoneDistance), 'Position', [360 120 40 25], ...
                    'Callback', @checkIsNumber, 'Tooltipstring', zDistTT);
   
   nrPartTypes=numel(particleTypes);
   if numel(Default.partExcl)<nrPartTypes
       %If property was defined for fewer particles than neccessary, fill up rest with 'random'
       Default.partExcl=[Default.partExcl, repmat({'random'},1,nrPartTypes-numel(Default.partExcl))];
       Options.partExcl=Default.partExcl;
   end
   partExclTT=sprintf(['The relationship of each particle Size with exclusion zones\n' ...
               'Random: Particles are distributed irrespective of exclusion zones (Same as if exclusion zone did not exist\n'...
               'inside: Particles are limited to inside the exclusion zones\n' ...
               'outside: Particles are limited to outside the exclusion zones']);
   hExclPartText=uicontrol('Style', 'Text', 'String', 'Relation of particles and zones', 'Position', [25 75 100 30], ...
                        'Tooltipstring', partExclTT);
   hPartNames=gobjects(1,nrPartTypes);
   hExclPart=gobjects(1,nrPartTypes);
   for i=1:nrPartTypes
       hPartNames(i)=uicontrol('Style', 'Text', 'String', [num2str(particleTypes(i)) ' nm'], ...
                         'Tooltipstring', partExclTT, 'Position', [130+80*(i-1) 90 75 20]);
       hExclPart(i)=uicontrol('Style', 'popup', 'String', {'random', 'outside', 'inside'}, ...
                          'Tooltipstring', partExclTT, 'Position', [130+80*(i-1) 70 75 20]);
       hExclPart(i).Value=find(cellfun(@(cell) isequaln(cell, Default.partExcl{i}), hExclPart(i).String));
   end
   
   
   
   hSaveIndiv = uicontrol('Parent', Menu, 'Style', 'CheckBox', 'String', 'Save every Simulation', 'Tooltipstring', sprintf('Required for Image by Image Analysis.\nDeactivate if not needed to drastically reduce file size.'), ...
                    'Position', [25 170 180 25], 'Value', Default.indivsave, 'Visible', 'off');
   
   hEndlessLoop=uicontrol('Parent', Menu, 'Visible', 'off', 'Style', 'Text', 'Position', [135 30 355 50], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'String', sprintf('The current settings of NND fitting would lead to an endless Loop!\nThe lower bound (left) must be smaller than the upper bound(right)'));
   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
   % Show or hide two-step and exclZone settings
   changeVisibility(hExclusionZones);
   changeVisibility(hTwoStep);
   waitfor(Menu);
    
    function checkIsNumber(hObj, ~)
       if isequal(hObj,hRPDistEdit) && strcmp(hObj.String,'-1')
           hRPDistEdit.String=strforsameasouterrim;
           Options.ReceptorParticleDistance(2)=-1;
           return;
       end
       
       switch hObj
           case hNrEdit1
               Options.zoneNr{1}=shouldBeNumber(Options.zoneNr{1},hObj,1);
           case hNrEdit2
               Options.zoneNr{2}=shouldBeNumber(Options.zoneNr{2},hObj,1);
           case hZDiameterEdit
               Options.zoneDiameter=shouldBeNumber(Options.zoneDiameter,hObj,1,[0,inf]);
           case hZDistEdit
               Options.zoneDistance=shouldBeNumber(Options.zoneDistance,hObj,1,[0,inf]);
           case hMinDistEdit
               Options.mindistance=shouldBeNumber(Options.mindistance,hObj,1,[0,inf]);
           case hReceptorDistEdit
               Options.minReceptorDistance=shouldBeNumber(Options.minReceptorDistance,hObj,1,[0,inf]);
           case hRPDistEdit
               Options.ReceptorParticleDistance(2)=shouldBeNumber(Options.ReceptorParticleDistance(2),hObj,1,[0,inf]);
           case hSimFitLowerEdit
               switch hSimFitLowerPopup.Value
                   case 4
                       nrRange=[0,100];
                   case 6
                       nrRange=[0,1];
                   otherwise
                       nrRange=[0,inf];
               end
               Options.bounds{1,2}=shouldBeNumber(Options.bounds{1,2},hObj,1,nrRange);
           case hSimFitUpperEdit
               switch hSimFitUpperPopup.Value
                   case 4
                       nrRange=[0,100];
                   case 6
                       nrRange=[0,1];
                   otherwise
                       nrRange=[0,inf];
               end
               Options.bounds{2,2}=shouldBeNumber(Options.bounds{2,2},hObj,1,nrRange);
       end
    end
    function selectBound(hObj, hEdit)
        if get(hObj, 'Value')==5
            set(hEdit, 'Visible', 'off');
        else
            set(hEdit, 'Visible', 'on');
        end
    end
    function changeVisibility(hOb,~)
        switch hOb
            case hExclusionZones
                handles=[hNrText1,hNrText2,hNrText3,hNrEdit1,hNrEdit2,hZDiameterText,hZDiameterEdit, ...
                        hZDistText, hZDistEdit, hPartNames, hExclPart, hExclPartText];
            case hTwoStep
                handles=[hReceptorDistText, hRPDistText, hReceptorDistEdit, hRPDistEdit];
        end
        set(handles,'Visible',hOb.Value);
    end
 

    function close(~,~)
        Options=Default;
        delete(gcf)  
    end
    function updateOptions(~,~)
        set(hEndlessLoop, 'Visible', 'off');
        Options.mindistance=str2double(hMinDistEdit.String);
        Options.bounds{1,1}=get(hSimFitLowerPopup, 'Value');
        Options.bounds{2,1}=get(hSimFitUpperPopup, 'Value');
        Options.bounds{1,2}=str2double(get(hSimFitLowerEdit, 'String'));
        Options.bounds{2,2}=str2double(get(hSimFitUpperEdit, 'String'));
        Options.fitdisttype=get(hSimFitDistType,'String');
        Options.fitdisttype=Options.fitdisttype{get(hSimFitDistType, 'Value')};
        if Options.bounds{1,1}==Options.bounds{2,1} && Options.bounds{1,2}>=Options.bounds{2,2}
            set(hEndlessLoop, 'Visible', 'on');
            return
        end
        Options.indivsave=get(hSaveIndiv, 'Value');
        Options.twoStep=hTwoStep.Value;
        if Options.twoStep
            Options.minReceptorDistance=str2double(hReceptorDistEdit.String);
            if strcmp(hRPDistEdit.String, strforsameasouterrim)
                Options.ReceptorParticleDistance(2)=-1;
            else
                Options.ReceptorParticleDistance(2)=str2double(hRPDistEdit.String);
            end
        end
        Options.exclZones=hExclusionZones.Value;
        if Options.exclZones
            for i=1:numel(hExclPart)
                Options.partExcl{i}=getSelectedStringFromPopup(hExclPart(i));
            end
        end
        Options.simOnDilation=hSimulateOnDD.Value-1;
        delete(gcf)
    end
   
end

