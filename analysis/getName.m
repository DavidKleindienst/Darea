function name=getName(Data,input)
%% Find correct Name for the particle type or type of interparticle distance

if iscell(input)        %input is of type methodB (i.e. interparticle distance type)
    if strcmp(input{1},'all')
        name=Data.allName;
    elseif isnan(input{2})      %Intratype distance
        name=Data.names{Data.radii==input{1}};
    else                        %Intertype distance
        name=[Data.names{Data.radii==input{1}}, ' to ' Data.names{Data.radii==input{2}}];
    end
else                    %input is of type methodA (i.e. particle type)
    if strcmp(input,'all')
        name=Data.allName;
    else
        name=Data.names{Data.radii==input};
    end
end