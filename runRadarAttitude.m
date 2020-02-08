function runRadarAttitude(flightdates_use)


    
for i=1:length(flightdates_use)

    %% check if bahamas exists

    % Set path to bahamas files
    bahamasDir = [getPathPrefix getCampaignFolder(flightdates_use{i}) 'bahamas/'];
    smartDir = [getPathPrefix getCampaignFolder(flightdates_use{i}) 'smartnav/'];
    % Look for files from flight
    if isempty(listFiles([bahamasDir '*.nc'])) ...
        && ~isempty(listFiles([smartDir '*.Asc']))

        % if yes, set marker to 1
        convertmarker = 1;
    elseif ~isempty(listFiles([bahamasDir '*.nc']))
        % if no, set marker to 2
        convertmarker = 2;
    else
        error('No aircraft attitude data. Can''t convert radar data')
    end
    
    % run runRadarAttComb with overloaded marker for smart or bahamas
    
    runRadarAttComb(convertmarker, flightdates_use{i})
end