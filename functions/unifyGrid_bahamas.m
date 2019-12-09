function [uniTime,uniHeight,uniData] = unifyGrid_bahamas(pathtofolder,flightdate,bahamasVars)

interpolate = 1;

% Set path to output file
outfile = [pathtofolder 'all_mat/uniData_bahamas' flightdate '.mat'];

% If output file already exists, delete it
if exist(outfile,'file')
    delete(outfile)
end

extra_info = cell(1,4);

%% Load bahamas data
filename = listFiles([pathtofolder 'bahamas/*' flightdate '*']);
filepath = [pathtofolder 'bahamas/' filename{1}];

% List Bahamas variables in file
varsInBahamasFile = nclistvars(filepath);

% Read data
varNameUse = replaceBahamasVarName('TIME',varsInBahamasFile);
bahamasTime = ncread(filepath,varNameUse{1});
% Convert unix time to SDN
bahamasTime = unixtime2sdn(bahamasTime);

% Check for variable names and read accordingly
varNameUse = replaceBahamasVarName('IRS_ALT',varsInBahamasFile);
% Read data
bahamasAlt = ncread(filepath,varNameUse{1});

%% Define grid
% Define grid for height data
uniHeight = (0:30:max(bahamasAlt))';
% Define grid for time data
uniTime = bahamasTime(1):1/24/60/60:bahamasTime(end);
% Create empty variable according to unified grid
uniData = nan(length(uniHeight),length(uniTime));

extra_info(end+1,:) = {'time','seconds since 1970-01-01 00:00:00 UTC','time','uniTime'};
extra_info(end+1,:) = {'height','m','height','uniHeight'};

% Display information
disp(['Flight from ' datestr(uniTime(1),'HH:MM') ' to ' datestr(uniTime(end),'HH:MM')])


%% Bahamas data

% Check if Bahamas data is 10 Hz
if length(bahamasTime)==10*length(uniTime)
    % Get index of 1Hz data from bahamas
    ind1Hz = bahamas10Hz_to_1Hz(bahamasTime);
    bahamasTime10Hz = bahamasTime;
    bahamasTime = bahamasTime(ind1Hz);
    bahamasAlt = bahamasAlt(ind1Hz);
end

% Select Bahamas variables to consider
% bahamasVars = {'mixratio','P','RH','speed_air','theta','theta_v','Tv','U','V','W',...
%                'wa','ws','Ts','Td','T','heading','pitch','roll','lat','lon'};
% bahamasVars = {'MIXRATIO','PS','RELHUM','THETA','U','V','W','IRS_ALT'...
%                 'IRS_HDG','IRS_THE','IRS_PHI','IRS_LAT','IRS_LON','TS'};
            
bahamasVarsUse = cellfun(@(x,y) replaceBahamasVarName(x,varsInBahamasFile),...
                 bahamasVars,'UniformOutput',false);
bahamasVars = [bahamasVarsUse{:}];
           
% Check for available variables
indVars = cellfun(@(x) ismember(x,varsInBahamasFile),bahamasVars);
% Remove variables from list that do not exist in Bahamas file
bahamasVars_tmp = bahamasVars;
bahamasVars = bahamasVars(indVars~=0);

if isempty(bahamasVars)
    % Check if variables exist with different name
    bahamasVars = bahamasVars_tmp;
    for i=1:length(bahamasVars)
        varNameUse = replaceBahamasVarName(bahamasVars{i},varsInBahamasFile);
        if ~isempty(varNameUse)
            bahamasVars(strcmp(bahamasVars,bahamasVars{i})) = varNameUse;
        end
    end           

    % Check for available variables
    indVars = cellfun(@(x) ismember(x,varsInBahamasFile),bahamasVars);
    % Remove variables from list that do not exist in Bahamas file
    bahamasVars = bahamasVars(indVars~=0);
end

clear bahamasVars_tmp

% Only read if there are variables to be read
if ~isempty(bahamasVars)
    % Replace variable names with the ones to use in all files
    trueNames = bahamasVarnameLookup(bahamasVars);

    % Get index for time information
    indTime = get_indTime(uniTime,bahamasTime);
    % Get index for height information
    indHeight = get_indHeight(uniHeight,bahamasAlt,'bahamas');

    % Check if Bahamas data is 10 Hz
    % if length(bahamasTime)==10*length(uniTime)
    %     % Get index of 1Hz data from bahamas
    %     ind1Hz = bahamas10Hz_to_1Hz(bahamasTime);
    % end

    % Loop variables
    for i=1:length(bahamasVars)
        % Display variable name
        disp(bahamasVars{i})

        % Read bahamas data
        data = ncread(filepath,bahamasVars{i});

        % Replace missing value with nan
        data(data<-9000) = nan;

        if interpolate && sum(isnan(data))>0
            if exist('bahamasTime10Hz','var')
                timeInterp = bahamasTime10Hz;
            else
                timeInterp = bahamasTime;
            end
            % Only interpolate data if not all are nan
            if sum(~isnan(data))>0
                interpolated_data = interpolateData(timeInterp,data,3000);
                % Rename
                data = interpolated_data;
            end
        end

        % Read units and long name
        unitsTemp = ncreadatt(filepath,bahamasVars{i},'units');
        longNameTemp = ncreadatt(filepath,bahamasVars{i},'long_name');
        longNameTemp_1d = [longNameTemp '; 1d data'];
        longNameTemp_2d = [longNameTemp '; 2d data'];
        extra_info(end+1,:) = {trueNames{i},unitsTemp,longNameTemp_2d,['uniBahamas' trueNames{i}]};

        % Transpose if necessary and error check
        if size(data,1)==length(uniTime) && size(data,2)==1
            data = data';
        elseif exist('ind1Hz','var')
            data = data(ind1Hz);
        elseif sum(size(data)==length(uniTime))==0
            error('Problem: Bahamas data dimensions don''t agree')
        end

        % Combine data from different files
        tmp_data = transferDataBahamas(uniData,data,indHeight,indTime);
        eval(['uniBahamas' trueNames{i} ' = tmp_data;'])

        % Test if only one value per time step is in variable
        if sum(sum(~isnan(tmp_data),1)<=1)==length(uniTime)
            tmp_data_1d = nansum(tmp_data,1);
            extra_info(end+1,:) = {trueNames{i},unitsTemp,longNameTemp_1d,['uniBahamas' trueNames{i} '_1d']};
            eval(['uniBahamas' trueNames{i} '_1d = tmp_data_1d;'])
        else
            error(['Fehler: ' trueNames{i}])
        end
        clear data tmp_data tmp_data_1d
    end
end
clear indTime indHeight bahamasTime10Hz



%%
extra_info(end+1,:) = {'flightdate','','Date of flight','flightdate'};

%% Save data

% Delete first entry from extra_info cell
extra_info(1,:) = [];

% Clear universal arrays
clear uniData unitsTemp 

save(outfile,'uni*','flightdate','extra_info')



