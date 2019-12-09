function data = filterSpikes(data,varargin)

% If no value is specified in input
if nargin==1
    % Set allowed difference to half of overall data range in profile
    range = abs(max(data)-min(data))/2;
else
    range = varargin{1};
end

% Absolute differences between neighbouring data points
differences = abs(diff(data));

% Indices of spikes
indSpike = differences>range;

% Set spiking values to nan
data(indSpike) = nan;