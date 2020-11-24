
%% Comments for data files
% Specify comment to be included into data files
comment = 'Preliminary data! Data is uncalibrated. Only use for preliminary work!';
% Specify contact information
contact = 'heike.konow@uni-hamburg.de';

%% Specify time frame for data conversion
% Start date
t1 = '20200119';  
% End date
t2 = '20200218';
% ! Add flight information to file flight_dates.m if they aren't already in
% there

%% Processing steps
correctAttitude = false;
addRadarMask = true;
unifyGrid = true;
quicklooks = true;
removeClutter = true;

%% Set version information
version = 0;
subversion = 7;

%% Missing value
% Set value for missing value (pixels with no measured signal). This should
% be different from NaN, since NaN is used as fill value (pixels where no
% measurements were conducted)
missingvalule = -888;
fillvalue = NaN; % !!! changes not yet applied in data creation !!!

%%
% Set threshold for altitude to discard radiometer data
altitudeThreshold = 4800;
% Set threshold for roll angle to discard radiometer data
rollThreshold = 5;

% Get flight dates to use in this program
flightdates_use = specifyDatesToUse(t1,t2);

% Add radar data mask
landMask = 1;
noiseMask = 1;
calibrationMask = 1;
surfaceMask = 1;
seaSurfaceMask = 1;
numRangeGatesForSeaSurface = 4;

%%

% Check structure of folders for data files
checkfolderstructure(getPathPrefix, flightdates_use)

if correctAttitude
    % Correct radar data for aircraft attitude
    runRadarAttitude(flightdates_use, missingvalule)
end

if addRadarMask
    % Create radar info mask
    run_makeRadarMasks(landMask, noiseMask, calibrationMask, surfaceMask, seaSurfaceMask, ...
                        flightdates_use, numRangeGatesForSeaSurface)
end

if unifyGrid
    % Unify data from bahamas, dropsondes, radar, radiometer onto common grid
    run_unifyGrid(version, subversion, flightdates_use, comment, contact, altitudeThreshold, ...
        rollThreshold, addRadarMask, removeClutter, missingvalule, fillvalue)
end

if quicklooks
    % Plot quicklooks for latest version
    plotHAMPQuicklook_sepFiles(flightdates_use)
end