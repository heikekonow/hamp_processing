clear; close all;

% Run script to call functions for radar data masks

landMask = 0;
noiseMask = 1;
calibrationMask = 0;
surfaceMask = 0;
seaSurfaceMask = 0;

% campaign = 'NARVAL-I';
% campaign = 'NARVAL-II';
campaign = '2016';

% Define output file
outfile = [getPathPrefix 'ucp_hamp_work_data/radarMask_' campaign '.mat'];

% Define dates to use
flightdates_mask = get_campaignDates(campaign);

if landMask
    disp('Generating land sea mask for all flights.')
    make_haloLandMask(flightdates_mask,outfile)
else
    disp('Skipping land sea mask...')
end

if noiseMask
    disp('Generating radar noise mask for all flights.')
    make_radarNoiseMask(flightdates_mask,outfile,'noise')
else
    disp('Skipping radar noise mask...')
end

if calibrationMask
    disp('Generating radar calibration mask for all flights.')
    make_radarNoiseMask(flightdates_mask,outfile,'calibration')
else
    disp('Skipping radar calibration mask...')
end

if surfaceMask
    disp('Generating surface mask for all flights.')
    make_radarSurfaceMask(flightdates_mask,outfile)
else
    disp('Skipping surface mask...')
end

if seaSurfaceMask
    disp('Generating sea surface mask for all flights.')
    make_radarSeaSurfaceMask(flightdates_mask,outfile)
else
    disp('Skipping sea surface mask...')
end

disp('Combining all masks into one')
make_radarInfoMask(flightdates_mask,outfile,'figures')
% make_radarInfoMask(flightdates_mask,outfile)