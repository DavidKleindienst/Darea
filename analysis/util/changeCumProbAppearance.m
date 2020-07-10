function changeCumProbAppearance(cpl, changes)
%% Changes Appearance of cumulative probability plots according to user defined settings
% Input parameters:
% cpl - handle of cumulative probability plot
% changes - struct with each field being named as the property to be changed and containing the new value
%           for instance: changes.LineWidth=3
for i=1:numel(cpl)
    if isfield(changes, 'LineWidth')
        set(cpl{i}, 'LineWidth', changes.LineWidth);
    end
    if isfield(changes, 'LineStyleOrder')
        if i<=numel(changes.LineStyleOrder)
            set(cpl{i}, 'LineStyle', changes.LineStyleOrder{i});
        else
            set(cpl{i}, 'LineStyle', changes.LineStyleOrder{end});
        end
    end
    
end
end

