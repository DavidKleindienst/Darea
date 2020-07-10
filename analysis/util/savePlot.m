function savePlot(figure_handle, filename, format)
%% Saves figure in appropriate format.
% Input parameters:
% fig: figure handle
% path: path to where the file shoudl be saved
% format: extension of the file (e.g. .png, .fig, .eps) 

if strcmp(format,'.fig')
    savefig(figure_handle,[filename '.fig']);
elseif strcmp(format, '.eps')
    saveas(figure_handle, [filename, format], 'epsc');
else
    saveas(figure_handle, [filename, format]);
end

end



