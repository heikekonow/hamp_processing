pathtoflightsegments = '/Users/heike/Documents/eurec4a/data_processing/EUREC4A_campaignData/flightsegments/';

t1 = '20200119';
t2 = '20200218';
flightdates_use = specifyDatesToUse(t1,t2);
segmentfiles = listFiles(pathtoflightsegments, 'full');
for i=1:length(segmentfiles)
    data{i} = ReadYaml(segmentfiles{i});
end

segmentDates = cellfun(@(x) datestr(x.date, 'yyyymmdd'), data, 'uni', 0);