function gaplength = countDataGapLength(dataseries)

switchBack = 0;

% Check if dataseries is horizontal vector, otherwise, transpose
if size(dataseries,1)~=1
    dataseries = dataseries';
    switchBack = 1;
end

% Find nan values and convert to double
a = double(isnan(dataseries));

% Detect switching between data and nan
c=diff(a);
% Find switching from data to nan
start=find(c==1)+1;
% Find switching from nan to data
stop=find(c==-1)+1;

% If first value in dataseries is NaN
if isnan(dataseries(1))
    start=[1 start];
end

% If last value in dataseries is NaN
if isnan(dataseries(end))
    stop=[stop length(dataseries)+1];
end

% Calculate length of data gaps
nanlength=stop-start;
% Write data gap length into array as long as dataseries
for i=1:length(nanlength)
    a(start(i):(stop(i)-1))=nanlength(i);
end

% Rename
gaplength = a;

if switchBack
    gaplength = gaplength';
end

% see: https://de.mathworks.com/matlabcentral/answers/42185-vector-index-of-consecutive-gap-nan-lengths
% modified and tested by me (11.11.16)