function run_unifyGrid(flightdates_use)

tic 
%% Switches
% Unify data onto common grid
unify = 1;
% Save data to netcdf
savedata = 1;
% Redo unified bahamas data, otherwise only load
redoBahamas = 1;

%% Set version information
version = 0;
subversion = 4;

% %% Specify time frame for data conversion
% % Start date
% t1 = '20190516';  
% % End date
% t2 = '20190517';
% 
% % Get flight dates to use in this program
% flightdates_use = specifyDatesToUse(t1,t2);

% Load information on flight dates and campaigns
[NARVALdates, NARVALdatenum] = flightDates;

t1 = flightdates_use{1};

% Set path to root folder
if str2num(t1)<20160101
    pathtofolder = [getPathPrefix 'NARVAL-I_campaignData/'];
elseif str2num(t1)<20190101
    pathtofolder = [getPathPrefix 'NANA_campaignData/'];
else
    pathtofolder = [getPathPrefix 'EUREC4A_campaignData/'];
end

% %% Check if output folders exist, otherwise create
% 
% checkandcreate(pathtofolder, 'all_mat')
% checkandcreate(pathtofolder, 'all_nc')
% checkandcreate(pathtofolder, 'radar_mira')

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
            [uniTime,uniHeight] = unifyGrid_bahamas(pathtofolder,flightdates_use{i},bahamasVars);
        else
            filepath = listFiles([pathtofolder 'all_mat/*bahamas' flightdates_use{i} '*'],'full');
            load(filepath{end},'uniTime','uniHeight')
        end

        % Radiometer
        unifyGrid_radiometer(pathtofolder,flightdates_use{i},uniTime,radiometerVars)

        % Create empty variable according to unified grid
        uniData = nan(length(uniHeight),length(uniTime));
% 
        % Radar
        unifyGrid_radar(pathtofolder,flightdates_use{i},uniHeight,uniTime,radarVars)
% 
        % Dropsondes
        unifyGrid_dropsondes(pathtofolder,flightdates_use{i},uniHeight,uniTime,uniData,sondeVars)
% 
%         % Lidar
%         unifyGrid_lidar(pathtofolder,flightdates_use{i},uniHeight,uniTime,uniData,lidarVars)
    end
end
%% Prepare infos for global attribute

% Get infos about data versions
versionInfo = getVersionInfo_eurec4a(version,subversion,'all');
vAttr = cell(length(versionInfo),1);
for k=1:length(versionInfo)
    vAttr{k} = {['Version ' versionInfo{k}(1:4)],versionInfo{k}(7:end)};
end

% Write attribute with contact information
contactAttr = {{'contact','heike.konow@uni-hamburg.de'}};

%% Export to netcdf

instr = {'bahamas','radar','radiometer','dropsondes'};
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
            outfile = [pathtofolder 'all_nc/' instr{j} '_' flightdates_use{i} ...
                        '_v' num2str(version) '.' num2str(subversion) '.nc'];
            infile = [pathtofolder 'all_mat/uniData_' instr{j} flightdates_use{i} '.mat'];
            
%             if ~(version==2 && subversion==1 && strcmp(instr{j},'radar'))
            
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

                    % Get flight infos
                    flightdateDN = datenum(flightdates_use{i},'yyyymmdd');
                    indFlightInfo = NARVALdatenum==flightdateDN;
                    flightNumber = NARVALdates{indFlightInfo,2};
                    flightMission = NARVALdates{indFlightInfo,3};

                    % Write flight attribute infos
                    flightAttr = {{'mission',flightMission};{'flight_number',flightNumber}};

                    % Concatenate global attribute infos into one variable
                    globAtt = [vAttr;contactAttr;flightAttr];

                    varInfo = replaceVarName(varInfo,instr{j});
                    ncDims = replaceVarName(ncDims,instr{j});
                    ncVarNames = replaceVarName(ncVarNames,instr{j});

                    writeNetCDF(outfile,ncVarNames,ncDims,varData,varInfo,globAtt, mfilename)
                    
%                     clear ncVarNames ncDims varData varInfo ncVarNamesBahamas ncDimsBahamas varDataBahamas varInfoBahamas
                    
                    % Add coorinates to variables to create georeferenced data
                    addGeoRef(outfile)
                else
                    disp(['No ' instr{j} ' data found'])
                end
%             else
%                 % If version is v2.1, reprocess radar data
%                 processRadarv2(flightdates_use{i})
%             end
        end
    end

    % Change access rights
    eval(['! chmod go+rx ' getPathString(outfile) '*' num2str(version) '.' num2str(subversion) '.nc'])
end
toc
end

%% Functions
function list = replaceVarName(list,instrument)

    % Replace variable names:
    % Load nametable
    [lookuptable,instrOrder] = varnames_lookup;
    ind_instr = strcmp(instrOrder,instrument);
    for i=1:numel(list)
%         disp(list{i})
        if iscell(list{i})
            ind_char = find(cellfun(@ischar,list{i}));
            for j=1:length(ind_char)
                list{i}(ind_char(j)) = ...
                    lookuptable(strcmp(list{i}(ind_char(j)),lookuptable(:,1)) , ind_instr);
            end
        elseif ischar(list{i}) && sum(strcmp(list{i},lookuptable(:,1)))~=0
            
            % Look for new name in lookup table
            newName = lookuptable(strcmp(list{i},lookuptable(:,1)) , ind_instr);
            
            % Check if name has been found in list for instrument, if not,
            % look in Bahamas list
            if isempty(newName{1})
                ind_instr = strcmp(instrOrder,'bahamas');
                
                newName = lookuptable(strcmp(list{i},lookuptable(:,1)) , ind_instr);
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
        
        disp(varnames{i})
        
        if sum(indVar)~=0 && ~strcmp(table{indVar, 2}, '')
            ncwriteatt(outfile, varnames{i}, 'coordinates', table{indVar, 2});
        end
    end
end


