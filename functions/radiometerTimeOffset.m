function [timeOffsetRange, timeOffsetValue] = radiometerTimeOffset(flightdate, frequency)

timeOffsetsAll = {...
    '20200119',    'HAMP-WF',    ':',          -141;
    '20200122',    'none   ',    ':',             0;
    '20200124',    'HAMP-KV',    ':',            -1;
    '20200124',    'HAMP-WF',    ':',            -2;
    '20200124',    'HAMP-G ',    '1:21001',      -7;
    '20200124',    'HAMP-G ',    '21001:29401',  -3;
    '20200126',    'HAMP-KV',    '1:23351',      -2;
    '20200126',    'HAMP-WF',    '1:23351',       1;
    '20200126',    'HAMP-G ',    '23701:',       -3;
    '20200128',    'none   ',    ':',             0;
    '20200130',    'HAMP-WF',    ':',            -1;
    '20200130',    'HAMP-G ',    '21201:',       -3;
    '20200202',    'HAMP-KV',    '4001:6211',    -2;
    '20200202',    'HAMP-WF',    '1:2001',       -3;
    '20200202',    'HAMP-WF',    '2001:4001',    -1;
    '20200202',    'HAMP-WF',    '4001:6255',    -3;
    '20200202',    'HAMP-WF',    '6255:6721',    -2;
    '20200202',    'HAMP-WF',    '6721:',        -1;
    '20200202',    'HAMP-G ',    ':',            -2;
    '20200205',    'HAMP-KV',    ':',            -3;
    '20200205',    'HAMP-WF',    ':',            -4;
    '20200207',    'HAMP-KV',    '21301:23261',  -2;
    '20200207',    'HAMP-WF',    '1:22401',       2;
    '20200209',    'HAMP-G ',    ':',            -2;
    '20200211',    'HAMP-KV',    '1:22901',      -2;
    '20200211',    'HAMP-G ',    '21001:23501',  -5;
    '20200213',    'none   ',    ':',             0;
    '20200215',    'HAMP-KV',    '20484:',       -1;
    '20200215',    'HAMP-WF',    '2034:28757',    2;
    '20200218',    'HAMP-WF',    ':',            -1;
    '20200218',    'HAMP-G ',    ':',            -4;
    };

offsetDates = timeOffsetsAll(:,1);
offsetModules = timeOffsetsAll(:,2);

indexDate = strcmp(flightdate, offsetDates);

% Explanation for different radiometer modules
% 1: 183,   f>180           (G band)
% 2: 11990, f>=90 & f<180   (WF band)
% 3: KV,    f<90            (KV band)

if frequency >= 180
    freqString = 'HAMP-G ';
elseif frequency>=90 && frequency<180
    freqString = 'HAMP-WF';
elseif frequency < 90
    freqString = 'HAMP-KV';
else
    error('Frequency not found')
end

indexFrequency = strcmp(freqString, offsetModules);

indexEntry = indexFrequency & indexDate;

timeOffsetRange = timeOffsetsAll(indexEntry, 3);
timeOffsetValue = cell2mat(timeOffsetsAll(indexEntry, 4));