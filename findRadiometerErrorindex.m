function [idx] = findRadiometerErrorindex(time, frequency, varargin)

% Convert time format
if isdatetime(time)
    time = datenum(time);
elseif nargin>2
    time = datenum(time, varargin{1});
end

% Check time format
if ~(all(time>700000) && all(time<800000))
    error('Time must either be given as serial date number, datetime, or string with string format as third input.')
end

% Get string for frequency
freqString = getHAMPfrequencyString(frequency);

% Get date as string
day = datestr(time(1), 'yyyymmdd');

% Get path to measurement file for current date
filepath = listFiles([getPathPrefix getCampaignFolder(day) 'radiometer/' freqString '/*' day(3:end) '*BRT*NC'], 'full', 'mat');

% Read time and convert to serial date number
t = time2001_2sdn(ncread(filepath, 'time'));

% Find indices of given time
idx(1) = find(t>=time(1), 1, 'first');
idx(2) = find(t<=time(2), 1, 'last');