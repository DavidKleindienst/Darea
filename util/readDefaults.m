function defaults = readDefaults(config)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

f=fopen('configDefault_options.dat','r');
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

if nargin>0
    defaults=updateDefaults(getOptionsName(config),defaults);
end
fclose(f);
