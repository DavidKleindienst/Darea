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
real_NNDs_str=nearestParticleImage(infoImage,radius,NaN);
real_distances=real_NNDs_str.(distfield);

%Get lower and upper bounds based on Options and real image characteristics
for bo=1:2
    switch Options.bounds{bo,1}
        case 1          %nm
            bound=Options.bounds{bo,2};
        case 2          %mean + x*SD
            bound=mean(real_distances)+Options.bounds{bo,2}*std(real_distances);
        case 3          %mean + x*SEM
            bound=mean(real_distances)+Options.bounds{bo,2}*(std(real_distances)/sqrt(size(real_distances,2)));
        case 4          %xth Percentile
            bound=prctile(real_distances, Options.bounds{bo,2});
        case 5          %None
            bound=NaN;
        case 6          %Kolmogorv-Smirnov
            bound=Options.bounds{bo,2};
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
if ~isnan(upper) && Options.bounds{bo,1}~=6 && upper<=mindistance
    set(hProgress, 'foregroundcolor', 'red', 'String', sprintf('Upper bound for simulation is smaller than the minimum distance between two particles. Fitting cannot be done with these parameters.\n%s', infoImage.route));
    uistack(hProgress, 'top');
    drawnow();
    error('Upper bound for simulation is smaller than the minimum distance between two particles. Fitting cannot be done with these parameters. Upper bound is %g\n%s', upper, infoImage.route);
end



TrialCounter=1;


sim_NNDs_str=nearestParticleImage(simImageInfo,radius,NaN);     %Compute Distances
sim_distances=sim_NNDs_str.(distfield);
[LowerTruth, UpperTruth]=isFittingNecessary(real_distances, sim_distances, upper, lower, Options); %Check whether fitting is necessary

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
    else  %If randomly selected particle should be redistributed

       flag=1;
       %Get previous distance value
       if (Options.bounds{1,1}==4 && LowerTruth) || (Options.bounds{2,1}==4 && UpperTruth)
           previous=median(sim_distances);
       elseif (Options.bounds{1,1}==6 && LowerTruth) || (Options.bounds{2,1}==6 && UpperTruth)
           [~,previous]=kstest2(real_distances, sim_distances);
       else
           previous=mean(sim_distances);
       end
       count=0;
       while flag==1
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

           if area(b,a)==0 %if particle lands in relevant part of image
                a=a*infoImage.scale;
                b=b*infoImage.scale;
                if Options.twoStep
                    if min(distToNearestPoint2Sets(receptors,[a,b],true))>=Options.minReceptorDistance
                        receptor=[a,b];
                        receptors(randIn,:)=receptor;
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
                        farenough=1;
                    else
                        farenough=0;
                    end
                else
                    farenough=min(distToNearestPoint2Sets(simImageInfo.centers, [a,b], true))>=mindistance;
                end
                if farenough %If it is far enough from other particles
                    simImageInfo.centers(index_list(randIn),:)=[a,b];

                    %Get new distance value
                    dist_now=nearestParticleImage(simImageInfo,radius,NaN);
                    sim_distances=dist_now.(distfield);                
                    if (Options.bounds{1,1}==4 && LowerTruth) || (Options.bounds{2,1}==4 && UpperTruth)
                        now=median(sim_distances);
                    elseif (Options.bounds{1,1}==6 && LowerTruth) || (Options.bounds{2,1}==6 && UpperTruth)
                        [~,now]=kstest2(real_distances, sim_distances);
                    else
                        now=mean(sim_distances);
                    end
                    %If new distance value is better than previous, keep the new coordinates; otherwise move it back to previous coordinates

                    if (UpperTruth && now<previous) || (LowerTruth && now>previous)
                        flag=0;
                    end
                end
           end
           if flag
               simImageInfo.centers(index_list(randIn),:)=oldP;
               if Options.twoStep; receptors(randIn,:)=oldR; end
           end
           if mod(count,50000)==0 && flag      %If after 50000 tries no improvement could be found, reroll all particles
               simImageInfo=randomSimulation(infoImage, simImageInfo, area, radius, partnr, Options,vm,hm);
               count=0; flag=0;      %reset all counters and flags
               TrialCounter=TrialCounter+1;     %Increase Trial counter by 1 and display a message
               fprintf(['Simulation Attempt failed for Image ' num2str(infoImage.id) '. Starting Attempt ' num2str(TrialCounter) '!\n']);
           end
       end
    end


    %Compute the new distances and test whether additional fitting is necessary
    sim_NNDs_str=nearestParticleImage(simImageInfo,radius,NaN); 
    [LowerTruth, UpperTruth]=isFittingNecessary(real_distances, sim_NNDs_str.(distfield), upper, lower, Options);
    %[~, KS]=kstest2(real_distances, sim_NNDs_str.(distfield));
    %counter=counter+1;    %Template that can be used for troubleshooting
    %if counter==1 || mod(counter, 50)==0
    %    fprintf(['Image ' num2str(infoImage.id) ':' num2str(KS) '\n']);
    %end
end




end

