
%% Specify time frame for data conversion
% Start date
t1 = '20190517';  
% End date
t2 = '20190517';

% Get flight dates to use in this program
flightdates_use = specifyDatesToUse(t1,t2);

%%


checkfolderstructure

runRadarAttitude(flightdates_use)

run_unifyGrid

