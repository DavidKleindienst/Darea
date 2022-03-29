function closeCB(updated, saveFct)
%% Standard closing function
% if updated is true, closes the figure
% If updated is false, asks if the data should be saved. If so, uses saveFct to save the data.

% If everything is updated does not show the dialog.
if updated
    delete(gcf);
    return
end
% Construct a questdlg with three options
choice = questdlg('Do you want to close the figure without saving?', ' Warning',...
                'Cancel', 'Close without saving','Save and close','Save and close');
% Handle response
switch choice
    case {'','Cancel'} % Do not close.
        return;
    case 'Close without saving' 
        delete(gcf);
    case 'Save and close' 
        saveFct();
        delete(gcf);
end
end

