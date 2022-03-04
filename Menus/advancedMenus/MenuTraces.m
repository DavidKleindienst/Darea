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

function [Grouptraces, NNDtraces, Clustertraces, Simulationtraces] = MenuTraces(Default, Data, settings)
%% Opens a menu to select Traces for which figures should be made

if numel(Data.methodB)<=8
    figurePos=[120 220 500 300];
    heightBase=0;
else        %Adjust figure height if too many particles exist
    figurePos=[120 120 500 300+25*(numel(Data.methodB)-8)];
    heightBase=25*(numel(Data.methodB)-8);
end
    

TraceMenu=figure('OuterPosition', figurePos, 'Name', 'Select Traces', 'menubar', 'None', 'CloseRequestFcn', @close);

hGroupTracesText=uicontrol('Parent', TraceMenu, 'Style', 'Text', 'Position', [25 heightBase+245 80 25], 'String', 'Groups', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
hGroupTraces=cell(Data.Groups.number+1,1);
hGroupTraces{1}=uicontrol('Parent', TraceMenu, 'Style', 'CheckBox', 'Position', [35 heightBase+225 80 25], 'String', settings.allGroupsname);
for t=2:numel(hGroupTraces)
    hGroupTraces{t}=uicontrol('Parent', TraceMenu, 'Style', 'CheckBox', 'Position', [35 heightBase+250-25*t 80 25], 'String', Data.Groups.names{t-1});
end
for t=1:numel(hGroupTraces)
    if ~ismember(get(hGroupTraces{t}, 'String'), Default{1})
        set(hGroupTraces{t}, 'Value', 1);
    end
end

hNNDTracesText=uicontrol('Parent', TraceMenu, 'Style', 'Text', 'Position', [125 heightBase+245 130 25], 'String', 'NND-Traces', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
hNNDTraces=cell(numel(Data.methodB),1);
for t=1:numel(hNNDTraces)
   hNNDTraces{t}=uicontrol('Parent', TraceMenu, 'Style', 'CheckBox', 'Position', [135 heightBase+250-25*t 130 25], 'String', getName(Data,Data.methodB{t})); 
   if ~ismember(get(hNNDTraces{t}, 'String'), Default{2})
       set(hNNDTraces{t}, 'Value', 1);
   end
end

hClusterTracesText=uicontrol('Parent', TraceMenu, 'Style', 'Text', 'Position', [275 heightBase+245 80 25], 'String', 'Cluster-Traces', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
hClusterTraces=cell(numel(Data.methodA),1);
for t=1:numel(hClusterTraces)
   hClusterTraces{t}=uicontrol('Parent', TraceMenu, 'Style', 'CheckBox', 'Position', [285 heightBase+250-25*t 80 25], 'String', getName(Data,Data.methodA{t})); 
   if ~ismember(get(hClusterTraces{t}, 'String'), Default{3})
       set(hClusterTraces{t}, 'Value', 1);
   end
end

simOrignames=[{settings.Origname}, settings.SimNames(:)'];
hSimulationTracesText=uicontrol('Parent', TraceMenu, 'Style', 'Text', 'Position', [375 heightBase+245 100 25], 'String', 'Simulation-Traces', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
hSimulationTraces=cell(numel(simOrignames),1);
for t=1:numel(hSimulationTraces)
    hSimulationTraces{t}=uicontrol('Parent', TraceMenu, 'Style', 'CheckBox', 'Position', [375 heightBase+250-25*t 80 25], 'String', simOrignames{t}); 
    if ~ismember(get(hSimulationTraces{t}, 'String'), Default{4})
       set(hSimulationTraces{t}, 'Value', 1);
    end
end

hAlright=uicontrol('Parent', TraceMenu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @alright, 'Position', [250 25 40 25]);
hCancel= uicontrol('Parent', TraceMenu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
set(findall(mainFigure, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

waitfor(TraceMenu);
%% Functions
    %Closes figures and aborts changes
    function close(~,~)
       Grouptraces=Default{1};
       NNDtraces=Default{2};
       Clustertraces=Default{3};
       Simulationtraces=Default{4};
       delete(TraceMenu);
    end
    
    %Saves changes and closes figure
    function alright(~,~)
        Grouptraces={};
        for t=1:numel(hGroupTraces)
            if get(hGroupTraces{t}, 'Value')==0
                Grouptraces{end+1}=get(hGroupTraces{t}, 'String');
            end
        end
        NNDtraces={};
        for t=1:numel(hNNDTraces)
            if get(hNNDTraces{t}, 'Value')==0
                NNDtraces{end+1}=get(hNNDTraces{t}, 'String');
            end
        end
        Clustertraces={};
        for t=1:numel(hClusterTraces)
            if get(hClusterTraces{t}, 'Value')==0
                Clustertraces{end+1}=get(hClusterTraces{t}, 'String');
            end
        end
        Simulationtraces={};
        for t=1:numel(hSimulationTraces)
            if get(hSimulationTraces{t}, 'Value')==0
                Simulationtraces{end+1}=get(hSimulationTraces{t}, 'String');
            end
        end
        delete(TraceMenu);
    end

end

