function defaults = updateDefaults(filename, defaults)
%% Checks if option file exists and updates any defaults mentioned there

if exist(filename, 'file') == 2
    f=fopen(filename,'r');
    tline=fgetl(f);
    while ischar(tline)
        if ~isempty(tline) && ~strcmp(tline(1),'#')
            if contains(tline,'#')
                tline=strsplit(tline,'#');
                tline=tline{1};
            end
            s=strsplit(tline,'\t');
            if isempty(strfind(s{1},'.'))
                defaults.(s{1})=eval(s{2});
            else
                s1=strsplit(s{1},'.');
                defaults.(s1{1}).(s1{2})=eval(s{2});
            end
        end
        tline=fgetl(f);
    end
end

if ~exist('defaults','var')
    %Create struct with dummy field if it doesn't exist
    %Using a dummy field rather than empty struct avoids dot notation
    %errors
    defaults.dummy='dummy';
end
