function run_makeRadarMasks(landMask, noiseMask, calibrationMask, surfaceMask, seaSurfaceMask, flightdates)

% Run script to call functions for radar data masks



% campaign = 'NARVAL-I';
% campaign = 'NARVAL-II';
campaign = getCampaignName(flightdates(1));

% Define output file
basefolder = [getPathPrefix getCampaignFolder(flightdates{1})];
outfile = [basefolder 'aux/radarMask_' campaign '.mat'];

% Define dates to use
% flightdates = get_campaignDates(campaign);

if landMask
    disp('Generating land sea mask for all flights.')
    make_haloLandMask(flightdates,outfile)
else
    disp('Skipping land sea mask...')
end

if noiseMask
    disp('Generating radar noise mask for all flights.')
    make_radarNoiseMask(flightdates,outfile,'noise')
else
    disp('Skipping radar noise mask...')
end

if calibrationMask
    disp('Generating radar calibration mask for all flights.')
    make_radarNoiseMask(flightdates,outfile,'calibration')
else
    disp('Skipping radar calibration mask...')
end

if surfaceMask
    disp('Generating surface mask for all flights.')
    make_radarSurfaceMask(flightdates,outfile)
else
    disp('Skipping surface mask...')
end

if seaSurfaceMask
    disp('Generating sea surface mask for all flights.')
    make_radarSeaSurfaceMask(flightdates,outfile)
else
    disp('Skipping sea surface mask...')
end

disp('Combining all masks into one')
make_radarInfoMask(flightdates,outfile,'figures')
% make_radarInfoMask(flightdates_mask,outfile)