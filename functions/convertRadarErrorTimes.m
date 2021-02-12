%   convertRadiometerErrorTimes - converting error indices to error flags
%   Program for converting error indices from raw radiometer data into error
%   flag according to unified data set
%   Data is saved into mat file in auxiliary folder
%
%   Syntax:  convertRadiometerErrorTimes(campaign)
%
%   Inputs:
%       campaign - String with campaign name
%
%   Outputs:
%       file with error flags in subfolder aux/
%
%   Example: 
%       convertRadiometerErrorTimes('EUREC4A')
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   June 2017; Last revision: April 2020

%------------- BEGIN CODE --------------

% Program for converting error indices from raw radiometer data into error
% flag according to unified data set

function convertRadarErrorTimes(campaign)

% Load error indices
errors = radarErrorsLookup;

% Get dates to process
date = getCampaignDates(campaign);

% Preallocate arrays
errorFlag = cell(length(date), 1);

% Set path to data
basefolder = [getPathPrefix getCampaignFolder(date{1})];
pathRadar = [basefolder 'radar/'];
pathtofolderNc = [basefolder 'all_nc/'];
    
% Loop flight dates
for i=1:length(date)

    % Display date
    disp(date(i))

    % Get path to radiometer data file
    filepath = listFiles([pathRadar '*' date{i}(3:end) '*'], 'full', 'mat');

    % Get path to latest version of processed radiometer file
    filepathnc = listFiles([pathtofolderNc 'radiometer*' date{i} '*'], 'full', 'latest');

    % Get day index from error cell
    indDay = strcmp(errors(:,1),date{i});

    % Preallocate array
    timeRaw = cell(size(filepath, 1), 1);
    % Loop all found files
    for k=1:size(filepath, 1)
        % Read time from original files
        timeRaw{k} = (ncread(filepath(k,:),'time'))';
    end
    % Concatenate
    timeRaw = [timeRaw{:}];
    % Convert time to serial date number
    timeRaw = unixtime2sdn(timeRaw);

    % Copy errors to variables
    errorsDay = errors{indDay,2};
    
    % If variable is not cell, convert to cell
    if ~iscell(errorsDay)
        errorsDay = {errorsDay};
    end

    % Read time from unified data
    timeUni = ncread(filepathnc,'time');
    % Convert time to serial date number
    timeUni = unixtime2sdn(timeUni);

    % Create flags and fill with zeros
    timeErrorFlag = zeros(size(timeUni));

    % If errors array is not empty
    if sum(cellfun(@isempty,errorsDay))==0 && ~isempty(timeRaw)

        % Loop all errors for current date
        for k=1:length(errorsDay)

            % Copy error indices to variable
            indError = errorsDay{k};

            % If only one index is given
            if length(indError)==1 
                if timeRaw(indError)<timeUni(end) && timeRaw(indError)>timeUni(1) % Make sure that error index time is after first time step from uni time

                    % Find according time interval indices in unified grid
                    ind_errorTime(1) = find(timeUni>=timeRaw(indError),1,'first');
                    ind_errorTime(2) = find(timeUni<=timeRaw(indError),1,'last');

                    % Set flag to 1
                    timeErrorFlag(ind_errorTime(1):ind_errorTime(2)) = 1;
                end
            elseif timeRaw(indError(2))>timeUni(1) % Make sure that second error index time is after first time step from uni time

                % Find according time interval indices in unified grid
                ind_errorTime(1) = find(timeUni>=timeRaw(indError(1)),1,'first');
                ind_errorTime(2) = find(timeUni<=timeRaw(indError(2)),1,'last');

                % Set flag to 1
                timeErrorFlag(ind_errorTime(1):ind_errorTime(2)) = 1;
            end
        end

        % Convert flag to logical array
        errorFlag{i} = logical(timeErrorFlag);
    end
end


% Check if auxiliary directory exists, otherwise create
checkandcreate(basefolder, 'aux')

% Save flags to file
save([basefolder 'aux/errorFlagRadar.mat'],'errorFlag','date')
