
%% Specify time frame for data conversion
% Start date
t1 = '20200122';  
% End date
t2 = '20200202';

% ! Add flight information to file flight_dates.m if they aren't already in
% there

% Get flight dates to use in this program
flightdates_use = specifyDatesToUse(t1,t2);

%%


checkfolderstructure(getPathPrefix, flightdates_use)

runRadarAttitude(flightdates_use)

run_unifyGrid(flightdates_use)

