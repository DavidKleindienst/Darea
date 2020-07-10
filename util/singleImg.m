% Not yet part of the GPDQ
function singleImg(infoI, simI, settings)
%SINGLEIMG Summary of this function goes here
%   Detailed explanation goes here

name='GIRK';

infoD=nearestParticleImage(infoI,2.5,5);
simI.centers(simI.teorRadii==0,:)=infoI.centers(simI.teorRadii==0,:);
simI.teorRadii(simI.teorRadii==0,:)=simI.removed;
simD=nearestParticleImage(simI,2.5,5);

f=figure;
ax=axes;
cpl{1}=cdfplot(infoD.distances);
hold on
cpl{2}=cdfplot(simD.distances);
[~,p]=kstest2(infoD.distances, simD.distances)

set(cpl{2}, 'color', 'green');
settings.CumProbOptions.XLim=[0, 210];
changeAppearance(ax, settings.CumProbOptions)
changeCumProbAppearance(cpl, settings.CumProbOptions);

title([name '-GABA_{B1} colocalization']);
l=legend({['real ' name ' to real GABA_{B1}'];['simulated ' name ' to real GABA_{B1}']}, 'Location', 'southeast');
set(l, 'Box', 'off');

xlabel('NND [nm]');
ylabel('Cumulative probability');

hold off

end

