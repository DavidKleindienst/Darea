function closeCB(updated, saveFct)
% If updated is false, asks if stuff should be saved then closes figure;
% Otherwise closes figure right away

% If everything is updated does not show the dialog.
if updated
    delete(gcf);
    return
end
% Construct a questdlg with three options
choice = questdlg('Do you want to close the figure without saving?', ' Warning', 'Cancel', 'Close without saving','Save and close','Save and close');
% Handle response
switch choice
    case 'Cancel' % Do not close.
        return;
    case 'Close without saving' 
        delete(gcf);
    case 'Save and close' 
        saveFct();
        delete(gcf);
end
end

