function unifyGrid_radiometer(pathtofolder,flightdate,uniTime,radiometerVars)

interpolate = 1;

% Set path to output file
outfile = [pathtofolder 'all_mat/uniData_radiometer' flightdate '.mat'];

% If output file already exists, delete it
if exist(outfile,'file')
    delete(outfile)
end

extra_info = cell(1,4);

%% Radiometer data

% Select Radiometer variables to consider
% radiometerVars = {'183','11990','KV'};

interpolate_flag = cell(1,3);

for i=1:length(radiometerVars)
        
    % Display variable name
    disp(radiometerVars{i})

    % List files from specified date
    filename = listFiles([pathtofolder 'radiometer/' radiometerVars{i} '/*' flightdate '*']);

    % If no files were found, it's probably because the date is written in
    % yymmdd format in file names instead of yyyymmdd
    if isempty(filename)
        date_backup = flightdate;
        flightdate = flightdate(3:end);
        filename = listFiles([pathtofolder 'radiometer/' radiometerVars{i} '/*' flightdate '*']);
        
        % Check if flight ended after 00z
        if ~strcmp(datestr(uniTime(end), 'yymmdd'), flightdate)
            filename_2 = listFiles([pathtofolder 'radiometer/' radiometerVars{i} '/*' datestr(uniTime(end), 'yymmdd') '*']);
            filename = [filename;filename_2];
        end
        flightdate = date_backup;
    end

    if ~isempty(filename)
        % Loop all files from day; should work either way: if it is only
        % one file and if it is several files
        
        for j=1:length(filename)
            % Set path to file
            filepath = [pathtofolder 'radiometer/' radiometerVars{i} '/' filename{j}];
            % Read time data
            radiometerTime{j} = ncread(filepath,'time');
            % Read radiometer data
            data{j} = ncread(filepath,'TBs');
            % Read channel frequencies
            freq{j} = ncread(filepath,'frequencies');
        end
        
        % Convert cells to matrices
        data = [data{:}];
        % Transpose for concatenation
        radiometerTime = radiometerTime';
        % Convert to matrix and transpose back to match data matrix
        radiometerTime = transpose(cell2mat(radiometerTime));
        % Convert to matrix
        freq = [freq{:}];
        % Check if all frequencies are the same
        if sum(sum(diff(freq,1,2)))==0
            % Only keep first column
            freq = freq(:,1);
        else
            error('Check radiometer frequencies')
        end
        
        % Check if there are multiple time stamps in radiometer time
        % e.g. EUREC4A: 4 Hz sampling rate with same second as time stamp
        if ~isequal(radiometerTime, unique(radiometerTime))
            [radiometerTime, data] = averageMultTimestamps(radiometerTime, data);
        end
        
        % Convert to serial date number
        radiometerTime = time2001_2sdn(radiometerTime);
        
        % Round time to seconds to avoid numerical deviations
        radiometerTime = dateround(radiometerTime', 'second');
        
        % Remove times in the future and past
        ind_off = find(radiometerTime > datenum(flightdate,'yyyymmdd')+2 | ...
                        radiometerTime < datenum(flightdate,'yyyymmdd')-2);
        % Delete respective time and data
        radiometerTime(ind_off) = nan;
        data(:,ind_off) = nan;
        
        % Omit time jumps ind radiometer data
        indJump = indRadiometerTimeJumps(radiometerTime);
        radiometerTime(indJump) = nan;
        % Remove data from time jumps
        data(:,indJump) = nan;
        
        % Read units and long name
        unitsTemp = ncreadatt(filepath,'TBs','units');
        longNameTemp = 'Brightness temperature';
        
        % Preallocate array
        uniDataRadiometer = nan(size(data,1),length(uniTime));
        
        % Catch unusual cases where first time entry is nan
        if isnan(radiometerTime(1))
            radiometerTime(1) = [];
            data(:,1) = [];
        end
        
        % If first radiometer time step is before first unified time step
        % and last radiometer time step is after last unified time step
        % (i.e. radiometer measurement started before take off and ended
        % after landing)
        if radiometerTime(1)<uniTime(1) && radiometerTime(end)>uniTime(end)
            % Find last time step before take off
            indStart = find(radiometerTime<uniTime(1),1,'last');
            % Find first tim step after landing
            indEnd = find(radiometerTime>uniTime(end),1,'first');
            % Restrict radiometer time array to between take off and landing
            radiometerTime = radiometerTime(indStart+1:indEnd-1);
            % Restrict data array to between take off and landing
            data = data(:,indStart+1:indEnd-1);
            
        % If first radiometer time step is before first unified time step
        % and last radiometer time step is before last unified time step
        % (i.e. radiometer measurement started before take off and ended
        % before landing)
        elseif radiometerTime(1)<uniTime(1) && radiometerTime(end)<uniTime(end)
            % Find last time step before take off
            indStart = find(radiometerTime<uniTime(1),1,'last');
            % Remove radiometer time steps before take off
            radiometerTime = radiometerTime(indStart+1:end);
            % Remove data entries before take off
            data = data(:,indStart+1:end);
            
        % If first radiometer time step is after first unified time step
        % and last radiometer time step is after last unified time step
        % (i.e. radiometer measurement started after take off and ended
        % after landing)
        elseif radiometerTime(1)>uniTime(1) && radiometerTime(end)>uniTime(end)
            % Find first tim step after landing
            indEnd = find(radiometerTime>uniTime(end),1,'first');
            % Remove radiometer time steps after landing
            radiometerTime = radiometerTime(1:indEnd-1);
            % Remove data entries after landing
            data = data(:,1:indEnd-1);
        end
        
        % If the first time step is nan, remove everything until first
        % non-nan time step
        if isnan(radiometerTime(1))
            firstNonNan = find(~isnan(radiometerTime),1,'first');
            radiometerTime(1:firstNonNan-1) = [];
            data(:,1:firstNonNan-1) = [];
        end
        
        % If the last time step is nan, remove everything after last
        % non-nan time step
        if isnan(radiometerTime(end))
            lastNonNan = find(~isnan(radiometerTime),1,'last');
            radiometerTime(lastNonNan+1:end) = [];
            data(:,lastNonNan+1:end) = [];
        end
        
        % Get indexes corresponding to unified time array 
        [indTimeUni,indTimeRadiometer] = get_indTimeRadiometer(uniTime,radiometerTime);

        % Copy data from corresponding times to new unified data array
        uniDataRadiometer(:,indTimeUni(~isnan(indTimeUni))) = ...
            data(:,indTimeRadiometer(~isnan(indTimeRadiometer)));

        
        % Interpolated data
        if interpolate && sum(sum(isnan(uniDataRadiometer)))>0
            % Make sure that only unique times are left, otherwise,
            % interpolation routine won't work
            % Obs: use option 'stable' to prevent sorting of values
%             [radiometerTime_unique,ind_uniqueTime,~] = unique(radiometerTime,'stable');
%             timeInterp = radiometerTime;
%             data = data(:,ind_uniqueTime);
            [interpolated_data,interpolate_flag{i}] = interpolateData(uniTime,uniDataRadiometer,30);

            % Rename
            uniDataRadiometer = interpolated_data;

        end
        
        % Rename variable
        eval(['uniRadiometer' radiometerVars{i} ' = uniDataRadiometer;'])
        eval(['uniRadiometer' radiometerVars{i} '_freq = freq;'])
    else
        uniDataRadiometer = ones(size(uniTime)) .* -888;
        freq = -888;
        
        interpolate_flag{i} = ones(size(uniTime)) .* -888;
        % Rename variable
        eval(['uniRadiometer' radiometerVars{i} ' = uniDataRadiometer;'])
        eval(['uniRadiometer' radiometerVars{i} '_freq = freq;'])
    end
    
    % Clean up
    clear indTimeUni indTimeRadiometer uniDataRadiometer data freq radiometerTime
end

% Combine measurements from all modules into one variable
uniRadiometer = [uniRadiometerKV;...
                 uniRadiometer11990;...
                 uniRadiometer183];
uniRadiometer_freq = [uniRadiometerKV_freq;...
                      uniRadiometer11990_freq;...
                      uniRadiometer183_freq];
                  
% Replace faulty frequency value
uniRadiometer_freq = round(100.*double(uniRadiometer_freq))./100;
uniRadiometer_freq(uniRadiometer_freq==197.31) = 195.81;
uniRadiometer_freq = single(uniRadiometer_freq);
                  
interpolate_flag = vertcat(interpolate_flag{:});

clear uniRadiometer11990* uniRadiometer183* uniRadiometerKV*

extra_info(end+1,:) = {'TB','K','Brightness temperature','uniRadiometer'};
extra_info(end+1,:) = {'freq','GHz','channel center frequency','uniRadiometer_freq'};
extra_info(end+1,:) = {'time','seconds since 1970-01-01 00:00:00 UTC','time','uniTime'};
extra_info(end+1,:) = {'Flag for interpolation','','interpolate_flag','interpolate_flag'};

%%
extra_info(end+1,:) = {'flightdate','','Date of flight','flightdate'};

%% Save data

% Delete first entry from extra_info cell
extra_info(1,:) = [];

% Clear universal arrays
clear uniData unitsTemp 

% Save data to file
save(outfile,'uni*','flightdate','extra_info','interpolate_flag')

end

function [tNew, dataNew] = averageMultTimestamps(t, data)
    
    % Get unique time stamps and indices of common time stamps in data
    [tNew, ~, idx] = unique(t);
    
    % Loop non time dimension (i.e. frequencies)
    for i=size(data,1):-1:1
        dataNew(i, :) = accumarray(idx, data(i, :), [], @mean);
    end

end