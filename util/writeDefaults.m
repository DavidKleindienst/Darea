function writeDefaults(filename,defaults)
if isfield(defaults,'dummy')
    %remove a dummy field if it exists
    defaults=rmfield(defaults,'dummy');
end
file = fopen(filename,'w');
printStruct(file,defaults);
fclose(file);


function printStruct(fid,struct,prefix)
    %Needs to be separate function to allow for recursiveness
    if nargin<3
        prefix='';
    else
        prefix=[prefix '.'];
    end
    fields=fieldnames(struct);
    for i=1:numel(fields)
        if i>1
            fprintf(fid, '\n');
        end
        val=struct.(fields{i});
        if isstruct(val)
            printStruct(fid,val,[prefix fields{i}]);
        else
            fprintf(fid, [prefix fields{i} '\t']);
            string=reverse_eval(val);
            fprintf(fid, string);
        end
    end
end


end

