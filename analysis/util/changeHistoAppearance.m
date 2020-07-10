function changeHistoAppearance(h, changes)
%% Changes appearance of histograms according to user defined settings
% Input parameters:
% h - handle of histogram
% changes - struct with each field being named as the property to be changed and containing the new value
%           for instance: changes.FaceColor='blue'
set(h, 'FaceColor', changes.FaceColor);
set(h, 'EdgeColor', changes.EdgeColor);
if isfield(changes, 'Orientation')
    set(h, 'Orientation', changes.Orientation);
end
if isfield(changes, 'LineStyle')
    set(h, 'LineStyle', changes.LineStyle);
end
if isfield(changes, 'LineWidth')
    set(h, 'LineWidth', changes.LineWidth);
end
if isfield(changes, 'Normalization')
    set(h, 'Normalization', changes.Normalization);
end
if isfield(changes, 'FaceAlpha')
    set(h, 'FaceAlpha', changes.FaceAlpha);
end
if isfield(changes, 'EdgeAlpha')
    set(h, 'EdgeAlpha', changes.EdgeAlpha);
end


end

