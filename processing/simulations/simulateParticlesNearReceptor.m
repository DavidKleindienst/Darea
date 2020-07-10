function simulated=simulateParticlesNearReceptor(toSimulate,receptors,minLength,maxLength)
    simReceptorsRelevant=reshape(receptors(isnan(toSimulate)),[],2);
    nPart=size(simReceptorsRelevant,1);
    %Gold particle will be random distance between minLength and
    %maxLength away from receptor, at a random angle
    lengths=(maxLength-minLength).*rand(nPart,1)+minLength;
    angles=(2*pi).*rand(nPart,1);
    vectors=[lengths.*cos(angles), lengths.*sin(angles)];
    simulated=simReceptorsRelevant+vectors;
end