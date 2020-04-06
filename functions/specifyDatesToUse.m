%% specifyDatesToUse
%   specifyDatesToUse - get all flight dates within a given date range
%       look up flight dates in range from list of all flight dates; return
%       list of flight dates 
%       
%
%   Syntax:  flightdates_use = specifyDatesToUse(t1,t2)
%
%   Inputs:
%       t1  - Beginning of processing interval as string (yyyymmdd)
%       t2  - End of processing interval as string (yyyymmdd)
%
%   Outputs:
%       cell array of strings with flight dates in given range
%
%   Example:
%
%       flightdates_use = specifyDatesToUse('20161018','20161018')
%
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   April 2020; Last revision:

%%
function flightdates_use = specifyDatesToUse(t1,t2)

%% Convert to numeric
t1 = str2num(t1);
t2 = str2num(t2);

%% List files

% Load information on flight dates and campaigns
[NARVALdates, ~] = flight_dates;

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