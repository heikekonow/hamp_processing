function pathPrefix = getPathPrefix

% Function to get computer specific path prefix to use this scripts on
% different computers

% Check for cumputer name
if strcmp(getComputerName,'corona') || strcmp(getComputerName,'thunder3') ||...
        strcmp(getComputerName,'breeze1') || strcmp(getComputerName,'mi16-l-03') || ...
        strcmp(getComputerName,'breeze2')
    pathPrefix = '/data/share/narval/work/heike/';
elseif strcmp(computer,'MACI64') && strcmp(getenv('USER'),'heike')
%     pathPrefix = '/Users/heike/narval/';    
    pathPrefix = '/Users/heike/Documents/';    
elseif strcmp(computer,'MACI64') && strcmp(getenv('USER'),'heikearbeit')
    pathPrefix = '/Users/heikearbeit/Documents/';
else
    error('Did not find your machine in the list. Pleas add!')
end