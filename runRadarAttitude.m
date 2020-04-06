%% runRadarAttitude
%   runRadarAttitude - run aircraft attitude correction for radar data
%       use either Bahamas or Smart attitude data to correct radar
%       measurements with respect to aircraft pitch and roll angles
%       
%
%   Syntax:  runRadarAttitude(flightdates_use)
%
%   Inputs:
%       flightdates_use - flight dates to process, this is neccessary for
%                         campaign folder name
%
%   Outputs:
%       none; attitude corrected radar data in .mat files ind folder
%           ./radar_mira/
%
%   Example:
%
%       runRadarAttitude({'20200119', '20200122'})
%
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   April 2020; Last revision:


function runRadarAttitude(flightdates_use)


    
for i=1:length(flightdates_use)

    %% check if bahamas exists

    % Set path to bahamas and smart files
    bahamasDir = [getPathPrefix getCampaignFolder(flightdates_use{i}) 'bahamas/'];
    smartDir = [getPathPrefix getCampaignFolder(flightdates_use{i}) 'smartnav/'];
    
    % Look for files from flight
    if isempty(listFiles([bahamasDir '*.nc'])) ...
        && ~isempty(listFiles([smartDir '*.Asc']))

        % if yes, set marker to 1 (= convert with smart data)
        convertmarker = 1;
    elseif ~isempty(listFiles([bahamasDir '*.nc']))
        % if no, set marker to 2 (= convert with bahamas data)
        convertmarker = 2;
    else
        error('No aircraft attitude data. Can''t convert radar data')
    end
    
    % run runRadarAttComb with overloaded marker for smart or bahamas
    runRadarAttComb(convertmarker, flightdates_use{i})
end