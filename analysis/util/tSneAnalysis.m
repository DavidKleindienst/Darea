function tSneAnalysis(Data,Groups,settings,outpath)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
methodA=Data.methodA; methodB=Data.methodB;
if isequal(methodA{1}, 'all')
    %Remove all for this analysis
    methodA(1)=[]; 
    methodB(1)=[];
end
numVar=1+numel(methodA)+2*numel(methodB);
values=zeros(Data.nrImages,numVar);
if ~iscell(Groups)
    %Allows using the struct as input argument when there is only one variety to be checked
    Groups={Groups};
end
for i=1:Data.nrImages
    values(i,1)=Data.Orig.Images{i}.area;
    for a=1:numel(methodA)
        values(i,1+a)=Data.Orig.PartCount.counts(i,a);
    end
    for b=1:numel(methodB)
        values(i,1+a+b)=mean(Data.Orig.Distance{b}{i}.distances);
        values(i,1+a+b+numel(methodB))=mean(Data.Orig.Distance{b}{i}.relativeDistanceFromCenter).^2;
    end
    
end

values(:,all(isnan(values)))=[];
%Scale the Data
orig_values=values;
values=fillmissing(values,'constant',0);
values=values-mean(values);
stds=std(values);

for c=1:size(values,2) 
    values(:,c)=values(:,c)./(stds(c)+1e-8);
end
Y=tsne(values);

for group=1:numel(Groups)
    g=num2cell(Groups{group}.imgGroup);
    gn=cellfun(@(x)Groups{group}.names{x},g,'UniformOutput',false);
    plotTSne(fullfile(outpath, sprintf('%s_tSNE', Groups{group}.groupings{1})));
end

particles=orig_values(:,2:numel(methodA)+1);
removeIndeces=any(particles==0,2);

Data.Orig.Images(removeIndeces)=[]; values(removeIndeces,:)=[]; orig_values(removeIndeces,:)=[];

Y=tsne(values);
for group=1:numel(Groups)
    g=num2cell(Groups{group}.imgGroup);
    gn=cellfun(@(x)Groups{group}.names{x},g,'UniformOutput',false);
    gn(removeIndeces)=[];
    plotTSne(fullfile(outpath, sprintf('%s_tSNE_rem', Groups{group}.groupings{1})));
end

    function plotTSne(fname)
        
        fig=figure('Visible','off');
        gscatter(Y(:,1),Y(:,2),gn);
        savePlot(fig,fname, settings.figformat);
        delete(fig);
        fid=fopen([fname '.csv'],'w');        
        %Print Header
        fprintf(fid,'Image;Group;tSne_X;tSne_Y;Area');
        for a=1:numel(methodA); fprintf(fid,';%gnm',methodA{a}); end
        for b=1:numel(methodB); fprintf(fid,';NND_%s', methodBName(methodB{b})); end
        for a=1:numel(methodA); fprintf(fid,';EdgeIndex_%g',methodA{a}); end

        %print data
        for i=1:numel(Data.Orig.Images)
            fprintf(fid, '\n%s;%s;%g;%g', Data.Orig.Images{i}.route,gn{i}, Y(i,:));
            fprintf(fid, repmat(';%g',1,size(orig_values,2)), orig_values(i,:));
            %g;%g;%g;%g;%g;%g;%g;%g;%g'
        end
        fclose(fid);

    end

    function str=methodBName(mB)
        if isnan(mB{2})
            str=sprintf('%g',mB{1});
        else
            str=sprintf('%g to %g',mB{1},mB{2});
        end
    end
end