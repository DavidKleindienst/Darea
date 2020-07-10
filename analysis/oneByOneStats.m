%
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria - Klosterneuburg - Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

function oneByOneStats(Data,settings, outpath, dist_names)
%% Compares distances of original Data to simulations individually (i.e. no pooling accross simulations) for each image seperately
%Input parameters:
%Data - Struct that has been made with performAnalysis(). Contains all the Data.
%settings - User defined parameters
%outpath - Path to folder where results will be saved to

%Simplification
simnames=Data.simnames;
methodA=Data.methodA;
methodB=Data.methodB;
Groups=Data.Groups;
Orig=Data.Orig;
nrsim=Data.nrsim;

statfct=settings.StatisticsOptions.statfct;
pval=settings.StatisticsOptions.pval;
dist_names=dist_names(1:numel(Data.distfields));
fields=cell(1,numel(dist_names)); 
for d=1:numel(dist_names)
    fields{d}=[dist_names{d} 'mean'];
end
nrImg=numel(Orig.Images);

%First compute significance for individual images and rearrange data into struct Imwise
Imwise=cell(nrImg,1);
for img=1:nrImg     %For all images
    for b=1:numel(methodB)      %For all types of Distances (A->B, A->A, B->A, ...)
        for d=1:numel(Data.distfields)
            Imwise{img}.Orig.(fields{d}){b}=statfct(Orig.Distance{b}{img}.(Data.distfields{d}));   %It is called mean, but can also be median depending on user settings
            for s=1:numel(simnames)     %For all types of simulation
                for a=1:numel(methodA)  %for all particle sizes simulated
                    current=Data.(simnames{s}){a};
                    Imwise{img}.(simnames{s}){a}.(fields{d}){b}=NaN(1,nrsim);

                    for n=1:nrsim   %For all individual simulations
                        Imwise{img}.(simnames{s}){a}.(fields{d}){b}(n)=statfct(current.IndivDist{b}{n}{img}.(Data.distfields{d}));
                    end

                    simulated=Imwise{img}.(simnames{s}){a}.(fields{d}){b};
                    sample=Imwise{img}.Orig.(fields{d}){b}; 
                    [diff,smaller,greater]=getSignificance(sample,simulated, pval);  %Test whether this image is significantly different from simulations
                    
                    Imwise{img}.(simnames{s}){a}.(['Sigmean' dist_names{d} 'SMALLER']){b}=smaller;
                    Imwise{img}.(simnames{s}){a}.(['Sigmean' dist_names{d} 'GREATER']){b}=greater;
                    Imwise{img}.(simnames{s}){a}.(['Sig' dist_names{d} 'mean']){b}=diff;                    
                end
            end
        end
    end
end

%Then generate output from the Imwise struct
header=['Original;Simulation;Percent Significant (' func2str(statfct) ');Greater Than (' func2str(statfct) '); Smaller Than(' func2str(statfct) ');pValue;N;totalImages\n'];
Grplabels=[settings.allGroupsname; Groups.names];
for mode=1:numel(Data.distfields) 
%if (mode==1 && settings.StatisticsOptions.makeNND) || (mode==2 && settings.StatisticsOptions.makeAllDist) 
    filename=fullfile(outpath,[dist_names{mode} '_1by1.csv']);
    fields={['Sig' dist_names{mode} 'mean'], ['Sigmean' dist_names{mode} 'GREATER'], ['Sigmean' dist_names{mode} 'SMALLER']};
    file=fopen(filename, 'wt');
    fprintf(file, header);
    for g=0:Groups.number           %for all groups
        if g>0
            indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        else            %g=0 - sum over all groups
            indeces=1:nrImg;
        end
        for s=1:numel(simnames)     %For all types of simulation
            for a=1:numel(methodA)  %For all simulated particle types
                for b=1:numel(methodB)      %For all types of distances (A->A, B->A, A->B, ...)
                    if Data.isPairedField(mode) || isnan(methodB{b}{2}) 
                        sigsMean=NaN(1,numel(indeces));
                        sigGreater=NaN(1,numel(indeces));
                        sigSmaller=NaN(1,numel(indeces));
                        for img=1:numel(indeces)        %For all images belonging to the group
                            sigsMean(img)=Imwise{indeces(img)}.(simnames{s}){a}.(fields{1}){b};
                            sigGreater(img)=Imwise{indeces(img)}.(simnames{s}){a}.(fields{2}){b};
                            sigSmaller(img)=Imwise{indeces(img)}.(simnames{s}){a}.(fields{3}){b};
                        end
                        NN=numel(sigsMean) - numel(sigsMean(isnan(sigsMean))); %Number of images used in analysis (i.e. the ones containing Data)
                        Sign=numel(sigsMean(sigsMean==1));
                        pdiff=myBinomTest(Sign, NN, pval, 'two');         %Test whether significantly more images than expected show a significant difference
                        %% myBinomTest() Copyright (c) 2015, Matthew Nelson
                        %% License can be found at util/myBinomTest/license.txt
                    
                        fprintf(file, [Grplabels{g+1} '-' getName(Data, methodB{b}) ';' simnames{s} getName(Data,methodA{a}) ';' num2str(100*numel(sigsMean(sigsMean==1))/(numel(indeces) - numel(sigsMean(isnan(sigsMean))))) ';' num2str(100*numel(sigGreater(sigGreater==1))/(numel(indeces) - numel(sigGreater(isnan(sigGreater))))) ';' num2str(100*numel(sigSmaller(sigSmaller==1))/(numel(indeces) - numel(sigSmaller(isnan(sigSmaller))))) ';' num2str(pdiff) ';' num2str(NN) ';' num2str(numel(sigsMean)) '\n']);
                    end
                end
            end
        end
    end
    fclose(file);
end   
end

