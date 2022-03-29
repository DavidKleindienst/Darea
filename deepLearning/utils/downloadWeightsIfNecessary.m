function  retValue=downloadWeightsIfNecessary(force)
%% Downloads pretrained weights
%retValue 1->Weights exist or have been succesfully downloaded
%retValue 0->Weights don't exist and couldn't be downloaded
%force-> download files even though some or all already exist

if nargin==0
    force=false;
end

if ~force && ~isempty(getTrainedNetworks())
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

retValue=downloadWeights();

end