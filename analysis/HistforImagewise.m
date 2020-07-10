%% Deprecated

function HistforImagewise(fileR, fileOrig, outputfolder, settings)
%HISTFORIMAGEWISE Summary of this function goes here
%   Detailed explanation goes here
settings.StatisticsOptions.printVal2Hist=1;

fig=figure;
set(fig, 'CloseRequestFcn', '');

ax=axes;

if ~exist(outputfolder, 'dir')
    mkdir(outputfolder);
end

R=importdata(fileR, ';');
O=importdata(fileOrig, ';');

for i=2:size(R.textdata,1)
    random=R.data(i-1,:);
    h=histogram(random);
    name=[R.textdata{i,1} ' - ' R.textdata{i,2}];
    title(name)
    xlabel('Percent Significant');
    ylabel('Number of Simulations');
    changeAppearance(ax, settings.HistoOptions);
    changeHistoAppearance(h, settings.HistoOptions);
    if settings.StatisticsOptions.printVal2Hist
        in1=find(ismember(O.textdata(:,1), R.textdata{i,1}));
        in2=find(ismember(O.textdata(:,2), R.textdata{i,2}));
        ind=intersect(in1,in2);
        if numel(ind)>1
            ind
        elseif numel(ind)==1
            txt=[num2str(round(O.data(ind-1,1),1)) '%'];
            xl=xlim; yl=ylim;
            x=xl(1)+(xl(2)-xl(1))*0.83;
            y=yl(1)+(yl(2)-yl(1))*0.88;
            
            text(x,y,txt, 'Color', 'red', 'Fontsize', 14);
        end
    end
    saveas(gcf, [outputfolder name '.png']);
end

delete(fig);
end