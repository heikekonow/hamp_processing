function [time, timeOffsetRange, timeOffsetValue] = radiometerTimeOffset(flightdate, frequency, time)

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

% Copy data to variables
offsetDates = timeOffsetsAll(:,1);
offsetModules = timeOffsetsAll(:,2);

% Find date index
indexDate = strcmp(flightdate, offsetDates);

% Explanation for different radiometer modules
% 1: 183,   f>180           (G band)
% 2: 11990, f>=90 & f<180   (WF band)
% 3: KV,    f<90            (KV band)

% Translate frequency to string from table above
if frequency >= 180
    freqString = 'HAMP-G ';
elseif frequency>=90 && frequency<180
    freqString = 'HAMP-WF';
elseif frequency < 90
    freqString = 'HAMP-KV';
else
    error('Frequency not found')
end

% Find frequency index
indexFrequency = strcmp(freqString, offsetModules);

% Find row where frequency and data match given date and frequency
indexEntry = indexFrequency & indexDate;

% Extract entries from table
timeOffsetRange = timeOffsetsAll(indexEntry, 3);
timeOffsetValue = cell2mat(timeOffsetsAll(indexEntry, 4));

%%%%%%%%%%%
% Apply time offset values
for i=1:length(timeOffsetRange)
    
    % Get colon position from string
    colPos = regexp(timeOffsetRange{i}, ':');
    
    % Analyse time offset index
    if strcmp(timeOffsetRange{i}, ':')          % ':'
        ind(1) = 1;
        ind(2) = length(time);
        
    elseif strncmp(timeOffsetRange{i}, ':', 1)  % ':yyyy'
        ind(1) = 1;
        a = timeOffsetRange{i}(2:end);
        ind(2) = str2double(a);
        
    elseif colPos==length(timeOffsetRange{i})
        a = timeOffsetRange{i}(1:colPos-1);     % 'xxxx:'
        
        ind(1) = str2double(a);
        ind(2) = length(time);
        
    else                                        % 'xxxx:yyyy'
        ind{1} = timeOffsetRange{i}(1:colPos-1);
        ind{2} = timeOffsetRange{i}(colPos+1:end);
        ind = cellfun(@str2double, ind);
    end
    
    % Apply offset to time array
    time(ind(1):ind(2)) = time(ind(1):ind(2)) + timeOffsetValue(i) ./24./60./60;
    clear ind
end