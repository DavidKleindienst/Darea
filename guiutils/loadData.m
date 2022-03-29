function Data = loadData(fileName)
%% Load analysis data saved in a .mat file
% Returns NaN if the loading fails
try
    Data=load(fileName);
catch
    Data=NaN;
    return
end

if isfield(Data, 'Data')    %If Data has been serialized prior to saving, deserialize it
    try
        Data=hlp_deserialize(Data.Data);
        %% Deserialization algorithm (C) 2012 by Christian Kothe
        %% License can be found at util/serialization/license.txt
    catch
        Data=NaN;
        return
    end
    
    if ~isfield(Data,'analysisName')
        Data.analysisName='';
    end
end

if ~isstruct(Data) || ~isfield(Data,'checksum')
    %Data is not what is expected
    Data=NaN;
end

end

