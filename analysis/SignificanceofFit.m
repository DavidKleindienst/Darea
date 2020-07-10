%% Not yet implemented into program

function SignificanceofFit(Data, settings)
%SIGNIFICANCEOFFIT Summary of this function goes here
%   Detailed explanation goes here

pthresh=0.05;
radius=[2.5,5];
methodA=Data.methodA;
methodB=Data.methodB;
Groups=Data.Groups;
Orig=Data.Orig;
nrsim=Data.nrsim;
nrImg=numel(Orig.Images);
Grplabels=[settings.allGroupsname; Groups.names];
for mode=1:2
    if mode==1
        distfield='distances';
        diststring='NNDs';
    else
        distfield='allDistances';
        diststring='all Distances';
    end
    for r=radius
        AA=[methodA{:}]==r;
        BB=find(cellfun(@(cell) isequaln(cell, {r,NaN}), methodB));
        fprintf(['For fitting' num2str(r) ', the comparison of ' diststring ':\n']);

        for g=0:Groups.number
            if g>0
                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
            else
                indeces=1:nrImg;
            end
        
      

            realpvals=NaN(1,numel(indeces));
            tobeRemoved=[];
            counter=0;
            for i=1:numel(indeces)
                rDist=Orig.Distance{BB}{indeces(i)}.(distfield);
                sp=NaN(1,nrsim);
                if ~all(isnan(rDist))
                    for snr=1:nrsim
                        [~,sp(snr)]=kstest2(rDist, Data.SimFit{AA}.IndivDist{BB}{snr}{indeces(i)}.(distfield));
                        if ~isnan(sp(snr)) && sp(snr)<pthresh
                            counter=counter+1;
                        end
                    end
                end
                sp=mean(sp);
                if isnan(sp)
                   tobeRemoved(end+1)=i;
                else
                    realpvals(i)=sp;
                end
            end
            realpvals(tobeRemoved)=[];
            percentage=100*counter/(nrsim*numel(indeces));
            fprintf([Grplabels{g+1} ': mean pvalue: ' num2str(mean(realpvals)) '; percentage of Significant pvalues: ' num2str(percentage) ' Percent\n']);

        end
        fprintf('\n');
    end 
end


end

