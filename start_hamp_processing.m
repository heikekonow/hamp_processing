
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


% checkfolderstructure(getPathPrefix, flightdates_use)

% runRadarAttitude(flightdates_use)

run_unifyGrid(flightdates_use, comment, contact)

