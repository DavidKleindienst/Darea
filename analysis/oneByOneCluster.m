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


function oneByOneCluster(Data,settings,outpath)
%% Compares Cluster paramters of original Data to simulations individually (i.e. no pooling accross simulations) for each image seperately
%Input parameters:
%Data - Struct that has been made with performAnalysis(). Contains all the Data.
%settings - User defined parameters
%outpath - Path to folder where results will be saved to

%Simplification
simnames=Data.simnames;
methodA=Data.methodA;
Groups=Data.Groups;
Orig=Data.Orig;
nrsim=Data.nrsim;
statOptions=settings.StatisticsOptions;

statfct=statOptions.statfct;    %Statistical function that will be used (Options are @mean and @median), To simplify the comments from now on I will write mean. But depending on the funciton chosen, it could also mean median.
pval=statOptions.pval/2;        %PValue below which results will be significant. /2 because a two-sided test will be performed
nrImg=numel(Orig.Images);
fields=settings.ClusterNames(:,1);

%First assess whether each image is signficantly different from its simulations.
%Collect the Data in 

for f=1:numel(fields)       %For all cluster parameters
    Imwise=cell(nrImg,1);
    for img=1:nrImg         %For all images
        if numel(Orig.ClusterInteraction{img}.(fields{f}))==numel(methodA)      %Cluster parameters that only relate to a single particle size (most of them)
            for a=1:numel(methodA)
                Imwise{img}.Orig{a}=statfct(Orig.ClusterInteraction{img}.(fields{f}){a});   %compute mean of that original image
                for s=1:numel(simnames)      %For all simulation types
                    for sim=1:numel(methodA)    %For all simulated particle sizes
                        current=Data.(simnames{s})(1,sim);
                        current=current{1};
                        Imwise{img}.(simnames{s}){sim}.mean{a}=NaN(1,nrsim);    
                        for n=1:nrsim       %For each individual simulation
                           Imwise{img}.(simnames{s}){sim}.mean{a}(n)=statfct(current.IndivClustInteraction{n}{img}.(fields{f}){a}); %Get mean of simulation
                        end
                        %Is the image signficantly different from simulations?
                        [Imwise{img}.(simnames{s}){sim}.sig{a}, Imwise{img}.(simnames{s}){sim}.smaller{a}, Imwise{img}.(simnames{s}){sim}.greater{a}]...
                                =getSignificance(Imwise{img}.Orig{a},Imwise{img}.(simnames{s}){sim}.mean{a},pval);      
                        
                    end
                end
            end
        else             %Cluster paramters of form from particle type A to particle type B (Overlap and intercluster Distance)
            for a=1:numel(methodA)
                for b=1:numel(methodA)
                    if a~=b             %For all pairs of different particle sizes A->B, B->A but not A->A or B->B.
                        Imwise{img}.Orig{a,b}=statfct(Orig.ClusterInteraction{img}.(fields{f}){a,b});       %Mean of Original Data
                        for s=1:numel(simnames)     %For all simulation types
                            for sim=1:numel(methodA)    %For all types of simulated particles
                                current=Data.(simnames{s})(1,sim);
                                current=current{1};
                                Imwise{img}.(simnames{s}){sim}.mean{a,b}=NaN(1,nrsim);
                                for n=1:nrsim       %For all individual simulations
                                   Imwise{img}.(simnames{s}){sim}.mean{a,b}(n)=statfct(current.IndivClustInteraction{n}{img}.(fields{f}){a,b});     %simulation means
                                end
                                %Is the image significantly different from simulations?
                                [Imwise{img}.(simnames{s}){sim}.sig{a,b}, Imwise{img}.(simnames{s}){sim}.smaller{a,b}, Imwise{img}.(simnames{s}){sim}.greater{a,b}]...
                                        =getSignificance(Imwise{img}.Orig{a,b},Imwise{img}.(simnames{s}){sim}.mean{a,b},pval);
                            end
                        end
                    end
                end
            end
        end
    end
    
    header=['Original;Simulation;Percent Significant (' func2str(statfct) ');Greater Than (' func2str(statfct) '); Smaller Than(' func2str(statfct) ');pValue;N;totalImages\n'];
    Grplabels=[settings.allGroupsname; Groups.names];
    
    filename=fullfile(outpath, [fields{f} '_1by1.csv']);
    %Open file to save Data
    file=fopen(filename, 'wt');
    fprintf(file,header);
    for g=0:Groups.number           %For all Groups
        if g>0
            indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        else            %g==0 -> All groups together
            indeces=1:nrImg;
        end
        if numel(Orig.ClusterInteraction{1}.(fields{f}))==numel(methodA) %Cluster parameters that only relate to a single particle size (most of them)
            for a=1:numel(methodA)      %For all particle sizes
                for s=1:numel(simnames)         %For all simulation types
                    for sims=1:numel(methodA)       %For all simulated particles 
                        sigsMean=NaN(1,numel(indeces));
                        sigGreater=NaN(1,numel(indeces));
                        sigSmaller=NaN(1,numel(indeces));
                        for img=1:numel(indeces)        %For all images belonging to the respective group
                            sigsMean(img)=Imwise{indeces(img)}.(simnames{s}){sims}.sig{a};
                            sigGreater(img)=Imwise{indeces(img)}.(simnames{s}){sims}.greater{a};    
                            sigSmaller(img)=Imwise{indeces(img)}.(simnames{s}){sims}.smaller{a};
                        end
                        NN=numel(sigsMean) - numel(sigsMean(isnan(sigsMean)));  %Number of images that contained Data on the tested parameter (i.e. parameter is not NaN)
                        Sign=numel(sigsMean(sigsMean==1));
                        pdiff=myBinomTest(Sign, NN, pval*2, 'two');     %Is number of significant images significantly different from expectations? Expectation: pvalue*100% of images should be signficant.
                        %% myBinomTest() Copyright (c) 2015, Matthew Nelson
                        %% License can be found at util/myBinomTest/license.txt
                        
                        %Write Output
                        fprintf(file, [Grplabels{g+1} '-' getName(Data, methodA{a}) ';' simnames{s} getName(Data,methodA{sims}) ';' num2str(100*numel(sigsMean(sigsMean==1))/(numel(indeces) - numel(sigsMean(isnan(sigsMean))))) ';' num2str(100*numel(sigGreater(sigGreater==1))/(numel(indeces) - numel(sigGreater(isnan(sigGreater))))) ';' num2str(100*numel(sigSmaller(sigSmaller==1))/(numel(indeces) - numel(sigSmaller(isnan(sigSmaller))))) ';' num2str(pdiff) ';' num2str(NN) ';' num2str(numel(sigsMean)) '\n']);

                    end
                end
            end
        else        %Cluster paramters of form from particle type A to particle type B (Overlap and intercluster Distance)
            for a=1:numel(methodA)
                for b=1:numel(methodA)
                    if a~=b                 %For all pairs of different particle sizes A->B, B->A but not A->A or B->B.
                        for s=1:numel(simnames)         %For all types of simulation
                            for sims=1:numel(methodA)   %For all simulated particle sizes
                                sigsMean=NaN(1,numel(indeces));
                                sigGreater=NaN(1,numel(indeces));
                                sigSmaller=NaN(1,numel(indeces));
                                for img=1:numel(indeces)  %For all images belonging to the respective group
                                    sigsMean(img)=Imwise{indeces(img)}.(simnames{s}){sims}.sig{a,b};
                                    sigGreater(img)=Imwise{indeces(img)}.(simnames{s}){sims}.greater{a,b};
                                    sigSmaller(img)=Imwise{indeces(img)}.(simnames{s}){sims}.smaller{a,b};
                                end 
                                NN=numel(sigsMean) - numel(sigsMean(isnan(sigsMean))); %Number of images that contained Data on the tested parameter (i.e. parameter is not NaN)
                                Sign=numel(sigsMean(sigsMean==1));  %Number of signficant images
                                pdiff=myBinomTest(Sign, NN, pval*2, 'two'); %Is number of significant images significantly different from expectations? Expectation: pvalue*100% of images should be signficant.
                                %% myBinomTest() Copyright (c) 2015, Matthew Nelson
                                %% License can be found at util/myBinomTest/license.txt
                                fprintf(file, [Grplabels{g+1} '-' getName(Data, methodA{a}) '->' getName(Data, methodA{b}) ';' simnames{s} getName(Data,methodA{sims}) ';' num2str(100*numel(sigsMean(sigsMean==1))/(numel(indeces) - numel(sigsMean(isnan(sigsMean))))) ';' num2str(100*numel(sigGreater(sigGreater==1))/(numel(indeces) - numel(sigGreater(isnan(sigGreater))))) ';' num2str(100*numel(sigSmaller(sigSmaller==1))/(numel(indeces) - numel(sigSmaller(isnan(sigSmaller))))) ';' num2str(pdiff) ';' num2str(NN) ';' num2str(numel(sigsMean)) '\n']);
                            end
                        end

                    end
                end
            end
        end
    end
    fclose(file);
end

