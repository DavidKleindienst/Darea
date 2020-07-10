function changeAppearance(ax, changes)
%% Changes appearance of the figure according to settings defined by user
% Input parameters:
% ax - handle the axes object of the figure
% changes - struct with each field being named as the property to be changed and containing the new value
%           for instance: changes.FontSize=12

if isfield(changes, 'AxisLineWidth')
    set(ax, 'LineWidth', changes.AxisLineWidth);
end
if isfield(changes, 'XLabel')
    set(ax, 'XLabel', changes.XLabel);
end
if isfield(changes, 'YLabel')
    set(ax, 'YLabel', changes.YLabel);
end
if isfield(changes, 'XLim')
    set(ax, 'XLim', changes.XLim);
end
if isfield(changes, 'YLim')
    set(ax, 'YLim', changes.YLim);
end
if isfield(changes, 'Box')
    set(ax, 'Box', changes.Box);
end
if isfield(changes, 'GridLineStyle')
    set(ax, 'GridLineStyle', changes.GridLineStyle);
end
if isfield(changes, 'XTick')
    set(ax, 'XTick', changes.XTick)
end
if isfield(changes, 'YTick')
    set(ax, 'YTick', changes.YTick)
end
if isfield(changes, 'XMinorTick')
    set(ax, 'XMinorTick', changes.XMinorTick);
end
if isfield(changes, 'YMinorTick')
    set(ax, 'YMinorTick', changes.YMinorTick);
end
if isfield(changes, 'XScale')
    set(ax, 'XScale', changes.XScale);
end
if isfield(changes, 'YScale')
    set(ax, 'YScale', changes.YScale);
end
if isfield(changes, 'XTickLabelRotation')
    set(ax, 'XTickLabelRotation', changes.XTickLabelRotation);
end
if isfield(changes, 'YTickLabelRotation')
    set(ax, 'YTickLabelRotation', changes.YTickLabelRotation);
end
if isfield(changes, 'FontSize')
    set(ax, 'FontSize', changes.FontSize);
end
if isfield(changes, 'FontWeight')
    set(ax, 'FontWeight', changes.FontWeight);
end
if isfield(changes, 'FontName')
    set(ax, 'FontName', changes.FontName);
end
if isfield(changes, 'TitleFontSizeMultiplier')
    set(ax, 'TitleFontSizeMultiplier', changes.TitleFontSizeMultiplier);
end
if isfield(changes, 'TitleFontWeight')
    set(ax, 'TitleFontWeight', changes.TitleFontWeight);
end
if isfield(changes, 'FontAngle')
    set(ax, 'FontAngle', changes.FontAngle);
end
if isfield(changes, 'FontUnits')
    set(ax, 'FontUnits', changes.FontUnits);
end
    
end   