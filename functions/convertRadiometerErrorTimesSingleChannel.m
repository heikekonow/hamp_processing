%   convertRadiometerErrorTimesSingleChannel - converting error indices to 
%                   error flags for errors in individual channels
%       Program for converting error indices from raw radiometer data into error
%       flag according to unified data set; in contrast to the function 
%       'convertRadiometerErrorTimes', this function generates error flags for
%       individual channels and not entire modules
%       Data is saved into mat file in auxiliary folder
%
%   Syntax:  convertRadiometerErrorTimesSingleChannel(campaign)
%
%   Inputs:
%       campaign - String with campaign name
%
%   Outputs:
%       file with error flags in subfolder aux/
%
%   Example: 
%       convertRadiometerErrorTimesSingleChannel('EUREC4A')
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   January 2021; Last revision: January 2021

%------------- BEGIN CODE --------------

function convertRadiometerErrorTimesSingleChannel(campaign)

% Get errors indices for single channels
errorsSingleChannel = radiometerErrorsSingleChannelLookup;

% Get dates to process
dateSingleChannel = getCampaignDates(campaign);

% Set radiometer module strings
radiometerStrings = {'183', '11990', 'KV'};

% Get dates to process
date = getCampaignDates(campaign);

% Set paths to data
basefolder = [getPathPrefix getCampaignFolder(dateSingleChannel{1})];
pathRadiometer = [basefolder 'radiometer/'];
pathtofolderNc = [basefolder 'all_nc/'];
path = cellfun(@(x) [pathRadiometer x '/'], radiometerStrings, 'uni', false);

% Preallocate arrays
errorFlagSingleChannel = cell(length(date),length(radiometerStrings));
frequencySingleChannel = cell(length(date),length(radiometerStrings));

% Loop dates
for i=1:length(dateSingleChannel)
    
    % Display date
%     disp(dateSingleChannel{i})
    
    % Get path to latest version of processed radiometer file
    filepathnc = listFiles([pathtofolderNc 'radiometer*' date{i} '*'], 'full', 'latest');
    
    % Read time from unified data and convert time to serial date number
    timeUni = unixtime2sdn(ncread(filepathnc,'time'));
    
    % Loop radiometer modules
    for j=1:length(radiometerStrings)
        
        % Get file path
        filepath = listFiles([path{j} '*' dateSingleChannel{i}(3:end) '*'], 'full', 'mat');
            
        % If a file was found, proceed
        if ~isempty(filepath)

            % Look if entries exist for this date in Single Channel
            % Error Lookup Table
            indDaySing = strcmp(errorsSingleChannel(:,1), dateSingleChannel{i});
            
            % Read radiometer frequencies
            frequencySingleChannel{i,j} = ncread(filepath, 'frequencies');
            
            % Create flags and fill with zeros
            timeErrorFlag = zeros(size(frequencySingleChannel{i,j},1), size(timeUni,1));
            
            % Preallocate array
            timeRaw = cell(size(filepath, 1), 1);
            % Loop all found radiometer files
            for k=1:size(filepath, 1)
                % Read time from original files
                timeRaw{k} = (ncread(filepath(k,:),'time'))';
            end
            % Concatenate
            timeRaw = [timeRaw{:}];
            % Convert time to serial date number
            timeRaw = time2001_2sdn(timeRaw);

            % Look for frequency in data that was listed in error
            % lookup table
            if sum(indDaySing)>0 && any(ismember([errorsSingleChannel{indDaySing,2}], round(double(frequencySingleChannel{i,j}),2)))
                indFreqData = [errorsSingleChannel{indDaySing,2}]==round(double(frequencySingleChannel{i,j}),2);
                
                % Remove empty columns
                indFreqData(:, ~any(indFreqData, 1)) = [];
                
                % Get error indices for current date
                errorsDay = errorsSingleChannel(indDaySing, 3);
                
                % Copy error indices to new variable
                singleChannelErrors = errorsDay{ismember([errorsSingleChannel{indDaySing,2}], round(double(frequencySingleChannel{i,j}),2))};
                
                % If frequency with error is part of current radiometer
                % module
                if sum(sum(indFreqData))>0
                    
                    % Loop all error index pairs
                    for k=1:length(singleChannelErrors)
                        
                        % If end of error interval is after beginning of
                        % Bahamas time
                        if timeRaw(singleChannelErrors{k}(2))>timeUni(1)
                            
                            % Find according time interval indices in unified grid
                            ind_errorTime(1) = find(timeUni>=timeRaw(singleChannelErrors{k}(1)),1,'first');
                            ind_errorTime(2) = find(timeUni<=timeRaw(singleChannelErrors{k}(2)),1,'last');
                        end
                        
                        % Set flag to 1
                        timeErrorFlag(indFreqData, ind_errorTime(1):ind_errorTime(2)) = 1;
                        
                    end
                end
                
                % Convert flag to logical array
                errorFlagSingleChannel{i,j} = logical(timeErrorFlag);
            end
        end
    end
end

%% Save data

% Check if auxiliary directory exists, otherwise create
checkandcreate(basefolder, 'aux')

% Save flags to file
% save([basefolder 'aux/errorFlagRadiometer.mat'],'errorFlagSingleChannel','frequencySingleChannel','dateSingleChannel','instrSingleChannel','-append')
save([basefolder 'aux/errorFlagRadiometer.mat'],'errorFlagSingleChannel','frequencySingleChannel','dateSingleChannel','-append')