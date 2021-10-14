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

function StatPopMeansCluster(Data, settings, outpath)
%% Compares whether the population mean of each cluster parameters is different from the simulation
%For each image, mean of parameter and mean of means of simulations are computed.
%A paired t-test is then used to see whether real is different from the simulation
%This is performed for each cluster parameter
%Results are written to csv-files which are saved in the folder specified in outpath


fct=@nanmean;          %Statistical functions are mean and
test=@ttest;           %Paired T-test

%Simplification
simnames=Data.simnames;
methodA=Data.methodA;
Groups=Data.Groups;
Orig=Data.Orig;
nrsim=Data.nrsim;
nrImg=numel(Orig.Images);
header=['Original;Simulation;realmean;realstd;realsem;simmean;simstd;simsem;pValue;t-Statistic;N;totalImages\n'];
Grplabels=[settings.allGroupsname; Groups.names];
fields=fieldnames(Orig.ClusterInteraction{1});
for f=3:numel(fields)       %For all fields containing Data
    if strcmp(fields{f}, 'thresholdDist') || strcmp(fields{f}, 'excludedClusters') ...
            || strcmp(fields{f}, 'maxDistance') 
        continue
    end
    filename=fullfile(outpath, [fields{f} '_PopMeans.csv']);
    file=fopen(filename, 'wt');
    fprintf(file, header);
    for g=0:Groups.number       %For all Groups
        if g>0
            indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        else        %g=0 - sum over all images
            indeces=1:nrImg;
        end
        for s=1:numel(simnames)     %For all simulation types
            for sims=1:numel(methodA)       %For all particle sizes being simulated
                if numel(Orig.ClusterInteraction{1}.(fields{f}))==numel(methodA)     %Cluster parameters that only relate to a single particle size (most of them)
                    for a=1:numel(methodA)      %For all particle sizes
                        realmeans=NaN(1,numel(indeces));
                        simmeans=NaN(1,numel(indeces));
                        for i=1:numel(indeces)      %For all images belonging to the respective group
                            realmeans(i)=fct(Orig.ClusterInteraction{indeces(i)}.(fields{f}){a});
                            sim_mean=NaN(1,nrsim);
                            for snr=1:nrsim
                                sim_mean(snr)=fct(Data.(simnames{s}){sims}.IndivClustInteraction{snr}{indeces(i)}.(fields{f}){a});
                            end
                            simmeans(i)=fct(sim_mean);
                        end
                        toKeep=~isnan(realmeans)&~isnan(simmeans);
                        realmeans=realmeans(toKeep);      %Remove flagged images
                        simmeans=simmeans(toKeep);

                        [~,p,~,t]=test(realmeans, simmeans);    %test if real Data is signficantly different from simulation
                        fprintf(file, [Grplabels{g+1} '-' getName(Data, methodA{a}) ';' simnames{s} getName(Data,methodA{sims}) ...
                            ';' num2str(mean(realmeans)) ';' num2str(std(realmeans)) ';' num2str(sem(realmeans)) ';' ...
                            num2str(mean(simmeans)) ';' num2str(std(simmeans)) ';' num2str(sem(simmeans)) ';' num2str(p) ...
                            ';t(' num2str(t.df) ')=' num2str(abs(t.tstat)) ';' num2str(numel(realmeans)) ';' num2str(numel(indeces)) '\n']);
                    end
                else        %Cluster paramters of form from particle type A to particle type B (Overlap and intercluster Distance)
                    for a=1:numel(methodA)
                        for b=1:numel(methodA)          %For all pairs of different particle sizes A->B, B->A but not A->A or B->B.
                            if a~=b
                                realmeans=NaN(1,numel(indeces));
                                simmeans=NaN(1,numel(indeces));
                                for i=1:numel(indeces)      %For all images belonging to the respectiv group
                                    realmeans(i)=fct(Orig.ClusterInteraction{indeces(i)}.(fields{f}){a,b});
                                    sim_mean=NaN(1,nrsim);
                                    for snr=1:nrsim         %For all individual simulations
                                        sim_mean(snr)=fct(Data.(simnames{s}){sims}.IndivClustInteraction{snr}{indeces(i)}.(fields{f}){a,b});
                                    end
                                    simmeans(i)=fct(sim_mean);

                                end
                                toKeep=~isnan(realmeans)&~isnan(simmeans);
                                realmeans=realmeans(toKeep);
                                simmeans=simmeans(toKeep);

                                [~,p,~,t]=test(realmeans, simmeans);
                                fprintf(file, [Grplabels{g+1} '-' getName(Data, methodA{a}) '_' getName(Data, methodA{b})  ';' ...
                                    simnames{s} getName(Data,methodA{sims}) ';' num2str(mean(realmeans)) ';' num2str(std(realmeans)) ...
                                    ';' num2str(sem(realmeans)) ';' num2str(mean(simmeans)) ';' num2str(std(simmeans)) ';' num2str(sem(simmeans)) ';' num2str(p) ...
                                    ';t(' num2str(t.df) ')=' num2str(abs(t.tstat)) ';' num2str(numel(realmeans)) ';' num2str(numel(indeces)) '\n']);
                            end
                        end
                    end
                end
            end
        end
    end
    fclose(file);
end

end