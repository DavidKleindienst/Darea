function toSimulate=doTheSimulation(toSimulate,simfct, area, mindistance, compareDistanceTo,scale)
    if nargin<6
        scale=1;
    end
    
    %Set 0 for area to ignore area
    while any(isnan(toSimulate))
        simulated=simfct(toSimulate);  %simulated will have as many values as there are NaNs in toSimulate
        if any(any(area))
            isOutside=logical(area(sub2ind(size(area),simulated(:,2),simulated(:,1))));
            simulated(isOutside,:)=NaN;
        end
        simulated=simulated.*scale;
        isTooClose=distToNearestPoint2Sets(simulated,[compareDistanceTo;toSimulate],true)<mindistance | ...
                    distToNearestPoint(simulated)<mindistance;

        simulated(isTooClose,:)=NaN;
        toSimulate(isnan(toSimulate))=simulated;
    end
    
end