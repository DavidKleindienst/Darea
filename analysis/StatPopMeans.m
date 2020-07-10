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

function StatPopMeans(Data, settings, outpath, dist_names)
%% Compares population means of Distances between real and simulated

%For each image, mean of real Distances and mean of means of simulations are computed.
%A paired t-test is then used to see whether real is different from the simulation
%Results are written to csv-files which are saved in the folder specified in outpath


meanfct=@nanmean;          %Statistical functions are mean 
test=@ttest;        %Paired T-test

%Simplification
simnames=Data.simnames;
methodA=Data.methodA;
methodB=Data.methodB;
Groups=Data.Groups;
Orig=Data.Orig;
nrsim=Data.nrsim;
nrImg=numel(Orig.Images);

header=['Original;Simulation;realmean;realstd;realsem;simmean;simstd;simsem;pValue;N;totalImages\n'];
Grplabels=[settings.allGroupsname; Groups.names];

for mode=1:numel(Data.distfields)
%if (mode==1 && settings.StatisticsOptions.makeNND) || (mode==2 && settings.StatisticsOptions.makeAllDist) || (mode==3 && settings.StatisticsOptions.makeDistEdge)
    filename=fullfile(outpath, [dist_names{mode} '_PopMeans.csv']);
    file=fopen(filename, 'wt');
    fprintf(file, header);
    for g=0:Groups.number       %for all Groups
        if g>0
            indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        else            %g==0 -> sum of all groups
            indeces=1:nrImg;
        end
        
        for s=1:numel(simnames)         %For all simulation types
            for a=1:numel(methodA)      %for all simulated particle sizes 
                for b=1:numel(methodB)   %Type of distance (e.g. A->A, A->B, B->A and so on)
                    if Data.isPairedField(mode) || isnan(methodB{b}{2}) 
                        realmeans=NaN(1,numel(indeces)); 
                        simmeans=NaN(1,numel(indeces));
                        for i=1:numel(indeces)
                            realmeans(i)=meanfct(Orig.Distance{b}{indeces(i)}.(Data.distfields{mode}));   %Get mean value
                            sim_mean=NaN(1,nrsim);
                            for snr=1:nrsim             %For all individual simulations
                                sim_mean(snr)=meanfct(Data.(simnames{s}){a}.IndivDist{b}{snr}{indeces(i)}.(Data.distfields{mode}));
                            end
                            simmeans(i)=meanfct(sim_mean);
                        end
                        toKeep=~isnan(realmeans)&~isnan(simmeans);
                        realmeans=realmeans(toKeep); 
                        simmeans=simmeans(toKeep);

                        [~,p]=test(realmeans, simmeans);
                        fprintf(file, [Grplabels{g+1} '-' getName(Data, methodB{b}) ';' simnames{s} getName(Data,methodA{a}) ';' num2str(mean(realmeans)) ';' num2str(std(realmeans)) ';' num2str(sem(realmeans)) ';' num2str(mean(simmeans)) ';' num2str(std(simmeans)) ';' num2str(sem(simmeans)) ';' num2str(p) ';' num2str(numel(realmeans)) ';' num2str(numel(indeces)) '\n']);
                    end
                end
            end
        end
    end
    fclose(file);
end
end

