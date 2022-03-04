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

function Options=MenuClusterNaming(Data,Default)
% Opens advanced option menu for choosing name of Cluster parameters
   Options=Default;
   allParameters=fieldnames(Data.Orig.ClusterInteraction{1});
   allParameters=allParameters(3:end);
   positionMenu=[225 250 400 400];
   Menu=figure('OuterPosition', positionMenu, 'Name', 'Cluster Parameter Menu', 'menubar', 'None', 'CloseRequestFcn', @close);
   hCheckbox=cell(numel(allParameters));
   hEdit=cell(numel(allParameters));
   %Make checkboxes and namefields for all the parameters
   for f=1:numel(allParameters)
       hCheckbox{f}=uicontrol('Parent', Menu, 'Style', 'checkBox', 'String', allParameters{f}, 'Position', [25 370-30*f 110 25]);
       hEdit{f}=uicontrol('Parent', Menu, 'Style', 'Edit', 'Position', [135 372-30*f, 150 21]);
       if ismember(allParameters{f}, Default)
           set(hCheckbox{f}, 'Value', 1);
           set(hEdit{f}, 'String', Default{cellfun(@(x) strcmp(allParameters{f}, x), Default(:,1)),2});
       else
           set(hEdit{f}, 'String', allParameters{f})
       end
   end

   hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
   hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
   hNotUniqueError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [125 50 260 25], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'String', 'Cluster Parameter names have to be unique, because they are used as filenames as well!', 'Visible', 'Off');

   set(findall(Menu, '-property', 'Units'), 'Units', 'Normalized');    %Make objects resizable

   % Waits for the figure to close to end the function.
    waitfor(Menu);
    
    %Checks if all names are unique
    function logical=uniqueNames()
        allNames={};
        for i=1:numel(hCheckbox)
            if get(hCheckbox{i}, 'Value')==1
                allNames{end+1}=get(hEdit{i}, 'String');
            end
        end
        if numel(unique(allNames))==numel(allNames)     %If all names are unique
            logical=1;
        else
            logical=0;
        end
    end
   
    %Closes figure and aborts changes
    function close(~,~)
        Options=Default;
        delete(gcf)  
    end
    %Saves changes and closes figure
    function updateOptions(~,~)
        if uniqueNames()==0
            set(hNotUniqueError, 'Visible', 'on');
        else
            Options={};
            for i=1:numel(hCheckbox)
                if get(hCheckbox{i}, 'Value')==1
                    Options(end+1,:)={allParameters{i}, get(hEdit{i}, 'String')};
                end
            end
            delete(gcf)
        end

    end
   
end

