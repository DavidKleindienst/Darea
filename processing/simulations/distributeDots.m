function simulated=distributeDots(toSimulate,hm,vm)
    nPart=sum(isnan(toSimulate),'all')/2;
    simulated=round([(hm(2)-hm(1)).*rand(nPart,1)+hm(1), ...
                    (vm(2)-vm(1)).*rand(nPart,1)+vm(1)]);
end