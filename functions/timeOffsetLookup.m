function timeOffset = timeOffsetLookup(date)

% Values determined from standard deviation of reflectivity maximum as
% ground (see memo)
tOffset =   {'20131210',-2;
             '20131211',-2;
             '20131212',-2;
             '20131214',-2;
             '20131215',-1;
             '20131216',-1;
             '20131219', 0;
             '20131220',-2;
             '20140107',-2;
             '20140109',-2;
             '20140112',-1;
             '20140118',-19;
             '20140120',-2;
             '20140121',-2;
             '20140122',-1;
             '20160808', 0;%-2;
             '20160810', 0;
             '20160812', 0;
             '20160815', 0;
             '20160817', 0;
             '20160819', 1;
             '20160822', 0;
             '20160917', 0;
             '20160921', 0;
             '20160923', 0;
             '20160926', 0;
             '20160927', 1;
             '20161001', 0;
             '20161006', 0;
             '20161009', 1;
             '20161010', 0;
             '20161013', 0;
             '20161014', 0;
             '20161015', 1;
             '20161018', 0;
            };

% Get index of date
index = cellfun(@(x) strcmp(x,date),tOffset(:,1))==1;

% If date is not in list, assume offset of 0 seconds, else, copy to output
% variable
if sum(index)==0
    timeOffset = 0;
else
    timeOffset = tOffset{index,2};
end