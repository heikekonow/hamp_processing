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
        
        % Convert to serial date number
        radiometerTime = time2001_2sdn(radiometerTime);
        
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
%         extra_info(end+1,:) = {['TB_' radiometerVars{i}],unitsTemp,longNameTemp,['uniRadiometer' radiometerVars{i}]};
        
        % Read channel frequencies
%         freq = ncread(filepath,'frequencies');
%         extra_info(end+1,:) = {['freq_' radiometerVars{i}],'GHz','channel center frequency',['uniRadiometer' radiometerVars{i} '_freq']};

        % Preallocate radiometer data matrix of desired size    
%         uniDataRadiometer = nan(size(data,1),size(uniData,2));   
        uniDataRadiometer = nan(size(data,1),length(uniTime));
        
        if isnan(radiometerTime(1))
            radiometerTime(1) = [];
            data(:,1) = [];
        end

        if radiometerTime(1)<uniTime(1) && radiometerTime(end)>uniTime(end)
            indStart = find(radiometerTime<uniTime(1),1,'last');
            indEnd = find(radiometerTime>uniTime(end),1,'first');
            radiometerTime = radiometerTime(indStart+1:indEnd-1);
            data = data(:,indStart+1:indEnd-1);
        elseif radiometerTime(1)<uniTime(1) && radiometerTime(end)<uniTime(end)
            indStart = find(radiometerTime<uniTime(1),1,'last');
            radiometerTime = radiometerTime(indStart+1:end);
            data = data(:,indStart+1:end);
        elseif radiometerTime(1)>uniTime(1) && radiometerTime(end)>uniTime(end)
            indEnd = find(radiometerTime>uniTime(end),1,'first');
            radiometerTime = radiometerTime(1:indEnd-1);
            data = data(:,1:indEnd-1);
%             error('Problem, please check')
        end
        
        if isnan(radiometerTime(1))
            firstNonNan = find(~isnan(radiometerTime),1,'first');
            radiometerTime(1:firstNonNan-1) = [];
            data(:,1:firstNonNan-1) = [];
        end
        
        if isnan(radiometerTime(end))
            lastNonNan = find(~isnan(radiometerTime),1,'last');
            radiometerTime(lastNonNan+1:end) = [];
            data(:,lastNonNan+1:end) = [];
        end
        
        [indTimeUni,indTimeRadiometer] = get_indTimeRadiometer(uniTime,radiometerTime);

        uniDataRadiometer(:,indTimeUni(~isnan(indTimeUni))) = ...
            data(:,indTimeRadiometer(~isnan(indTimeRadiometer)));
%         for j=1:length(indTimeUni)
%             % If data at this time exist
%             if ~isnan(indTimeUni(j)) && ~isnan(indTimeRadiometer(j))
%                 % Copy data into new matrix
%                 uniDataRadiometer(:,indTimeUni(j)) = data(:,indTimeRadiometer(j));
%             end
%         end
        
        % Interpolated data
%         if interpolate && sum(sum(isnan(data)))>0
        if interpolate && sum(sum(isnan(uniDataRadiometer)))>0
            % Make sure that only unique times are left, otherwise,
            % interpolation routine won't work
            % Obs: use option 'stable' to prevent sorting of values
%             [radiometerTime_unique,ind_uniqueTime,~] = unique(radiometerTime,'stable');
%             timeInterp = radiometerTime;
%             data = data(:,ind_uniqueTime);
            [interpolated_data,interpolate_flag{i}] = interpolateData(uniTime,uniDataRadiometer,30);
%             interpolated_data = interpolateData(radiometerTime_unique,data,30);
            % Rename
            uniDataRadiometer = interpolated_data;
%             radiometerTime = radiometerTime_unique;
%             dataInterp = interp1(timeInterp(~isnan(data)),data(~isnan(data)),...
%                             timeInterp,'linear');
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
