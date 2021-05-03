function results= imageChooser(title,explanation,strings,hotkeys,configpath,showDemarcation,adjustContrast)
%UNTITLED Summary of this function goes here
% Neccessary Arguments:
% title: Title shown to user
% explanation: explanation shown to user
% strings: cell array of strings, each corresponding to a choice
% Optional Arguments (NaN can be supplied to leave any argument unspecified):
% hotkeys: cell array of hotkeys for each choice. Has to be same length as
%           strings, if specified. 
% configpath: path to configfile. User will be asked if not specified

%Disable some warning:
warning('off','images:initSize:adjustingMag');

screenSize = get(0,'Screensize');

if nargin<5 || all(isnan(configpath))
    [f,p]=uigetfile('*.dat');
    configpath=fullfile(p,f);
end
if nargin>3 && (isnumeric(hotkeys)||islogical(hotkeys)) && hotkeys
    %Autogenerate hotkeys
    hotkeys=cell(size(strings));
    for i=1:size(strings,1)
        used={''};
        for j=1:size(strings,2)
           st=strings{i,j};
           for l=1:numel(st)
               if ~ismember(used,lower(st(l)))
                   used{end+1}=lower(st(l));
                   hotkeys{i,j}=lower(st(l));
                   break
               end
           end
        end
    end
elseif nargin>3 && iscell(hotkeys) && numel(strings)~=numel(hotkeys)
    error('Arguments strings and hotkeys need to contain same number of elements');
end
images=readConfig(configpath);
impath=fileparts(configpath);
if numel(images)==0; error('Specified ConfigFile is empty'); end


if nargin<7
    adjustContrast=false;
end
if nargin<4
    hotkeys=NaN;
end
%Dummy Variables to be filled later
imFig=gobjects(1,1);
choiceMenu=gobjects(1,1);
% User Interface:
nrQuestions=size(strings,1);
maxnrChoices=size(strings,2);
results=cell(numel(images),1+nrQuestions);
pos=[10 40 150+maxnrChoices*100 200];
% Loop through images:
i=1;
while ~isnan(i) && i<=numel(images) 
    imFig=figure('CloseRequestFcn', '', 'Name', images{i}, 'Visible', 'off');
    imRoute=fullfile(impath,images{i});
    [dem,im]=getBaseImages([imRoute '.tif'], [imRoute '_mod.tif'],NaN,0);
    if adjustContrast
        im=imadjust(im);
    end
    if showDemarcation
       im(dem)=im(dem).*0.8;
    end
    imshow(im);
    currPos=get(imFig,'Position');
    set(imFig, 'Position',[screenSize(3)/2 3*screenSize(4)/4, currPos(3), currPos(4)], 'Visible', 'on');
    
    for q=1:nrQuestions
        if isnan(i); break; end
        chs=strings(q,:);
        chs=chs(~cellfun(@isempty,chs));
        makeChoices(chs);
        figure(choiceMenu);
        waitfor(choiceMenu);
    end
end

delete(choiceMenu);

    function makeChoices(chs)
        choiceMenu=figure('OuterPosition', pos ,'menubar', 'none', 'resize','off', 'Name', title, 'CloseRequestFcn', @cancel, 'KeyReleaseFcn',@keyRelease);
        uicontrol('Style','Text', 'String', explanation, 'Position', [20 130 200 30]);
        hBack=uicontrol('Style', 'pushbutton', 'String', 'Back', 'Position', [20, 55 50 25], 'Callback', @back);
        hCancel=uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', [120, 55 50 25], 'Callback', @cancel);

        nrChoices=numel(chs);
        choices=gobjects(1,nrChoices);
        for c=1:nrChoices
            if iscell(hotkeys)
                str=[strings{q,c} ' [' hotkeys{q,c} ']'];
            else
                str=strings{q,c};
            end
                
            choices(c)=uicontrol('Style', 'pushbutton', 'String', str, 'Position', [20+95*(c-1) 100 85 30], ...
                                'Callback', @makeChoice);
            addprop(choices(c),'choicename');
            choices(c).choicename=strings{q,c};
        end
    end

    function cancel(~,~)
        i=NaN;
        results=NaN;
        delete(imFig);
        delete(choiceMenu);
    end
    function makeChoice(hObj,~)
        doChoice(hObj.choicename);
    end
    function doChoice(st)
        results{i,1}=images{i};
        results{i,q+1}=st;
        if q==nrQuestions
            i=i+1;
            delete(imFig);
        end
        delete(choiceMenu);
    end
    function keyRelease(~,key)
        if ~iscell(hotkeys)
            return
        end
        hks=hotkeys(q,:);
        hks=hks(~cellfun('isempty',hks));
        k=ismember(hks,key.Key);
        if any(k)
            doChoice(strings{q,k})
        end
    end
    function back(~,~)
       i=i-1;
       if i<1; i=1; end
       delete(imFig);
       delete(choiceMenu);
    end
    

end

