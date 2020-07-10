function fullRoutes = getFullRoutes(routes,config, extension)
%% Returns absolute filepaths of roues
% Usually routes are specified relative to a config file
% This function returns the full filepaths
% Input Arguments:
% routes: Cell array of relative file paths
% config: Config file relative to which the routes are specified
% extension: adds a fileextension add the end
if nargin<3
    extension='';
end

basePath=fileparts(config);
fullRoutes=cellfun(@(x) fullfile(basePath,[x extension]),routes,'UniformOutput',false);

