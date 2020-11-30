function data = readdata(flightdate, variable, vers)

% Load variable names and instruments
[lookuptable,instrOrder] = varnames_lookup;

% Look for instruments for given variable
[~, instrInd] = find(strcmp(lookuptable, variable));

% Check if more than one instance of the given variable was found
if length(instrInd)>1 && (strcmp(variable, 'time') || strcmp(variable, 'height'))
    instrInd = instrInd(1);
elseif length(instrInd)>1
    error(['Found variable "' variable '" in more than one instrument. Check code in "readdata"'])
end

% Get path to correct file
if ~exist('version', 'var')
    filepath = listFiles([getPathPrefix getCampaignFolder(flightdate) ...
                      'all_nc/' instrOrder{instrInd} '*' flightdate '*'], 'full', 'latest');
else
    filepath = listFiles([getPathPrefix getCampaignFolder(flightdate) ...
                      'all_nc/' instrOrder{instrInd} '*' flightdate '*v' vers '*'], 'full');
end

% Check if a file has been found
if isempty(filepath)
    error(['No file found for variable: ' variable ', version: ' vers '.'])
end
                  
% Read data
data = ncread(filepath, variable);