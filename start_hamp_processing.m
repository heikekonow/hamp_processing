
%% Comments for data files
% Specify comment to be included into data files
comment = 'Preliminary data! Data is uncalibrated. Only use for preliminary work!';
% Specify contact information
contact = 'heike.konow@uni-hamburg.de';

%% Specify time frame for data conversion
% Start date
t1 = '20200131';  
% End date
t2 = '20200131';
% ! Add flight information to file flight_dates.m if they aren't already in
% there

% Set threshold for altitude to discard radiometer data
altitudeThreshold = 4800;
% Set threshold for roll angle to discard radiometer data
rollThreshold = 5;

% Get flight dates to use in this program
flightdates_use = specifyDatesToUse(t1,t2);

landMask = 1;
noiseMask = 0;
calibrationMask = 0;
surfaceMask = 0;
seaSurfaceMask = 0;

%%

% Check structure of folders for data files
% checkfolderstructure(getPathPrefix, flightdates_use)

% Correct radar data for aircraft attitude
% runRadarAttitude(flightdates_use)

% Create radar info mask
run_makeRadarMasks(landMask, noiseMask, calibrationMask, surfaceMask, seaSurfaceMask, flightdates_use)

% % Unify data from bahamas, dropsondes, radar, radiometer onto common grid
run_unifyGrid(flightdates_use, comment, contact, altitudeThreshold, rollThreshold)

% Plot quicklooks for latest version
% plotHAMPQuicklook_sepFiles(flightdates_use)