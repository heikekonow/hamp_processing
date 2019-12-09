function flightdates_use = specifyDatesToUse(t1,t2)

%% Specify time frame for data conversion
% Start date
% t1 = '20161018';  
% % End date
% t2 = '20161018';

% Convert to numeric
t1 = str2num(t1);
t2 = str2num(t2);

%% List files

% Load information on flight dates and campaigns
flight_dates;

% Extract dates
flightdates_all = NARVALdates(:,1);
flightdates_all = str2num(cell2mat(flightdates_all));

% Find entries to use in this conversion
ind1 = find(flightdates_all>=t1,1,'first');
ind2 = find(flightdates_all<=t2,1,'last');

% Extract dates to use in this conversion
flightdates_use = flightdates_all(ind1:ind2);

% Convert back to strings for filename comparison
flightdates_use = cellstr(num2str(flightdates_use));