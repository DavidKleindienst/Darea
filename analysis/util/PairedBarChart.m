%% This function has not yet been implemented into the program
function PairedBarChart(x,settings)
%PAIREDBARCHART Summary of this function goes here
%   x(x,:) -> Group X, with all : being single measurements


barNr=size(x,2);

%Some Default Values so people can give an empty variable to use the default.
if ~isstruct(settings); settings=struct(); end;
if ~isfield(settings, 'center'); settings.center=@nanmean; end;
if ~isfield(settings, 'error'); settings.error=@sem; end;
if ~isfield(settings, 'showDatapoints'); settings.showDatapoints=1; end;
if ~isfield(settings, 'PointSymbol'), settings.PointSymbol='o'; end;
if ~isfield(settings, 'PointColor'), settings.PointColor='red'; end;
if ~isfield(settings, 'PointSize'), settings.PointSize=3; end;
if ~isfield(settings, 'showErrorbars'); settings.showErrorbars=1; end;
if ~isfield(settings, 'ErrorWidth'); settings.ErrorWidth=1.5; end;
if ~isfield(settings, 'ErrorColor'); settings.ErrorColor='black'; end;
if ~isfield(settings, 'Width'); settings.Width=0.3; end;
if ~isfield(settings, 'connectDatapoints'); settings.connectDatapoints=1; end;
if ~isfield(settings, 'ConnectionWidth'); settings.ConnectionWidth=0.75; end;
if ~isfield(settings, 'ConnectionColor'); settings.ConnectionColor='black'; end;
if ~isfield(settings, 'FaceColor') || (iscell(settings.FaceColor) && numel(settings.FaceColor)~=barNr); settings.FaceColor='b'; end;

%%%%%%DELETE LATER
delete(gca);
%%%%%


means=settings.center(x);
axes()
hold on
for b=1:barNr
    if iscell(settings.Width)
        width=settings.Width{b};
    else
        width=settings.Width;
    end
    if iscell(settings.FaceColor)
        color=settings.FaceColor{b};
    else
        color=settings.FaceColor;
    end
    bar(b, means(b), width, 'FaceColor', color);
end
hold on
if settings.showErrorbars
    errors=settings.error(x);
    for e=1:numel(errors)
       plot([e,e], [means(e), means(e)+errors(e)], 'LineWidth', settings.ErrorWidth, 'Color', settings.ErrorColor); 
    end
end
if settings.showDatapoints
    for b=1:barNr
        plot(b, x(:,b), settings.PointSymbol, 'MarkerEdgeColor', settings.PointColor, 'MarkerFaceColor', settings.PointColor, 'MarkerSize', settings.PointSize);
    end
    if settings.connectDatapoints
       for b=1:barNr-1;
           c=b+1;
           for p=1:size(x,1);
               if ~isnan(x(p,b)) && ~isnan(x(p,c))
                  plot([b,c], [x(p,b), x(p,c)], 'LineWidth', settings.ConnectionWidth, 'Color', settings.ConnectionColor); 
               end
           end

       end
    end
end
set(gca, 'XTick', 1:barNr);

if isfield(settings, 'xlabel') && numel(settings.xlabel)==barNr
    set(gca, 'XTickLabel', settings.xlabel)
end
changeAppearance(gca, settings);

if isfield(settings, 'Title')
    title(settings.Title);
end
if isfield(settings, 'ylabel')
    ylabel(settings.ylabel);
end

hold off
end

