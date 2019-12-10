function pathPrefix = getPathPrefix

configstruct = config;

% Set path to data output folder (end path with slash '/')
if ~strcmp(configstruct.datapath(end),'/')
    configstruct.datapath = [configstruct.datapath '/'];
end
pathPrefix = configstruct.datapath;
