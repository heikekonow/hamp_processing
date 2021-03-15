function run_unifyGrid(version, subversion, flightdates_use, comment, contact, altitudeThreshold, ...
                        rollThreshold, radarmask,  radarClutter, correctRadiometerTime, ...
                        missingvalue, fillvalue, filenameprefix)

tic 
%% Switches 
% usually all set to 1, but can be useful for debugging
%
% Unify data onto common grid
unify = 1;
% Save data to netcdf
savedata = 1;
% Redo unified bahamas data, otherwise only load
redoBahamas = 1;

% Load information on flight dates and campaigns
[NARVALdates, NARVALdatenum] = flightDates;

t1 = flightdates_use{1};

% Set path to base folder
pathtofolder = [getPathPrefix getCampaignFolder(t1)];


%% Specify variables to consider

% Bahamas
bahamasVars = {'MIXRATIO','PS','RELHUM','THETA','U','V','W','IRS_ALT'...
                'IRS_HDG','IRS_THE','IRS_PHI','IRS_LAT','IRS_LON','TS',...
                'IRS_GS','IRS_VV'};

% Radiometer
radiometerVars = {'183','11990','KV'};

% Radar
radarVars = {'dBZg','Zg','LDRg','RMSg','VELg','SNRg'};

% Dropsondes
sondeVars = {'pres','tdry','dp','rh','u_wind','v_wind','wspd','wdir','dz',...
             'mr','vt','theta','theta_e','theta_v','lat','lon'};


%% Data processing

if unify
    % Loop all dates
    for i=1:length(flightdates_use)


        % Return date
        disp(flightdates_use{i})

        % Unify data on one common grid    
        % Bahamas
        if redoBahamas
            [uniTime,uniHeight] = unifyGrid_bahamas(pathtofolder, flightdates_use{i}, ...
                                                    bahamasVars, fillvalue);
        else
            filepath = listFiles([pathtofolder 'all_mat/*bahamas' flightdates_use{i} '*'],'full');
            load(filepath{end},'uniTime','uniHeight')
        end

        % Create empty variable according to unified grid
        uniData = ones(length(uniHeight),length(uniTime)) .* fillvalue;

        % Round time to seconds to avoid numerical deviations 
        uniTime = dateround(uniTime', 'second');
        
        % Dropsondes
        unifyGrid_dropsondes(pathtofolder, flightdates_use{i}, uniHeight, uniTime, ...
                             uniData, sondeVars, fillvalue)

        % Radiometer
        unifyGrid_radiometer(pathtofolder,flightdates_use{i},uniTime,radiometerVars,...
            altitudeThreshold, rollThreshold, missingvalue, fillvalue, correctRadiometerTime)
        
        % Radar
        unifyGrid_radar(pathtofolder,flightdates_use{i},uniHeight,uniTime,radarVars)
        
    end
end
%% Prepare infos for global attribute

% % % Get infos about data versions
% % versionInfo = getVersionInfo_eurec4a(version,subversion,'all');
% % vAttr = cell(length(versionInfo),1);
% % for k=1:length(versionInfo)
% %     vAttr{k} = {['Version ' versionInfo{k}(1:4)],versionInfo{k}(7:end)};
% % end

% Write attribute with contact information
contactAttr = {{'contact', contact}};

commentAttr = {{'comment', comment}};

%% Export to netcdf

instr = {'radiometer','radar','bahamas','dropsondes'};
% instr = {'bahamas','radar','radiometer'};
% instr = {'radar'};
% instr = {'bahamas'};
% instr = {'lidar'};
% instr = {'radiometer'};
% instr = {'dropsondes'};

if savedata
    % Loop all dates
    for i=1:length(flightdates_use)
        
        disp(['Processing flight on: ' flightdates_use{i}])

        for j=1:length(instr)
            
            disp(['Processing data from: ' instr{j}])
            
             % Define in- and outfile
            outfile = [pathtofolder 'all_nc/' filenameprefix instr{j} '_' flightdates_use{i} ...
                        '_v' num2str(version) '.' num2str(subversion) '.nc'];
            infile = [pathtofolder 'all_mat/uniData_' instr{j} flightdates_use{i} '.mat'];
            
            if exist(infile,'file')

                [ncVarNames,ncDims,varData,varInfo] = prepareMat2NetCDF(infile);


                % If instrument is not bahamas, add geo informations to
                % dataset
                if ~strcmp(instr{j}, 'bahamas')

                    infileBahamas = [pathtofolder 'all_mat/uniData_bahamas' flightdates_use{i} '.mat'];

                    [ncVarNamesBahamas,ncDimsBahamas,varDataBahamas,varInfoBahamas] = prepareMat2NetCDF(infileBahamas);


                    % Get indices of Bahamas variables for lat, lon, alt
                    bahamasVarNamesAdd = {'uniBahamaslat_1d', 'uniBahamaslon_1d', 'uniBahamasalt_1d'};
                    indBahamasGeo = cell2mat(cellfun(@(x) find(strcmp(ncVarNamesBahamas, x)), ...
                                                bahamasVarNamesAdd, 'uni', 0));
                    indBahamasGeoInfo = cell2mat(cellfun(@(x) find(strcmp(varInfoBahamas(:,4), x)), ...
                                                bahamasVarNamesAdd, 'uni', 0));

                    if strcmp(instr{j}, 'dropsondes')
%                             ncVarNames{strcmp(ncVarNames, 'uniBahamaslat_1d')} = 'ac_lat';
%                             ncVarNames{strcmp(ncVarNames, 'uniBahamaslon_1d')} = 'ac_lon';
                        ind = find(strcmp(varInfoBahamas, 'lat'));
                        for k=1:length(ind)
                            varInfoBahamas{ind(k)} = 'ac_lat';
                        end
                        ind = find(strcmp(varInfoBahamas, 'lon'));
                        for k=1:length(ind)
                            varInfoBahamas{ind(k)} = 'ac_lon';
                        end

                        varInfoBahamas{indBahamasGeoInfo(1),4} = 'ac_lat';
                        varInfoBahamas{indBahamasGeoInfo(2),4} = 'ac_lon';
                        ncVarNamesBahamas{indBahamasGeo(1),1} = 'ac_lat';
                        ncVarNamesBahamas{indBahamasGeo(2),1} = 'ac_lon';
                    end

                    % Append Bahamas geo data to instrument data
                    ncVarNames = [ncVarNames; ncVarNamesBahamas(indBahamasGeo)];
                    ncDims = [ncDims; ncDimsBahamas(indBahamasGeo)];
                    varData = [varData, varDataBahamas(indBahamasGeo)];
                    varInfo = [varInfo; varInfoBahamas(indBahamasGeoInfo,:)];


                end
                

                %% Add radar quality mask
                if radarmask && strcmp(instr{j}, 'radar')
                    % Look for file with radar mask
                    maskfile = listFiles(...
                        [getPathPrefix getCampaignFolder(flightdates_use{i}) 'aux/radarMask_' ...
                         getCampaignName(flightdates_use{i}) '.mat'],...
                        'full', 'mat');

                    if isempty(maskfile)
                        error('No radar mask file found. Make sure that file exists and check path')
                    else
                        [ncVarNames, ncDims, varData, varInfo] = ...
                            addMaskToOutput(maskfile, flightdates_use{i}, ncVarNames, ncDims, varData, varInfo);
                    end
                end
                %%

                % Get flight infos
                flightdateDN = datenum(flightdates_use{i},'yyyymmdd');
                indFlightInfo = NARVALdatenum==flightdateDN;
                flightNumber = NARVALdates{indFlightInfo,2};
                flightMission = NARVALdates{indFlightInfo,3};

                % Write flight attribute infos
                flightAttr = {{'mission',flightMission};{'flight_number',flightNumber}};

                % Concatenate global attribute infos into one variable
                globAtt = [contactAttr; flightAttr; commentAttr];
%                 globAtt = [vAttr; contactAttr; flightAttr; commentAttr];

                varInfo = replaceVarName(varInfo,instr{j});
                ncDims = replaceVarName(ncDims,instr{j});
                ncVarNames = replaceVarName(ncVarNames,instr{j});

                writeNetCDF(outfile,ncVarNames,ncDims,varData,varInfo,globAtt, mfilename, fillvalue)

                %% Add coorinates to variables to create georeferenced data
                addGeoRef(outfile)
                
                %% Add fill value/missing value information
                addFillMissing(outfile, missingvalue)
                
                %% Remove side lobes during turns
                if strcmp(instr{j}, 'radar')
                    removeSideLobes(outfile, rollThreshold, fillvalue, radarmask)
                end
                
                %% Remove clutter from radar data

                if radarClutter && strcmp(instr{j}, 'radar')
                    removeClutter(outfile, missingvalue, fillvalue)
                end 
                
                %% Add comment about radiometer time correction
                if correctRadiometerTime && strcmp(instr{j}, 'radiometer')
                    addRadiometerTimeComment(outfile, infile)
                end
                
            else
                disp(['No ' instr{j} ' data found'])
            end
        end
    end

    % Change access rights
%     eval(['! chmod go+rx ' getPathString(outfile) '*' num2str(version) '.' num2str(subversion) '.nc'])
end
toc
end

%% Functions
function list = replaceVarName(list,instrument)

    % Replace variable names:
    % Load nametable
    [lookuptable,instrOrder] = varnames_lookup;
    % Find instrument column in lookup table
    ind_instr = strcmp(instrOrder,instrument);
    
    % Loop all list elements to replace if necessary
    for i=1:numel(list)
        % Output for troubleshooting
%         disp(list{i})
        
        % If list is a cell
        if iscell(list{i})
            
            % Look for character arrays in list
            ind_char = find(cellfun(@ischar,list{i}));
            
            % Loop all elements
            for j=1:length(ind_char)
                % Replace list elements with names from lookup table
                list{i}(ind_char(j)) = ...
                    lookuptable(strcmp(list{i}(ind_char(j)),lookuptable(:,1)) , ind_instr);
            end
            
        % Else, if the element is a string and the string is found in the
        % lookup table
        elseif ischar(list{i}) && sum(strcmp(list{i},lookuptable(:,1)))~=0
            
            % Look for new name in lookup table
            newName = lookuptable(strcmp(list{i},lookuptable(:,1)) , ind_instr);
            
            % Check if name has been found in list for instrument, if not,
            % look in Bahamas list
            if isempty(newName{1})
                % Copy variable
                ind_instrBACK = ind_instr;
                % Look for index of bahamas in lookup table
                ind_instr = strcmp(instrOrder,'bahamas');
                
                % Find new variable name
                newName = lookuptable(strcmp(list{i},lookuptable(:,1)) , ind_instr);
                
                % Copy instrument index back
                ind_instr = ind_instrBACK;
            end
            
            % Replace variable name
            list(i) = newName;
            
        end
    end
end

function addGeoRef(outfile)
    % Write global attribute
    ncwriteatt(outfile, '/', 'featureType', 'trajectoryProfile');
    
    % Load lookup table for coordinates
    table = lookup_coordinates;
    
    % List variable names in file
    varnames = nclistvars(outfile);
    
    for i=1:length(varnames)
        indVar = strcmp(varnames{i}, table(:,1));
        
%         if sum(indVar)==0
%             error(['Variable ' varnames{i} ' not found'])
%         end
        
%         disp(varnames{i})
        
        if sum(indVar)~=0 && ~strcmp(table{indVar, 2}, '')
            ncwriteatt(outfile, varnames{i}, 'coordinates', table{indVar, 2});
        end
    end
end

function removeClutter(outfile, missingvalue, fillvalue)
    % Get variable dimension sizes and names from file
    [varnames, ~, ~, vardims] = nclistvars(outfile);
    
    % Get number of non singleton dimensions for each variable
    dimNums = sum(cellfun(@(x) numel([x]), vardims), 2);
    % Look for variables that are matrices
    indMat = find(dimNums==2);
    
    for i=1:length(indMat)
        
        % Read variable data
        var = ncread(outfile, varnames{indMat(i)});
        
        % Preserve fill values
        mask = false(size(var));
        if isnan(fillvalue)
            mask(isnan(var)) = true;
        else
            mask(var==fillvalue) = true;
        end
        
        % Remove clutter from data
        var = removeRadarClutter(var, missingvalue, fillvalue);
        
        % Reintroduce fill value pixels
        var(mask) = fillvalue;
        
        % Write to nc file again
        ncwrite(outfile, varnames{indMat(i)}, var)
    end
end

function addFillMissing(outfile, missingvalue)
    
    % Get variable dimension sizes and names from file
    [varnames, ~, ~, vardims] = nclistvars(outfile);
    [dimnames] = nclistdims(outfile);
    
    % Get number of non singleton dimensions for each variable
    dimNums = sum(cellfun(@(x) numel([x]), vardims), 2);
%     % Loook for variables that are matrices
%     indMat = find(dimNums==2);
    
    for i=1:length(varnames)
        if ~any(strcmp(varnames{i}, dimnames)) && dimNums(i)~=0
        
            % Add attributes to variables
            ncwriteatt(outfile, varnames{i}, 'missing_value', missingvalue)
%             ncwriteatt(outfile, varnames{i}, 'FillValue', fillvalue)
        end
    end
end

function removeSideLobes(outfile, rollThreshold, fillvalue, radarmask)
    
    % Get variable dimension sizes and names from file
    [varnames, ~, ~, vardims] = nclistvars(outfile);
    
    % Read flight date from file
    flightdate = num2str(ncread(outfile, 'date'));
    
    % Read array with height of radar range gates
    h = ncread(outfile, 'height');
    
    % Read roll, pitch, altitude from Bahamas
    roll = readdata(flightdate, 'roll');
    pitch = readdata(flightdate, 'pitch');
    alt = readdata(flightdate, 'altitude');
    
    % Generate matrix that indicates turns based on roll threshold
    rollIndMat = abs(roll)>rollThreshold;
    rollIndMat = repmat(rollIndMat', size(h, 1), 1);
    
    % Calculate height affected by side lobes during turns
    hSidelobe = alt .* (1 ./ cosd(roll) ./ cosd(pitch) - 1) + 60;
    
    % Convert side lobe height to matrix
    hSidelobeMat = repmat(hSidelobe', size(h, 1), 1);
    
    % Convert height array to matrix
    heightMat = repmat(h, 1, size(hSidelobeMat,2));
    
    % Mask derived from geometry
    geoMask = heightMat<hSidelobeMat;
    
    % Mask for side lobe effects
    sideLobeMask = geoMask & rollIndMat;
    
    % Get number of non singleton dimensions for each variable
    dimNums = sum(cellfun(@(x) numel([x]), vardims), 2);
    
    % Look for variables that are matrices
    indMat = find(dimNums==2);
    
    % Loop all 2d variables
    for i=1:length(indMat)
            
            % Read variable data
            var = ncread(outfile, varnames{indMat(i)});
            
            % Replace side lobes in data with fill value
            varMasked = var;
            varMasked(sideLobeMask) = fillvalue;
            
            % Write to nc file again
            ncwrite(outfile, varnames{indMat(i)}, varMasked)
            
    end
    
    % Add information to radar data mask
    if radarmask
        
        % Read radar data flag
        flag = ncread(outfile, 'data_flag');
        
        % Add side lobes to flag
        flag(sideLobeMask) = 5;
        
        % Write to nc file again
        ncwrite(outfile, 'data_flag', flag)
        
        % Read flag's long name attribute
        longNameAtt = ncreadatt(outfile, 'data_flag', 'long_name');
        % Add entry for side lobes
        longNameAtt = [longNameAtt '; 5: side lobes removed'];
        
        ncwriteatt(outfile, 'data_flag', 'long_name', longNameAtt)
    end
end

function addRadiometerTimeComment(outfile, infile)
    string = load(infile, 'corrCommentString');
    
    ncwriteatt(outfile, 'tb', 'comment', string.corrCommentString)
end
