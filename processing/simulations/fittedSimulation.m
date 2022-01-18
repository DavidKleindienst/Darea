function simImageInfo = fittedSimulation(infoImage,simImageInfo, area, radius, partnr, Options,vm, hm, hProgress)
%FITTEDSIMULATION Summary of this function goes here
%   Detailed explanation goes her

%First generate random simulation
[simImageInfo, receptors]=randomSimulation(infoImage, simImageInfo, area, radius, partnr, Options,vm,hm);
mindistance=Options.mindistance;
minLength=Options.ReceptorParticleDistance(1);
maxLength=Options.ReceptorParticleDistance(2);

%Get list of particles being simulated
index_list=1:numel(infoImage.teorRadii);
index_list=index_list';
if ~strcmp(radius,'all')
    index_list(infoImage.teorRadii~=radius)=[];
end


if numel(index_list)<3             
    return;     %NNDs are only fitted if there are at least three particles of the simulated radius in the image
end
if strcmp(Options.fitdisttype, 'NNDs')
    distfield='distances';
elseif strcmp(Options.fitdisttype, 'all Distances')
    distfield='allDistances';
end
real_NNDs_str=nearestParticleImage(infoImage,radius,NaN,distfield);
real_distances=real_NNDs_str.(distfield);

%Get lower and upper bounds based on Options and real image characteristics
for bo=1:2
    switch Options.boundName
        case 'nm'
            bound=Options.bounds{bo};
        case 'mean + x*SD'
            bound=mean(real_distances)+Options.bounds{bo}*std(real_distances);
        case 'mean + x*SEM'
            bound=mean(real_distances)+Options.bounds{bo}*(std(real_distances)/sqrt(size(real_distances,2)));
        case 'xth Percentile'
            bound=prctile(real_distances, Options.bounds{bo});
        case 'KS'          %Kolmogorov-Smirnov
            bound=Options.bounds{bo};
    end
    if bo==1
        lower=bound;
    else
        upper=bound;
    end
end

%Some checks to see whether fitting criteria can actually be satisfied
if (~isnan(upper) && ~isnan(lower)) && (lower>=upper || nearEnough(lower, upper))
    set(hProgress, 'foregroundcolor', 'red', 'String', sprintf('Lower bound for simulation is larger then upper bound. Fitting cannot be done with these parameters.\n%s', infoImage.route));
    uistack(hProgress, 'top');
    drawnow();
    error('Lower bound for simulation is larger then upper bound. Fitting cannot be done with these parameters\n%s', infoImage.route);
end
if ~isnan(upper) && ~strcmp(Options.boundName, 'KS') && upper<=mindistance
    set(hProgress, 'foregroundcolor', 'red', 'String', sprintf('Upper bound for simulation is smaller than the minimum distance between two particles. Fitting cannot be done with these parameters.\n%s', infoImage.route));
    uistack(hProgress, 'top');
    drawnow();
    error('Upper bound for simulation is smaller than the minimum distance between two particles. Fitting cannot be done with these parameters. Upper bound is %g\n%s', upper, infoImage.route);
end



TrialCounter=1;


sim_NNDs_str=nearestParticleImage(simImageInfo,radius,NaN, distfield);     %Compute Distances
sim_distances=sim_NNDs_str.(distfield);
previous = getFittedValue(real_distances,sim_distances,Options.boundName);
[LowerTruth, UpperTruth]=isFittingNecessary(previous, upper, lower); %Check whether fitting is necessary

while UpperTruth || LowerTruth   %As long as fitting is neccessary
    if ~strcmp(Options.removeExtreme, 'random')     %If the particle furthest away from others should be redistributed (Older version of program probably biased, better use 'random')
        if UpperTruth
            if strcmp(Options.removeExtreme, 'NNDs')
                ind=find(sim_NNDs_str.distances==max(sim_NNDs_str.distances));        %If mean NND is too large, find particle with largest NND
            elseif strcmp(Options.removeExtreme, 'All Distances')
                D=mean(dist(infoImage.centers(infoImage.teorRadii==radius)'));
                ind=find(D==max(D));
            end
        else
            if strcmp(Options.removeExtreme, 'NNDs')
                ind=find(sim_NNDs_str.distances==min(sim_NNDs_str.distances));        %If mean NND is too small, find particle with smallest NND
            elseif strcmp(Options.removeExtreme, 'All Distances')
                D=mean(dist(infoImage.centers(infoImage.teorRadii==radius)'));
                ind=find(D==min(D));
            end
        end


        ind=datasample(ind,1);      %pick random index (only relevant if two particles have exactly same min/max NND
        simImageInfo.centers(index_list(ind),:)=NaN;      %Remove particle to be simulated
        if Options.twoStep
            receptors(ind,:)=NaN;   %uses index instead of index_list(ind) because receptor positions are only known where simulated
        end
        flag=1;

        while flag==1
            a=round((hm(2)-hm(1))*rand(1)+hm(1));          %roll dice for each particle that has the desired radius to obtain random distribution
            b=round((vm(2)-vm(1))*rand(1)+vm(1));          %get a number within the two limits of the discarded area

            if area(b,a)==0 %if particle lands in relevant part of image, check distance to other particles
                a=a*infoImage.scale;
                b=b*infoImage.scale;
                if Options.twoStep
                    % a,b correspond to coordinates of receptor, now
                    % find coordinates of particles
                    if min(distToNearestPoint2Sets(receptors,[a,b],true))<Options.minReceptorDistance
                        continue;   %receptor to close, start new
                    end
                    receptor=[a,b];
                    receptors(ind,:)=receptor;
                    yetAnotherFlag=1;
                    while yetAnotherFlag
                        angle=2*pi*rand(1);
                        length=(maxLength-minLength)*rand(1)+minLength;
                        vector=[length.*cos(angle), length.*sin(angle)];
                        particle=receptor+vector;
                        if min(distToNearestPoint2Sets(simImageInfo.centers, particle, true))>=mindistance
                            yetAnotherFlag=0;
                            a=particle(1);b=particle(2);
                        end
                    end
                elseif min(distToNearestPoint2Sets(simImageInfo.centers, [a,b], true))<mindistance         %If distance is larger than the minimum distance, save the new position
                    continue;   %Particle to close, start new
                end
                flag=0;
                simImageInfo.centers(index_list(ind),:)=[a,b];
            end
        end
        dist_now=nearestParticleImage(simImageInfo,radius,NaN,distfield);
        sim_distances=dist_now.(distfield);
        previous = getFittedValue(real_distances,sim_distances,Options.boundName);
        [LowerTruth, UpperTruth]=isFittingNecessary(previous, upper, lower); %Check whether fitting is necessary
        
    else  %If randomly selected particle should be redistributed

       count=0;
       while true
           count=count+1;
           %if mod(count,1000)==0; fprintf([num2str(count) '\n']); end; %Can be used for troubleshooting
           randIn=random('unid', numel(index_list));
           oldP=simImageInfo.centers(index_list(randIn),:);            %Save initial particle
           simImageInfo.centers(index_list(randIn),:)=NaN;             %then delete
           if Options.twoStep
                oldR=receptors(randIn,:);
                receptors(randIn,:)=NaN;
           end
           a=round((hm(2)-hm(1))*rand(1)+hm(1));          %roll dice for each particle that has the desired radius to obtain random distribution
           b=round((vm(2)-vm(1))*rand(1)+vm(1));          %get a number within the two limits of the discarded area

           if area(b,a)~=0 %if particle lands in relevant part of image
               simImageInfo.centers(index_list(randIn),:)=oldP;
               if Options.twoStep; receptors(randIn,:)=oldR; end
               continue
           end
           
            a=a*infoImage.scale;
            b=b*infoImage.scale;
            if Options.twoStep
                if min(distToNearestPoint2Sets(receptors,[a,b],true))>=Options.minReceptorDistance
                    receptor=[a,b];
                    receptors(randIn,:)=receptor;
                    while true
                        angle=2*pi*rand(1);
                        length=(maxLength-minLength)*rand(1)+minLength;
                        vector=[length.*cos(angle), length.*sin(angle)];
                        particle=receptor+vector;
                        if min(distToNearestPoint2Sets(simImageInfo.centers, particle, true))>=mindistance
                            a=particle(1);b=particle(2);
                            break;
                        end
                    end
                else
                    simImageInfo.centers(index_list(randIn),:)=oldP;
                    if Options.twoStep; receptors(randIn,:)=oldR; end
                    continue
                end
            elseif min(distToNearestPoint2Sets(simImageInfo.centers, [a,b], true))<mindistance
                simImageInfo.centers(index_list(randIn),:)=oldP;
                if Options.twoStep; receptors(randIn,:)=oldR; end
                continue
            end
            %Particle is now far enough from other particles
            simImageInfo.centers(index_list(randIn),:)=[a,b];

            %Get new distance value
            dist_now=nearestParticleImage(simImageInfo,radius,NaN,distfield);
            sim_distances=dist_now.(distfield);     
            
            now = getFittedValue(real_distances,sim_distances,Options.boundName);

            %If new distance value is better than previous, keep the new coordinates; otherwise move it back to previous coordinates

            if (UpperTruth && now<previous) || (LowerTruth && now>previous)
                %Accept new particle
                previous=now;
                [LowerTruth, UpperTruth]=isFittingNecessary(now, upper, lower);
                break;
            end
            
            %Revert to previous particle
            simImageInfo.centers(index_list(randIn),:)=oldP;
            if Options.twoStep; receptors(randIn,:)=oldR; end
            
            if mod(count,50000)==0     %If after 50000 tries no improvement could be found, reroll all particles
                simImageInfo=randomSimulation(infoImage, simImageInfo, area, radius, partnr, Options,vm,hm);
                previous = getFittedValue(real_distances,sim_distances,Options.boundName);
                [LowerTruth, UpperTruth]=isFittingNecessary(previous, upper, lower); %Check whether fitting is necessary
                TrialCounter=TrialCounter+1;     %Increase Trial counter by 1 and display a message
                fprintf(['Simulation Attempt failed for Image ' num2str(infoImage.id) '. Starting Attempt ' num2str(TrialCounter) '!\n']);
                break;
            end
        end
    end

end




end

