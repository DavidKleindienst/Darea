function meanEdgeIndex = simulateEdgeIndex(polygon,numParticles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Mi=min(polygon(:,:));
Ma=max(polygon(:,:));

particles=(Ma-Mi).*rand(numParticles,2)+Mi;

[inpoly, on]=inpolygon(particles(:,1),particles(:,2),polygon(:,1),polygon(:,2));
inpoly=inpoly | on;
while ~all(inpoly)
    particles(~inpoly,:)=(Ma-Mi).*rand(sum(~inpoly),2)+Mi;
    [inpoly, on]=inpolygon(particles(:,1),particles(:,2),polygon(:,1),polygon(:,2));
    inpoly=inpoly | on;
end
polygon(end,:)=[];
distEdge=distanceFromEdge(particles,polygon);     
distCenter=distanceFromCenter(particles,polygon);
relativeDistanceFromCenter=distCenter./(distEdge+distCenter);
%meanEdgeIndex=mean(distCenter);
%meanEdgeIndex=mean(relativeDistanceFromCenter.^2);
meanEdgeIndex=mean(relativeDistanceFromCenter)^2;

end

