%% runRadarAttComb
%   runRadarBahamasComb - Combines HAMP radar data with Bahamas data
%
%   Syntax:  runRadarBahamasComb
%               Adjust file location and desired conversion in header!!
%
%   Other m-files required: listFiles.m, HaloRadarBahamasComb.m,
%                           HaloRadarBahamasCombCorrectTime.m,
%                           HaloRadarBahamasCombCorrectTimeAngles.m
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   January 2014; Last revision: June 2015
%	March 2017: added processing for cases with multiple radar files
%				during one flight (only subversion 2)
%   August 2019: restructured file in preparation for EUREC4A: use 
%                SMART attitude data for first conversion

%------------- BEGIN CODE --------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runRadarAttComb(convertmarker, flightdate, missingvalule)

% Set version number
versionNumber = '0';

% % Select desired type of conversion
% convert_sv0 = 0;    % only convert raw data
% convert_sv1 = 1;    % correct aircraft attitude with SMART data
% convert_sv2 = 0;    % correct aircraft attitude with BAHAMAS data
% convert_sv3 = 0;    % correct time offsets in radar data

%% Specify time frame for data conversion
% Start date
% t1 = '20190517';  
% % End date
% t2 = '20190517';
% 
% %% Set additional information
% use_remote_data = 0;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% Get flight dates to use in this program
% flightdates_use = specifyDatesToUse(t1,t2);

radarDir = [getPathPrefix getCampaignFolder(flightdate) 'radar/'];
bahamasDir = [getPathPrefix getCampaignFolder(flightdate) 'bahamas/'];

radarOutDir = [getPathPrefix getCampaignFolder(flightdate) 'radar_mira/'];


%% Subversion 1: flight angles corrected with smart

if convertmarker==1
    % output
    fprintf('%s\n','')
    fprintf('%s','=================================')
    fprintf('%s\n','')
    fprintf('%s','Correct flight attitude without side lobes removal')
    fprintf('%s','using SMART attitude data')
    fprintf('%s\n','')
    fprintf('%s','=================================')

    % List relevant files
    fileNames = listFiles([radarDir '*.nc']);
    % If no files were found, try mmclx
    if isempty(fileNames)
        fileNames = listFiles([radarDir '*.mmclx']);
    end
%     fprintf('%s\n','')
%     disp('Found the following mira files:')
%     fprintf('\t%s\n',fileNames{:})

    % Start processing
    fprintf('%s\n','')
    disp('Start processing')
%     for i=1:length(flightdates_use)       % loop all files
    fileNameUse = listFiles([radarDir '*' flightdate '*'], 'full');

    if ~isempty(fileNameUse)

        % Loop files if multiple files from one flight exist
        for j=1:length(fileNameUse)
            % Concatenate path and file name
            RadarFile = fileNameUse{j};

            disp(['  file: ' fileNameUse{j}])
            fprintf('%s\n','')

            % Combine radar data with Smart data
            radarCorrectAtt_smart(RadarFile,versionNumber,radarOutDir, missingvalule,'nolobes')

        end
    end
%     end

    fprintf('%s\n','')
    disp('Finished processing')

    % Look for files
    fileNames = listFiles([radarOutDir '*' versionNumber '.1.nc']);
    fprintf('%s\n','')
    
    % Display
%     disp('Found the following .2 version files:')
%     fprintf('\t%s\n',fileNames{:})
end

%% Subversion 2: flight angles corrected with bahamas

if convertmarker==2
    % output
    fprintf('%s\n','')
    fprintf('%s','=================================')
    fprintf('%s\n','')
    fprintf('%s','Correct flight attitude without side lobes removal')
    fprintf('%s','using BAHAMAS attitude data')
    fprintf('%s\n','')
    fprintf('%s','=================================')

    % List relevant files
    fileNames = listFiles([radarDir '*.nc']);
    % If no files were found, try mmclx
    if isempty(fileNames)
        fileNames = listFiles([radarDir '*.mmclx']);
    end
%     fprintf('%s\n','')
%     disp('Found the following mira files:')
%     fprintf('\t%s\n',fileNames{:})

    % Start processing
    fprintf('%s\n','')
    disp('Start processing')
%     for i=1:length(flightdates_use)       % loop all files
    fileNameUse = listFiles([radarDir '*' flightdate '*']);

    if ~isempty(fileNameUse)

        % Loop files if multiple files from one flight exist
        for j=1:length(fileNameUse)
            % Concatenate path and file name
            RadarFile = [radarDir fileNameUse{j}];

            disp(['  file: ' fileNameUse{j}])
            fprintf('%s\n','')

            % Check if bahamas file exits
            checkBahamas = listFiles([bahamasDir '*' flightdate '*']);

            if isempty(checkBahamas)

            else
                % Combine radar data with Bahamas data
                radarCorrectAtt_bahamas(RadarFile,versionNumber,radarOutDir, missingvalule,'nolobes')
            end

        end
    end
%     end

    fprintf('%s\n','')
    disp('Finished processing')

    % Look for files
    fileNames = listFiles([radarOutDir '*' versionNumber '.2.nc']);
    fprintf('%s\n','')
    
    % Display
%     disp('Found the following .2 version files:')
%     fprintf('\t%s\n',fileNames{:})
end


%------------- END OF CODE --------------



