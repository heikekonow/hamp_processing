%% lookForRadarCalManually
%   lookForRadarCalManually - Manually identify radar calibration intervals
%    Use this script to manually identify radar calibration intervals. This is
%    based on the original measurement files as they still contain the entire
%    ground echo. Calibration intervals can be identified by looking for
%    times, where the ground echo area is narrower than before and after.
%   
%    This script can also be used to identify erroneous measurements by the
%    cloud radar. In this case, zoom into error intervals instead of
%    calibration intervals, and replace the string 'calibration' with the
%    string 'noise' in the file radar_mask.m.
%
%   Syntax:  lookForRadarCalManually
%
%   Inputs:
%       Define campaign name in the beginning. This is used to look for
%       data and loop through flight dates.
%
%   Outputs:
%       Display of time intervals. Copy these lines into the file
%       'radar_mask.m'
%
%   Other m-files required: radar_mask.m 
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   July 2020; Last revision: 

%------------- BEGIN CODE --------------

% Clean up
clear; close all;

% Set campaign name
campaign = 'EUREC4A';

% Get all flight dates
flightdates = getCampaignDates(campaign);

% Get paht to data directory
folderpath = [getPathPrefix getCampaignFolder(flightdates{1}) 'radar/'];

% Loop flight dates
for i=1:length(flightdates)
    
    % List radar files
    files = listFiles([folderpath '*' flightdates{i} '*.nc'],'fullpath', 'latest');
    
    % Only process if measurement data are found
    if ~isempty(files)
        disp('Reading data')
        
        % Read data
        z = ncread(files,'Zg');
        z = 10 .* log(z);
        h = ncread(files,'range');
        t = ncread(files,'time');
        % Convert time to serial date number if necessary
        if ~issdn(t(1))
            t = unixtime2sdn(t);
        end
        
        % Create figure
        figure(1)
        % Plot data
        imagesc(t,h,z)
        set(gcf,'Position',[854 684 1048 421])
        addWhiteToColormap
        xlabel('Time (UTC)')
        ylabel('Height (m)')
        title(flightdates{i})
        datetick('x', 'HH:MM:SS' ,'keeplimits')
        xl = xlim;
        
        % Output in command line
        disp('Use the zoom tool to zoom into calibration interval and press any key.')

        pause
        disp('If calibration intervals were identified, copy the next line into radar_mask.m.')
        sprintf('%s'', [%16.9f %16.9f], ''calibration', flightdates{i}, xl(1), xl(2))
        disp('Press any key to continue.')
        pause
    end
end

%------------- END OF CODE --------------