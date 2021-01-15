function run_removeRadiometerErrors(version, subversion, flightdates_use)

% Generate version string
dataversion = [num2str(version) '.' num2str(subversion)];

% Loop all dates
for i=1:length(flightdates_use)
    
    % Get base folder path for data
    pathtofolder = [getPathPrefix getCampaignFolder(flightdates_use{i})];

    % Look for radiometer data file from which the errors should be removed
    datafile = listFiles([pathtofolder 'all_nc/*radiometer*' flightdates_use{i} '*' ...
                          dataversion '*'], 'full', 'mat');
	
	% If more than one file was found, return error
    if size(datafile, 1)>1
        error(['More than one radiometer data file found for current version (v' ...
                dataversion '). Please check and remove unneccesary files.']) 
    end
    
    % Remove errors in brightness temperatures
    [tb, ~] = removeTBErrors(flightdates_use{i}, dataversion);
    
    % Write new brightness temperatures to file
    ncwrite(datafile, 'tb', tb)

end