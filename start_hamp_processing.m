
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

% Get flight dates to use in this program
flightdates_use = specifyDatesToUse(t1,t2);

%%

% Check structure of folders for data files
checkfolderstructure(getPathPrefix, flightdates_use)

% Correct radar data for aircraft attitude
runRadarAttitude(flightdates_use)

% Unify data from bahamas, dropsondes, radar, radiometer onto common grid
run_unifyGrid(flightdates_use, comment, contact)

% Plot quicklooks for latest version
plotHAMPQuicklook_sepFiles(flightdates_use)