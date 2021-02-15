
%% Comments for data files
% Specify comment to be included into data files
comment = 'Preliminary data! Data is uncalibrated. Only use for preliminary work!';
% Specify contact information
contact = 'heike.konow@uni-hamburg.de';

%% Output file name prefix
% The usual file name will follow the format: 
% <instrument>_<date>_v<version-number>.nc
% An additional file name prefix can be specified here (e.g. for EUREC4A),
% if no prefix is necessary, set to empty string ('')
% filenameprefix = 'EUREC4A_HALO_';
filenameprefix = '';

%% Specify time frame for data conversion
% Start date
t1 = '20200118';  
% End date
t2 = '20200219';
% ! Add flight information to file flight_dates.m if they aren't already in
% there

%% Processing steps
correctAttitude = false;
addRadarMask = true;
unifyGrid = true;
quicklooks = true;
removeClutter = true;
removeRadiometerErrors = true;  % Only possible if errors have been identified using run_assessData.m
correctRadiometerTime = true;

%% Set version information
version = 0;
subversion = 9;

%% Missing value
% Set value for missing value (pixels with no measured signal). This should
% be different from NaN, since NaN is used as fill value (pixels where no
% measurements were conducted)
missingvalue = -888;
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

%% Processing

% Check structure of folders for data files
checkfolderstructure(getPathPrefix, flightdates_use)
    
if correctAttitude
    % Correct radar data for aircraft attitude
    runRadarAttitude(flightdates_use, missingvalue)
end

if addRadarMask
    % Create radar info mask
    run_makeRadarMasks(landMask, noiseMask, calibrationMask, surfaceMask, seaSurfaceMask, ...
                        flightdates_use, numRangeGatesForSeaSurface)
end

if unifyGrid
    % Unify data from bahamas, dropsondes, radar, radiometer onto common grid
    run_unifyGrid(version, subversion, flightdates_use, comment, contact, altitudeThreshold, ...
        rollThreshold, addRadarMask, removeClutter, correctRadiometerTime, missingvalue, fillvalue, filenameprefix)
end

if removeRadiometerErrors
    run_removeRadiometerErrors(version, subversion, flightdates_use)
end

if quicklooks
    % Plot quicklooks for latest version
    plotHAMPQuicklook_sepFiles(flightdates_use)
end