
%% Comments for data files
% Specify comment to be included into data files
comment = 'Preliminary data! Data is uncalibrated. Only use for preliminary work!';
% Specify contact information
contact = 'heike.konow@uni-hamburg.de';

%% Specify time frame for data conversion
% Start date
t1 = '20200119';  
% End date
t2 = '20200119';
% ! Add flight information to file flight_dates.m if they aren't already in
% there

%% Set version information
version = 0;
subversion = 5;

%%
% Set threshold for altitude to discard radiometer data
altitudeThreshold = 4800;
% Set threshold for roll angle to discard radiometer data
rollThreshold = 5;

% Get flight dates to use in this program
flightdates_use = specifyDatesToUse(t1,t2);

% Add radar data mask
addRadarMask = true;
landMask = 1;
noiseMask = 1;
calibrationMask = 1;
surfaceMask = 1;
seaSurfaceMask = 1;
numRangeGatesForSeaSurface = 4;

%%

% Check structure of folders for data files
% checkfolderstructure(getPathPrefix, flightdates_use)

% Correct radar data for aircraft attitude
% runRadarAttitude(flightdates_use)

if addRadarMask
    % Create radar info mask
    run_makeRadarMasks(landMask, noiseMask, calibrationMask, surfaceMask, seaSurfaceMask, ...
                        flightdates_use, numRangeGatesForSeaSurface)
end

% Unify data from bahamas, dropsondes, radar, radiometer onto common grid
run_unifyGrid(version, subversion, flightdates_use, comment, contact, altitudeThreshold, rollThreshold, addRadarMask)

% Plot quicklooks for latest version
% plotHAMPQuicklook_sepFiles(flightdates_use)