function makeFigures(Data,datFile,outpath,settings,hProgress)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
warning('off');
mkdir(outpath)
save(fullfile(outpath, 'settings.mat'),'settings');      %Save settings to the same folder
printInfo(Data,fullfile(outpath,'ImageInfo.csv'));
if ~isfield(Data, 'distfields')
    % For compatibility with .mat files from previous versions
    Data.distfields={'allDistances', 'distances', 'distanceFromEdge', 'distanceFromCenter'};
    Data.isPairedField=[1,1,0,0];
end
dist_names={'All_Distances', 'NND', 'Distance_from_Edge', 'Distance_from_Center', 'normalized_Distance_from_Center', 'squaredDistCenter'};


%% Run all appropriate functions
if settings.makeStatistics
    set(hProgress, 'String','Calculating Metrics');
    drawnow();
    makeMetrics(Data,fullfile(outpath, 'Stats_and_Metrics'),settings,dist_names);
    
    set(hProgress, 'String', 'Calculating Statistics');
    drawnow();
    MakeStatistics(Data, fullfile(outpath, 'Stats_and_Metrics'), settings,dist_names);
    
    if settings.StatisticsOptions.maketSNE
        %%Make tSne plots:
        safeMkdir(fullfile(outpath,'Stats_and_Metrics','plots'));
        outpath_tsne=fullfile(outpath,'Stats_and_Metrics','plots','tSNE');
        safeMkdir(outpath_tsne);

        groupsForTsne={Data.Groups};
        if numel(Data.Groups.chosenGroups)>1
            %We want to get a plot with different colors for any grouping
            %So speceify all these groupings
            for g=1:numel(Data.Groups.chosenGroups)
                groupsForTsne=[groupsForTsne, getInfoGroups(datFile, Data.Groups.chosenGroups(g))];
            end
        end
        tSneAnalysis(Data,groupsForTsne,settings,outpath_tsne);
    end
end
if settings.makeCumProb
    set(hProgress, 'String', 'Producing cumulative probability plots');
    drawnow();
    ProduceCumProb(Data, outpath, settings);
end  
if settings.makeHist
    set(hProgress, 'String', 'Producing Histograms');
    drawnow();        %pause is neccessary for the Progress message to be displayed.
    ProduceHistograms(Data, outpath, settings);
end
end

