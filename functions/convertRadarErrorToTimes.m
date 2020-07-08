function [tRawErrors, tUniErrors, indUniTimeError] = convertRadarErrorToTimes(campaign)

errors = radarErrorsLookup;

% campaign = 'EUREC4A';

flightdates = getCampaignDates(campaign);

tRawErrors = cell(length(flightdates),1);
indUniTimeError = cell(length(flightdates),1);
tUniErrors = cell(length(flightdates),1);

for i=1:length(flightdates)
    
    disp(flightdates{i})
    
    %% Read data
    pathToMeasData = listFiles([getPathPrefix getCampaignFolder(flightdates{i}) 'radar/*' flightdates{i} '*'], 'full');
    pathToUniData = listFiles([getPathPrefix getCampaignFolder(flightdates{i}) 'all_nc/*' flightdates{i} '*'], 'full', 'latest');
    
    if ~isempty(pathToMeasData{1})
        % Loop multiple radar data files
        for j=1:length(pathToMeasData)
            % Read time
            tRaw = ncread(pathToMeasData{j}, 'time');
        end

        % If there were multiple files, concatenate
        if iscell(tRaw)
            % Concatenate
            tRaw = [tRaw{:}];
        end

        % Read uni time
        tUni = ncread(pathToUniData, 'time');

        %%

        % Look for date in error array
        ind_errorDay = strcmp(flightdates{i}, errors(:,1));

        radarErrorIndices = errors{ind_errorDay, 2};

        if ~isempty(radarErrorIndices)
            tRawErrors{i} = double(tRaw(radarErrorIndices));
            
            for j=1:length(radarErrorIndices)
                [~, indUniTimeError{i}(j)] = min(abs(tUni-tRawErrors{i}(j)));
                tUniErrors{i}(j) = tUni(indUniTimeError{i}(j));
            end
        end
    end
end