function projectSettings(datFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin==0
    [infoFile, folder] = uigetfile('*.dat');
    datFile=fullfile(folder,infoFile);
end

factory_defaults=readDefaults();
settingsFile=getOptionsName(datFile);
defaults=updateDefaults(settingsFile, factory_defaults);
userDefaults=updateDefaults(settingsFile);


diameter=defaults.particleTypes;
newDiameter=diameter;
positionMenu=[225 250 500 500];
Menu=figure('OuterPosition', positionMenu, 'Name', 'Particle Options', 'resize', 'Off', 'menubar', 'None', 'CloseRequestFcn', @close);

hNrText=uicontrol('Style', 'Text', 'Parent', Menu, 'String', 'Number of particle sizes', 'Position', [25 440 85 25], 'Tooltipstring', 'Choose number of particle kinds');
hNrPart=uicontrol('Style', 'Edit','Parent', Menu, 'String', num2str(numel(diameter)), 'Tooltipstring', 'Choose number of Particles', 'Callback', @nrChange, ...
                'Position', [110, 440, 30, 21]);

hParticlesText=uicontrol('Style', 'Text', 'Parent', Menu, 'String', 'Diameters', 'Tooltipstring', 'Please enter the Diameter (in nm) of each Particle', 'Position', [25 395 80 25]);
hParticles=cell(1, numel(diameter));
for d=1:numel(diameter)
  hParticles{d}=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', num2str(diameter(d)), 'Position', [105+(d-1)*45, 400 35 21], 'Callback', @(hObj, ~)changeNm(hObj, d), 'Tooltipstring', ['Please enter the Diamter of the ' num2str(d) 'th particle in nm']);
end
rimTT='Enter thickness of outer tim that should be included for detecting particles in nm. 0 means to not include any outer rim';
hOuterRimText=uicontrol('Style', 'Text', 'Parent', Menu, 'String', 'include Outer Rim of', 'Tooltipstring', rimTT, ...
                'Position', [25 360 110 15]);
hOuterRimEdit=uicontrol('Style', 'Edit', 'Parent', Menu, 'String', num2str(defaults.dilate), 'Tooltipstring', rimTT, ...
                'Position', [135 360 30 15],'Callback',@changeRim);
hOuterRimText2=uicontrol('Style', 'Text', 'Parent', Menu, 'String', 'nm', 'Tooltipstring', rimTT, ...
                'Position', [165 360 20 15]);           
hOnlyWithin=uicontrol('Style','checkbox', 'Parent', Menu, 'String', 'Strictly limit analysis to particles within area of interest (incl. outer rim)', ...
                    'Value', defaults.onlyParticlesWithin, 'Position', [25 330 380 20], 'Tooltipstring', ...
                    sprintf('If checked all particles where the center is outside of the area of interest will be discarded during analysis.\n They will still be visible in particle labeling screen'));
            
hOkMenu=uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Ok', 'Callback', @updateOptions, 'Position', [250 25 40 25]);
hCancelMenu= uicontrol('Parent', Menu, 'Style', 'pushbutton', 'String', 'Cancel', 'Callback', @close, 'Position', [325 25 40 25]);
hErrorPresent=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [175 50 265 15], 'ForegroundColor', 'red', 'FontWeight', 'bold', 'String', 'Cannot continue because Errors are present', 'Visible', 'Off');
hUniqueError=uicontrol('Parent', Menu, 'Style', 'Text', 'Position', [85 30 120 25], 'String', 'Particle Diameters must be unique!', 'ForegroundColor', 'red', 'FontWeight', 'bold', 'Visible', 'Off');

% Waits for the figure to close to end the function.
waitfor(Menu);
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions


%Changes number of particle kinds
function nrChange(hObj, ~)
   number=shouldBeNumber(numel(newDiameter),hObj,0,[1,inf]);
   if numel(newDiameter)==number
       return;
   end
   if number<numel(newDiameter)
       for i=number+1:numel(newDiameter)
          delete(hParticles{i})
       end
       hParticles(number+1:end)=[];
       newDiameter(number+1:end)=[];
   elseif number>numel(newDiameter)
       for i=numel(newDiameter)+1:number
          newDiameter(i)=0;
          hParticles{i}=uicontrol('Parent', Menu, 'Style', 'Edit', 'String', num2str(newDiameter(i)), 'Position', [105+(i-1)*45, 400 35 21], 'Callback', @(hObj, ~)changeNm(hObj, i), 'Tooltipstring', ['Please enter the Diamter of the ' num2str(i) 'th particle in nm']);
       end

   end
end

function changeRim(hObj,~)
    if isfield(userDefaults, 'dilate')
        userDefaults.dilate=shouldBeNumber(userDefaults.dilate,hObj,1,[0,inf]);
    else
        userDefaults.dilate=shouldBeNumber(defaults.dilate,hObj,1,[0,inf]);
    end
end

%Ensures that user input for diameter is valid
function changeNm(hObj,nr)
   newDiameter(nr)=shouldBeNumber(newDiameter(nr),hObj,1,[0,inf]);
end

%Returns 1 if two kinds of particles have same size
function logical=uniqueNumbers()
   numbers=[];
   for i=1:numel(hParticles)
       numbers(i)=str2double(get(hParticles{i}, 'String'));
   end
   if numel(numbers)==numel(unique(numbers))
       logical=0;
   else
       logical=1;
   end
end

%Closes figure and aborts changes
function close(~,~)
    delete(gcf)  
end
%Saves changes and closes figure
function updateOptions(~,~)
    
    if uniqueNumbers()
        set(hUniqueError, 'Visible', 'on');
    else
        for i=1:numel(newDiameter)
            newDiameter(i)=str2double(get(hParticles{i}, 'String'));
        end
        userDefaults.onlyParticlesWithin=get(hOnlyWithin,'Value');
        userDefaults.particleTypes=newDiameter;
        writeDefaults(settingsFile,userDefaults);
        delete(gcf)
    end
end

end

