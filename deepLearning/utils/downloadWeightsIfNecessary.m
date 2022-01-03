function  retValue=downloadWeightsIfNecessary(force)
%% Downloads pretrained weights
%retValue 1->Weights exist or have been succesfully downloaded
%retValue 0->Weights don't exist and couldn't be downloaded
%force-> download files even though some or all already exist

if nargin==0
    force=false;
end

retValue=0;
if ~force && isfile('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt') && ...
                ~isempty(getTrainedNetworks())
    retValue=1;
    return;
    %Weights already exist, no need to download
end
answer=questdlg(sprintf('Pre-trained neural networks need to be downloaded to proceed.\nShould they be downloaded now?'), ...
                    'Download networks?','yes','no','no');
if strcmp(answer,'no')
    retValue=0;
    return;
end
msg=msgbox('Downloading pre-trained networks...');

serverpath='https://pub.ist.ac.at/~dkleindienst/weights/';
try
    websave('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt',[serverpath 'resnet_v2_101.ckpt']);
catch
    if isfile('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt')
        delete('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt');
    end
    retValue=0;
    delete(msg);
    msgbox('Download failed!');
    return;
end

localpath='deepLearning/checkpoints/';
networks={'AZ','PSD'};
extensions={'.ckpt.data-00000-of-00001', '.ckpt.index', '.ckpt.meta','.info'};
preTrained={};
for n=1:numel(networks)
    for e=1:numel(extensions)
        preTrained{end+1}=[networks{n} extensions{e}];
    end
end

try
    for i=1:numel(preTrained)
        websave([localpath preTrained{i}], [serverpath preTrained{i}]);
    end
catch
    for i=1:numel(preTrained)
        if isfile([localpath preTrained{i}])
            delete([localpath preTrained{i}]);
        end
    end
    if isfile('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt')
        delete('python/SemanticSegmentationSuite/models/resnet_v2_101.ckpt');
    end
    retValue=0;
    delete(msg);
    msgbox('Download failed!');
    return;
end
%Needs check whether file hash is correct here!!
 
delete(msg);
msgbox('Finished downloading');
retValue=1;

end