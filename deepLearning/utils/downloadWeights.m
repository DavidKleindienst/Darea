function retValue = downloadWeights()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

serverpath='https://pub.ist.ac.at/~dkleindienst/weights/';
indexFile = 'networkList.csv';

    function path=getFullWebpath(path,file)
        %% Like fullfile, but for the webpaths and with only two arguments        
        path=fullfile(path,file);
        path=replace(path,'\', '/');
    end

try
    listedNetworks = webread(getFullWebpath(serverpath, indexFile));
    names = listedNetworks.Name;
    descriptions = listedNetworks.Description;
catch
    msgbox('Failed to load network list from server. Please check your internet connection', ...
            'Error', 'error');
    retValue = 0;
    return
end
nrNetworks = numel(names);
localpath='deepLearning/checkpoints/';
extensions={'.ckpt.data-00000-of-00001', '.ckpt.index', '.ckpt.meta','.info'};

networksInstalled = zeros(1,nrNetworks);
for n = 1:nrNetworks
    filesExist = zeros(1,numel(extensions));
    for ext = 1:numel(extensions)
        if isfile(fullfile(localpath, [names{n} extensions{ext}]))
            filesExist(ext) = 1;
        end
    end
    if all(filesExist)
        networksInstalled(n) = 1;
    end
end
if all(networksInstalled) && isfile('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt')
   msgbox('All available networks are already installed');
   retValue = 1;
   return
end
gridX = [35, 100, 145, 250, 455, 60];
ySpacingTop = 80;
ySpacingBetween = 20;
outerPosition = [150 200 600 220+(ySpacingBetween*nrNetworks)];

dlWindow = figure('OuterPosition',outerPosition , 'menubar', 'none', 'resize','off', ...
                  'Name','Download Networks','CloseRequestFcn', @cancel); 



hResnet = uicontrol('Style', 'checkbox', 'Position', [gridX(1), outerPosition(4)-ySpacingTop, gridX(2), 25],...
          'String', 'Resnet101', 'Enable', 'off');
uicontrol('Style', 'text', 'Position', [gridX(3), outerPosition(4)-ySpacingTop, gridX(4), 20], ...
          'String', 'Weights necessary for all networks.','HorizontalAlignment', 'left')
hResnetComment = uicontrol('Style', 'text', 'FontWeight', 'bold','HorizontalAlignment', 'left',  ...
                          'Position', [gridX(5), outerPosition(4)-ySpacingTop, gridX(6), 20]);
if isfile('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt')
    hResnetComment.String = 'Installed';
else
    hResnet.Value = 1;
    hResnetComment.String = 'Required';
end
hCheckboxes = gobjects(1,nrNetworks);
for n = 1:nrNetworks
    yPosition = outerPosition(4)-ySpacingTop-(ySpacingBetween*n);
    hCheckboxes(n) = uicontrol('Style', 'checkbox', 'String', names{n}, 'Position', ...
                        [gridX(1), yPosition , gridX(2), 25]);
    uicontrol('Style', 'text', 'String', descriptions{n}, 'Position', ...
              [gridX(3),yPosition, gridX(4), 20],'HorizontalAlignment', 'left');
    if networksInstalled(n)
        uicontrol('Style', 'text', 'FontWeight', 'bold', 'String', 'Installed', ...
                  'Position',[gridX(5), yPosition, gridX(6), 20],'HorizontalAlignment', 'left');
        hCheckboxes(n).Enable = 'off';
    end
end

hProgress=uicontrol('Style', 'Text', 'foregroundcolor', 'blue', 'Position', [200 55 180 35],...
                    'FontWeight', 'bold', 'FontSize', 13, 'HorizontalAlignment', 'center');
uicontrol('Style', 'pushbutton', 'String', 'Download', 'Callback', @doDownload, ...
           'Position', [140 35 100 25]);
uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Callback', @cancel,'Position', [340 35 100 25]);
                    
waitfor(dlWindow);

    function doDownload(~,~)
        toDownload = cell2mat(get(hCheckboxes,'Value'));
        if ~any(toDownload) && ~hResnet.Value
            msgbox('No network has been selected for download');
            return
        end
        hProgress.String = 'Starting Downloads...';
        drawnow();
        if hResnet.Value
            hProgress.String = 'Downloading Resnet101...';
            drawnow();
            try
                websave('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt', ... 
                        getFullWebpath(serverpath, 'resnet_v2_101.ckpt'));
            catch excpt
                if isfile('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt')
                    delete('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt');
                end
                hProgress.String='Download failed!';
                rethrow(excpt);
            end
        end
        for net = 1:nrNetworks
            hProgress.String = sprintf(['Downloading ' names{net} '...']);
            drawnow();
            if ~toDownload(net)
                continue
            end
            try
                for ex=1:numel(extensions)
                    websave(fullfile(localpath, [names{net} extensions{ex}]),...
                            getFullWebpath(serverpath, [names{net} extensions{ex}]));
                end
            catch excpt
                for ex=1:numel(extensions)
                    if isfile(fullfile(localpath, [names{net} extensions{ex}]))
                        delete(fullfile(localpath, [names{net} extensions{ex}]));
                    end
                end

                hProgress.String='Download failed!';
                drawnow();
                rethrow(excpt);
            end
        end
        msgbox('Finished downloading');
        retValue=1;
        delete(dlWindow);
    end

    function cancel(~,~)
        retValue = 0;
        delete(dlWindow);
    end
    
end

