% function run_convertDataSamd > CERA

%% Clean up
clear

%% Input

%%%%%%%%%%%%%%%%%%%%%
% Define which instruments to process
% instrumentList = {'radar','radiometer','bahamas','dropsondes'};
% instrumentList = {'radiometer'};
% instrumentList = {'radar'};
% instrumentList = {'dropsondes'};
instrumentList = {'radar', 'radiometer'};

% Set campaign to process
campaign = 'EUREC4A';
filenameprefix = 'EUREC4A_HALO_';

% Set threshold for roll angle to discard radiometer data
rollThreshold = 5;

% Get dates
dates = getCampaignDates(campaign);

% Set uniform data version to read
v = '0.10';

% Set data version in data base
versionInDatabase = '1.0';

% Set comment for output files
comment = '';

% Set path for new files to be written in
outpath = [getPathPrefix getCampaignFolder(dates) 'data4publ/'];

% Define netcdf format
ncformat = 'netcdf4';
% Define netcdf compression (value between 0 and 9, with 9 beeing strongest compression) 
deflatelevel = 5;
%%%%%%%%%%%%%%%%%%%%%

%%

% Look up instruments and associated variables 
outvars = lookup_var2read; 

% Loop instruments
for i=1:length(instrumentList)
    
    % Print out instrument name
    disp(instrumentList{i})
    
    % List all variables that should be written for this instrument
    outVarsForThisInstrument = outvars(strcmp(outvars,instrumentList{i}),:); 
    outVarsBAHAMAS = outvars(strcmp(outvars,'bahamas'),:);
    
    % Loop dates
    for j=1:length(dates) 
        
        % Print out date
        disp(dates{j})
        
        % Set flag to check if data is available
        nodata = false;
        
        %%%% READING %%%%
        %
        % Look up additional information 
        information = lookup_globalInformation(instrumentList{i}, dates{j}, versionInDatabase,comment);
        
        % Check if radar was operating
        if strcmp(instrumentList{i}, 'radar')
            testfile = listFiles([getPathPrefix getCampaignFolder(dates{j}) ...
                                  'all_nc/*' instrumentList{i} '*' dates{j} '*' v '*'], 'full', 'mat');
                              
            if ~ncVarInFile(testfile, 'dBZ')
                nodata = true;
            end
        end
        
        % If data is available
        if ~nodata
            
            % Read data
            [data_name, data_data, data_units, data_fillValue, data_missingValue] = ...
                        read_data(instrumentList{i}, dates{j}, v, outVarsForThisInstrument);

            % Read additional BAHAMAS data
            [data_name_bahamas, data_data_bahamas, data_units_bahamas, data_fillValue_bahamas, data_missingValue_bahamas] = ...
                        read_data('bahamas', dates{j}, v, outVarsBAHAMAS); %function defined below
            
            if ~strcmp(instrumentList{i},'dropsondes')
                
                % Concatenate variables
                data_name = [data_name; data_name_bahamas];
                data_data = [data_data; data_data_bahamas];
                data_units = [data_units; data_units_bahamas];
                data_fillValue = [data_fillValue; data_fillValue_bahamas];
                data_missingValue = [data_missingValue; data_missingValue_bahamas];
            end
            
            %%%% ADJUSTING %%%%
            %
            % Make roll flag for radar
            if strcmp(instrumentList{i},'radar') 
                % Generate flag to indicate aircraft turning
                [data_name_turn, turn_ind, ~, ~, ~] = ... %function defined below
                    makeRollFlag(dates{j}, v, rollThreshold);
                % Concatenate variables 
                data_name = [data_name; data_name_turn]; % first used from above, second output of the function
                data_data = [data_data; turn_ind];
                data_units = [data_units; {''}];
                data_fillValue = [data_fillValue; cell(1)];
                data_missingValue = [data_missingValue; cell(1)];
            end

            % Convert dropsonde temperature from degC to K
            if strcmp(instrumentList{i},'dropsondes')
                ind_temp = strcmp(data_name, 'ta');
                data_data{ind_temp} = data_data{ind_temp}+273.15;
                data_units{ind_temp} = 'K';
            end

            %%%% ATTRIBUTES %%%%
            %
            % Read attributes
            [data_standardName, data_longName, data_ancVars, data_comment] = ...
                        read_varAttribute(data_name, data_units, campaign); % function defined below

            % Find index of time in data
            indDataTime = strcmp(data_name,'time'); 
            if sum(indDataTime)==0
                indDataTime = strcmp(data_name, 'base_time');
            end

            % Generate file name string
            fileNameString = makeFileName(instrumentList{i}, dates{j}, information.Version_in_database, filenameprefix);

            %%%% WRITING %%%%
            %
            % Set path and file name for saving
            outfile = [outpath fileNameString]; 
            % Delete netcdf file if it already exists
            if exist(outfile,'file')
                delete(outfile)
            end
            % Write  output data
            write_data(outfile, information, data_name, data_data, data_fillValue, data_missingValue, ncformat, deflatelevel, rollThreshold) %use the function below

            % Clear data
            clear data_*
        end
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Function definitions %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function for reading existing uniform data set
function [data_name, data_data, data_units,data_fillValue, data_missingValue] = ...
        read_data(instrument,flightdates,version, outVarsForThisInstrument)
     
    % List uniform data files
    filetoread = listFiles([getPathPrefix getCampaignFolder(flightdates) 'all_nc/*' instrument...
                            '*' flightdates '*' version '*.nc'],'fullpath', 'mat');
    

    % If file with 'version' does not exist, take the latest one
    if isempty(filetoread)
        filetoread = listFiles([getPathPrefix getCampaignFolder(flightdates) 'all_nc/*' instrument...
                            '*' flightdates '*.nc'],'fullpath', 'latest', 'mat');
%         filetoread = filetoread{end};
    end

    % List all variables that exist in netcdf file
    varsInFile = nclistvars(filetoread);

    % Get number of variables to write into new file, used for
    % preallocating the data cells
    numOfVarsToWrite = length(outVarsForThisInstrument{2}); %Length of the input
    % Preallocate empty cells
    data_name = cell(numOfVarsToWrite,1);
    data_data = cell(numOfVarsToWrite,1);
    data_units = cell(numOfVarsToWrite,1);
    data_fillValue = cell(numOfVarsToWrite,1);
    data_missingValue = cell(numOfVarsToWrite,1);

    % Loop all variables that should be converted
    for varNum=1:numOfVarsToWrite

        % Get index of corresponding variable in uniform data set
        indVarInFile = strcmp(outVarsForThisInstrument{3}{varNum},varsInFile); 

        % If the variable was found in uniform data
        if any(indVarInFile)
            % Write info: name, data, units
            data_name{varNum} = outVarsForThisInstrument{2}{varNum}; %fill the empty cells from above 
            data_data{varNum} = ncread(filetoread,varsInFile{indVarInFile}); 
            data_units{varNum} = ncreadatt(filetoread,varsInFile{indVarInFile},'units');
            
            attnames = ncListAtt(filetoread, varsInFile{indVarInFile});
            
            if any(strcmp(attnames, '_FillValue'))
                data_fillValue{varNum} = ncreadatt(filetoread, varsInFile{indVarInFile}, '_FillValue');
            end
            if any(strcmp(attnames, 'missing_value'))
                data_missingValue{varNum} = ncreadatt(filetoread, varsInFile{indVarInFile}, 'missing_value');
            end
        else
            
            error(['Variable ' outVarsForThisInstrument{2}{varNum} ' not found in file!'])
        end
    end
end

function [data_standardName, data_longName, data_ancVars, data_comment] = ...
                                            read_varAttribute(data_name, data_units, campaign)
    
    % Preallocate cells
    data_standardName = cell(length(data_name),1);
    data_longName = cell(length(data_name),1);
    data_ancVars = cell(length(data_name),1);
    data_units_list = cell(length(data_name),1); 
    data_comment = cell(length(data_name),1);
    
    % Loop all variables
    for i=1:length(data_name)
        
        % Read attributes as defined in lookup table
        varAttributes = lookup_varAttributesList(data_name{i}); 
        
        % Associate attributes to variables
        data_standardName{i} = varAttributes{2,strcmp(varAttributes(1,:),'standard_name')};
        data_longName{i} = varAttributes{2,strcmp(varAttributes(1,:),'long_name')};
        data_ancVars{i} = varAttributes{2,strcmp(varAttributes(1,:),'ancilliary_variables')};
        data_units_list{i} = varAttributes{2,strcmp(varAttributes(1,:),'units')}; % copy this to check against true units from file later on
        data_comment{i} = varAttributes{2,strcmp(varAttributes(1,:),'comment')};
        % omitted fill values in this list, since this has been extracted 
        % in function read_data
        
        % Check units from uniform data file (data_units) and the supposed 
        % units in samd standard (data_units_list):
        % If the units don't match:
        if ~strcmp(data_units{i},data_units_list{i})
            
            if strcmp(data_name{i}, 'time') && strcmp(data_units{i},'seconds since 2020-01-01 00:00:00 UTC') && ...
                        strcmp(campaign, 'EUREC4A')
                    data_units_list{i} = data_units{i};
            end
            
        end
    end
end

function fileNameString = makeFileName(instrument, flightdate, version, filenameprefix)
                        
    fileNameString = [filenameprefix instrument '_' flightdate '_' version '.nc'];
    
end

function write_data(outfile, information, data_name, data_data, data_fillValue, ...
                    data_missingValue, ncformat, deflatelevel, rollThreshold)
    
    % Read attribute information
    for i=1:length(data_name)
        var(i) = lookup_varAttributesList(data_name{i},'struct');
    end
    
    % Identify dimensions
    indDims = logical([var.is_dimension]);
    
    % Loop variables
    for i=1:length(data_name)
        % Add variable size information to struct
        var(i).size = size(data_data{i});
        varSize{i} = var(i).size;
        if sum(var(i).size==1)==2
            varSize{i} = 1;
        else
            varSize{i} = varSize{i}(varSize{i}~=1);
        end
    end
    
    % Look for sizes and names of dimensions
    dimSize = [varSize{indDims}];
    dimName = {var(indDims).variable_name};
    
    % Get variable sizes and associate dimensions accordingly
    for i=1:length(data_name)
        size_tmp = varSize{i};
        for j=1:length(size_tmp)
            tmp{1,j} = [dimName(size_tmp(j)==dimSize), dimSize(size_tmp(j)==dimSize)];
        end
        dimInfo = [tmp{:}];
        var(i).dimension = dimInfo;
        clear tmp
    end
    
   
    % Loop variables
    for i=1:length(data_name) 
        
        % Print variable name
        disp(data_name{i}) 
        
        % Create variable in NetCDF file; method depending on fact if fill
        % value is defined or not
        if ~isempty(data_fillValue{i})
            nccreate(outfile, var(i).variable_name, 'Dimensions', [var(i).dimension],... 
                    'Datatype', replace_ncFormats(var(i).precision),...
                    'Format', ncformat, 'DeflateLevel',deflatelevel,...
                    'FillValue', data_fillValue{i})
                    
        else
            nccreate(outfile, var(i).variable_name, 'Dimensions', [var(i).dimension],...
                    'Datatype', replace_ncFormats(var(i).precision),...
                    'Format', ncformat, 'DeflateLevel',deflatelevel)
        end
        
        % If variable is time: round and check if it's still ok
        if strcmp(var(i).variable_name,'time')
            data_data{i} = checkAndRoundTime(data_data{i});
        end
        
        % If variable is ldr: change values to dimension dB
        if strcmp(var(i).variable_name, 'ldr')
            % Calculate all values which are greater than -200; typical
            % indicators for error/missing values are smaller than that
            data_data{i}(data_data{i}>-200)=10.*log10(data_data{i}(data_data{i}>-200)); 
        end        
        
        % Write data
        ncwrite(outfile, var(i).variable_name, data_data{i})
        
        %%% Write attributes %%%
        % standard_name
        if ~isempty(var(i).standard_name)
            ncwriteatt(outfile, var(i).variable_name,'standard_name',var(i).standard_name)
        end
        % long_name
        if ~isempty(var(i).long_name)
            ncwriteatt(outfile, var(i).variable_name,'long_name',var(i).long_name)
        end
        % missing_value
        if ~isempty(data_missingValue{i})
            ncwriteatt(outfile, var(i).variable_name,'missing_value',data_missingValue{i})
        end
        % comments
        if ~isempty(var(i).comment)
            ncwriteatt(outfile, var(i).variable_name,'comments',var(i).comment)
        end
        
        % Units
        ncwriteatt(outfile, var(i).variable_name,'units',var(i).units)
        
        % Ancilliary_variables
        if ~isempty(var(i).ancilliary_variables)
            ncwriteatt(outfile, var(i).variable_name,'ancillary_variables',var(i).ancilliary_variables)
        end
        % Bounds
        if ~isempty(var(i).bounds)
            ncwriteatt(outfile, var(i).variable_name,'bounds',var(i).bounds)
        end
        
        % If current variable is radar_flag
        if strcmp(var(i).variable_name,'radar_flag')
            % Write flag_values attribute
            ncwriteatt(outfile, var(i).variable_name,'flag_values', int16([0,1,2,3,4,5])) % add flag_values, convert these to short (int16)
            % Write flag_values attribute
            ncwriteatt(outfile, var(i).variable_name,'flag_meanings', 'data_ok noise surface_and_sub-surface sea_surface radar_calibration_maneuvers side_lobes_removed') %add flag_meanings
        end
        
       
        
        
        % If current variable is turn_flag
        if strcmp(var(i).variable_name,'turn_flag')
            % Write flag_values attribute
            ncwriteatt(outfile, var(i).variable_name,'flag_values', [0,1])
            
            rollflag{1} = ['roll_angle_less_than_' num2str(rollThreshold) '_deg'];
            rollflag{2} = ['roll_angle_more_than_' num2str(rollThreshold) '_deg'];
            % Write flag_values attribute
            ncwriteatt(outfile, var(i).variable_name,'flag_meanings', [rollflag{1} ' ' rollflag{2}])
        end
        
        % If current variable is dimension, add boundaries for time and
        % height
%         if var(i).is_dimension
%             % If dimension is time
%             if strcmp(var(i).variable_name,'time')
%                 % Create time bounds variable
% %                 var_bnds = [data_data{i}(1:end-1) data_data{i}(2:end)]; 
%             end
%             % If dimension is height
%             if strcmp(var(i).variable_name,'height')
%                 % Calculate vertical resolution
%                 vres = unique(diff(data_data{i}));
%                 if length(vres)>2
%                     error('Problem vertical resolution not constant!')
%                 end
%                 % height array indentifies center of range gate. -> lower
%                 % and upper bound are value +/- half of resolution
%                 lb = data_data{i}(1:end)-vres./2;
%                 ub = data_data{i}(1:end)+vres./2;
%                 
%                 % Replace value below ground to ground
%                 lb(lb<0) = 0;
%                 % Create time bounds variable
% %                 var_bnds = [lb ub];
%             end
%             
%             % Create variable
% %             if ~(strcmp(data_name{i},'freq_sb'))
% %                 nccreate(outfile, [var(i).variable_name '_bnds'], 'Dimensions', [{'nv', 2}, var(i).dimension],... %{'nv', 2} als zweiter Stelle in []
% %                     'Datatype', replace_ncFormats(var(i).precision),...
% %                     'Format', ncformat, 'DeflateLevel',deflatelevel)
% %             end
%             %nccreate(outfile, [var(i).variable_name '_bnds'], 'Dimensions', [{'nv', 2}, var(i).dimension],... %{'nv', 2} als zweiter Stelle in []
%             %        'Datatype', replace_ncFormats(var(i).precision),...
%             %        'Format', ncformat, 'DeflateLevel',deflatelevel)
%                 
%             % Write data
%             
%             
%         end
    end
    
    % Global attributes
    ncwriteatt(outfile,'/','Title',information.Title) 
    ncwriteatt(outfile,'/','Institution',information.Institute)
    ncwriteatt(outfile,'/','Contact_person',information.Contact_person)
    ncwriteatt(outfile,'/','Source',information.Source)
    ncwriteatt(outfile,'/','Conventions',information.Conventions)
    ncwriteatt(outfile,'/','Processing_date',getProcessingDate)
    ncwriteatt(outfile,'/','Author',information.Author)
    ncwriteatt(outfile,'/','Comments',information.Comment)
    ncwriteatt(outfile,'/','Licence',information.Licence)
%     ncwriteatt(outfile,'/','Dependencies',information.Dependencies)
end

function formatOUT = replace_ncFormats(formatIN)
    
    switch formatIN
        case 'double'
            formatOUT = 'double';
        case 'float'
            formatOUT = 'single';
        case 'int64'
            formatOUT = 'int64';
        case 'short'
            formatOUT = 'int16';
        case 'byte'
            formatOUT = 'int8';
        otherwise
            formatOUT = formatIN;
    end
end

function processingDate = getProcessingDate %Date 
    processingDate = datestr(datetime(now, 'ConvertFrom', 'datenum'));
end

function timeRounded = checkAndRoundTime(time) 
%Time rounded
    timeRounded = round(time);
    
    if numel(time)~=numel(unique(timeRounded))
        error('rounded time is funny')
    end
end

function [data_name, turn_ind, data_units, data_fillValue, data_missingValue] = makeRollFlag(flightdate, version, rollThreshold)

    % Read roll angle from bahamas
    [~, roll, ~, ~, ~] = ...
        read_data('bahamas', flightdate, version, {'bahamas',{''},{'roll'}});
    
    roll = roll{1};
    turn_ind = zeros(size(roll));
    turn_ind(abs(roll)>rollThreshold) = 1;
    
    data_name = {'turn_flag'};
    data_units = {};
    data_fillValue = {};
    data_missingValue = {};
end
