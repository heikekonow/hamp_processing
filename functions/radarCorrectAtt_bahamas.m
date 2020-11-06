%% HaloRadarBahamasCombCorrectTimeAngles
%   HaloRadarBahamasCombCorrectTimeAngles - Combines data from Mira radar and Bahamas 
%                          into one file and corrects for time offset of
%                          radar and flight attitude
%           - Loads Bahamas and Mira data files
%           - Loads time offset data from lookup table and corrects for
%             those
%           - Variables that should converted are defined in the Variable
%             Selection Section below
%           - Common time steps from both systems are selected and only
%             data at those times is considered further
%           - Data measured during turns of the aircraft (roll angle > 3
%             deg) is flagged
%           - Radar data that is in a range bin farther from the aircraft
%             than the ground is omitted
%           - Radar data matrix is flipped to reflect the downward-looking
%             of the instrument
%           - Radar data is regridded and corrected for flight attitude
%           - All data is written to NetCDF
%           - dBZ are calculated
%
%   Syntax:  HaloRadarBahamasCombCorrectTime(RadarFile,versionNumber,netCDFPath)
%
%   Inputs:
%       RadarFile -     path to radar data file
%       versionNumber - version number of radar data
%       netCDFPath -    path to generated NetCDF file of converted data
%
%   Outputs:
%       no output variables
%
%   Example: 
%       see script: runRadarBahamasComb
%
%   Other m-files required: copyNetCDFVariable, copyNetCDFglobalAtt,
%                           dateround, listFiles, sdn2unixtime,
%                           unixtime2sdn, timeOffsetLookup, regriddFlightAngles
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: HaloRadarBahamasComb,
%             HaloRadarBahamasCombCorrectTime, runRadarBahamasComb
%
%   % 20160615: added additionaly input argument: varargin, set to be 'nolobes'
%                   to prevent removal to side lobes (use this to see if
%                   derivation of surface mask is easier now)
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   January 2014; Last revision: June 2015

%%

function radarCorrectAtt_bahamas(RadarFile,versionNumber,netCDFPath, missingvalue, varargin)

%------------- BEGIN CODE --------------

%BahamasPath = '/data/share/u231/u231107/HAMP/bahamas_all/';
% BahamasPath = '/data/share/narval/work/heike/NANA_campaignData/bahamas/';
% BahamasPath = '/Users/heike/Work/NANA_campaignData/bahamas/';

% BahamasPath = [getPathPrefix 'NANA_campaignData/bahamas/'];

ind_folder_string = regexp(RadarFile,'/radar/');
campaignPath = RadarFile(1:ind_folder_string);
BahamasPath = [campaignPath 'bahamas/'];


% Version Number is assigened during function call, subversion number is
% defined as '2' for this type of operation (exception: if side lobes
% should not be removed, subversion is 3)
% if nargin>3 && strcmp(varargin{1},'nolobes')
%     subversionNumber = '3';
% else
    subversionNumber = '2';
% end

%% Load Bahamas

% Check if radar data file is assigned during function call, otherwise use
% predefined files
if ~exist('RadarFile','var')
    RadarFile = ...
    '/data/share/u231/u231107/HAMP/NARVAL-North/flight09_20140107_EDMO-BIKF/mira36/20140107_all_g40.mmclx';
    netCDFPath = '/data/share/u231/u231107/HAMP/NARVAL-North/mira-allNetCDF/';
end

% Extract time information
tRadar = double(ncread(RadarFile,'time'));
tRadar = unixtime2sdn(tRadar);

% Date as string
date = datestr(tRadar(1),'yyyymmdd');

% Search for corresponding bahamas data file
BahamasFile = listFiles([BahamasPath '*' datestr(tRadar(1),'yyyymmdd') '*.nc']);
BahamasFile = [BahamasPath BahamasFile{1}];

%% Correct Time Offset

% Get offset for specific day
timeOffset = timeOffsetLookup(date);

% Adjust time by adding offset
tRadar = tRadar + 1/24/60/60 * timeOffset;


%% Outfile Definition
outfile = [netCDFPath 'mira' datestr(tRadar(1),'yyyymmdd') '_' datestr(tRadar(1),'HHMM') ...
            '_g40_v' versionNumber '.' subversionNumber '.nc'];

% delete if outfile already exists
if exist(outfile,'file')
    delete(outfile)
end

%% Variable Selection
% one dimensional data to copy
varCopy = {'nfft','prf','NyquistVelocity','nave','zrg','rg0','drg','lambda',...
           'tpow','npw1','npw2','cpw1','cpw2','grst'};

% varEdit = {'SNRg','VELg','RMSg','LDRg','NN1','NF1','NN2','NF2','HSDco','HSDcx','Zg'};

varEdit = {'SNRg','VELg','RMSg','LDRg','HSDco','HSDcx','Zg'};

% varBahamas = {'P','RH','abshum','mixratio','speed_air','T','Td','theta',...
%               'theta_v','Tv','U','V','W','lat','lon','pitch','heading',...
%               'roll','Ts','alpha','beta','h','palt','mc','qc','wa','ws',...
%               't_sys','galt','nsv','ewv','vv','p','q',...
%               'r','axb','ayb','azb','azg','ata','speed_gnd'};
varBahamas = {'PS','RELHUM','ABSHUM','MIXRATIO','TAS','TAT','TD','THETA',...
              'THETA_V','TV','U','V','W','IRS_LAT','IRS_LON','IRS_THE','IRS_HDG',...
              'IRS_PHI','TS','ALPHA','BETA','H','HP','MC','QC','WA','WS',...
              'IRS_ALT'};
       
%% BAHAMAS essentials

% List Bahamas variables in file
varsInBahamasFile = nclistvars(BahamasFile);

% time
timeNameUse = replaceBahamasVarName('TIME',varsInBahamasFile);
tBahamas = ncread(BahamasFile,timeNameUse{1});
tBahamas = unixtime2sdn(tBahamas);
% location
heightNameUse = replaceBahamasVarName('IRS_ALT',varsInBahamasFile);
hGPS = ncread(BahamasFile,heightNameUse{1});
% flight data
varNameUse = replaceBahamasVarName('IRS_PHI',varsInBahamasFile);
rollAngle = ncread(BahamasFile,varNameUse{1});
% pitchAngle = ncread(BahamasFile,'pitch');
varNameUse = replaceBahamasVarName('IRS_THE',varsInBahamasFile);
pitchAngle = ncread(BahamasFile,varNameUse{1});

% Replace variable names
varNameUse = cellfun(@(x,y) replaceBahamasVarName(x,varsInBahamasFile),varBahamas,'UniformOutput',false);
varBahamas = [varNameUse{:}];

% Get maximum altitude 
alt_max = max(hGPS);

%% Adjust time series
disp('Adjust time series')
fprintf('%s\n','')
% round times to avoid numerical deviations
tBahamas = dateround(tBahamas,'second');
tRadar = dateround(tRadar,'second');
% find common entries
[tBoth,indBahamas,indRadar] = intersect(tBahamas,tRadar);
if isempty(tBoth)
    error('Bahamas and mira don''t match. Did you select the correct files?')
end

%% Edit Data
disp('Edit Data')
fprintf('%s\n','')
% Read essentials
range = double(ncread(RadarFile,'range'));

% Read data to cell
dataRadar = cell(1,length(varEdit));
for i=1:length(varEdit)
    dataRadar{i} = ncread(RadarFile,varEdit{i});
    
end
% dataRadar = cellfun(@(x) ncread(RadarFile,x),varEdit,'UniformOutput',false);


% Copy Z for later dBZ calculation
Zcopy = dataRadar{strcmp(varEdit,'Zg')};
Zcopy(isnan(dataRadar{strcmp(varEdit,'Zg')})) = -Inf;

% If data matrix is filled with nans, replace with -Inf (set missing value)
dataRadar{strcmp(varEdit,'Zg')}(isnan(dataRadar{strcmp(varEdit,'Zg')})) = -Inf;

for i=1:length(varEdit)
    dataRadar{i}(isnan(dataRadar{i})) = -Inf;
end

% ncdisp(outfile)
% Adjust to common time steps
dataRadarTimeAdjusted = cellfun(@(x) x(:,indRadar),dataRadar,'UniformOutput',false);
hGPS = hGPS(indBahamas);
rollAngle = rollAngle(indBahamas);
pitchAngle = pitchAngle(indBahamas);

%% Modify Bahamas Data
% Read data from NetCDF
dataBahamas = cellfun(@(x) ncread(BahamasFile,x),varBahamas,'UniformOutput',false);
% Transpose to fit to radar data dimensions
dataBahamas = cellfun(@transpose,dataBahamas,'UniformOutput',false);

% Adjust to common time steps
dataBahamasTimeAdjusted = cellfun(@(x) x(:,indBahamas),dataBahamas,'UniformOutput',false);

%% Correct Flight Attitude
disp('Correct Attitude')
fprintf('%s\n','')

% Look for roll angles larger than 3 deg, i.e. turning
% Create flag value for turning
% turnInd = (rollAngle>3|rollAngle<-3);
turnInd = (abs(rollAngle)>5);

% % define vertical grid for variables
% % zGrid = 0:30:14000;


% Round up to next 100 m
alt_max = ceil(alt_max/100)*100;
% Define vertical grid for variables
if alt_max<=14000 % keep this for compatibility between flights
    zGrid = 0:30:14000;
else % if aircraft ceiling was higher, extend vertical coordinate
    zGrid = 0:30:alt_max+30;
end


if nargin>3 && strcmp(varargin{1},'nolobes')
    dataRadarSideLobes = dataRadarTimeAdjusted;
else
    % Remove data from side lobes during turns
    dataRadarSideLobes = cellfun(@(x) removeSideLobes(turnInd,dataRadarTimeAdjusted{strcmp(varEdit,'LDRg')},x),...
                             dataRadarTimeAdjusted,'UniformOutput',false);
end

% Regrid radar data to acount for flight attitudes
dataRadarCorr = cellfun(@(x) regriddFlightAngles(range,rollAngle,pitchAngle,hGPS,zGrid,x),...
                    dataRadarSideLobes,'UniformOutput',false);
                
% Cooz Zg variable for later use in dBZ calculation
Zg = dataRadarCorr{strcmp(varEdit,'Zg')};

%% Convert Time

time = tBoth;
% Convert sdn to unix time
tUnixSec = round(sdn2unixtime(time));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize netCDF file

bahamasInfo = ncinfo(BahamasFile);

%% Write dimensions, time and range
disp('Write Data')
fprintf('%s\n','')

% Copy time scheme
schemaCopy = ncinfo(RadarFile,'time');
% Delete size information
schemaCopy.Size = [];
% Set format to 'netcdf4_classic', compatible with bahamas data
schemaCopy.Format = bahamasInfo.Format;
% Adjust name
schemaCopy.Attributes(strcmp({schemaCopy.Attributes.Name},'long_name')).Value = 'Seconds since 01.01.1970 00:00 UTC';
% Adjust variable type
schemaCopy.Datatype = class(tUnixSec);
% Write schema to new file
ncwriteschema(outfile,schemaCopy);
% Write data to outfile
ncwrite(outfile,'time',tUnixSec)

verticalCoordinate = zGrid;

% Copy range scheme
schemaCopy = ncinfo(RadarFile,'range');
% Delete size information
schemaCopy.Size = [];
% Set format to 'netcdf4_classic', compatible with bahamas data
schemaCopy.Format = bahamasInfo.Format;
% Adjust name
schemaCopy.Attributes(strcmp({schemaCopy.Attributes.Name},'long_name')).Value = 'Height above MSL';
% Adjust variable type
schemaCopy.Datatype = class(range);
% Rename Variable to height
schemaCopy.Name = 'height';
% Rename height dimension
schemaCopy.Dimensions(strcmp({schemaCopy.Dimensions.Name},'range')).Name = 'height';
% Adjust length to vertical coordinate
schemaCopy.Dimensions(strcmp({schemaCopy.Dimensions.Name},'height')).Length = length(verticalCoordinate);
% Write schema to new file
ncwriteschema(outfile,schemaCopy);
% Write data to outfile
ncwrite(outfile,'height',verticalCoordinate)

% Read outfile file information
outfileInfo = ncinfo(outfile);

%% Copy Unmodified Variables
fprintf('%s\n','')
disp('Copy Unmodified Variables')
% Copy one-dimensional radar variables
for i=1:length(varCopy)
    if ncVarInFile(RadarFile,varCopy{i})
        varInfo = ncinfo(RadarFile,varCopy{i});
        disp(['    ' varCopy{i}])
        if varInfo.Size==1
            copyNetCDFVariable(RadarFile,varCopy{i},outfile)
        elseif length(varInfo.Size)==1  % only time dimension
            % Copy schema from orig file
            schemaCopy = ncinfo(RadarFile,varCopy{i});
            % Set format to 'netcdf4_classic', compatible with bahamas data
            schemaCopy.Format = outfileInfo.Format;

            % Read data from file
            copyData = ncread(RadarFile,varCopy{i});
            copyData = copyData(indRadar);
            % Adjust variable type
            schemaCopy.Datatype = class(copyData);
            % Write schema to new file
            ncwriteschema(outfile,schemaCopy);

            ncwrite(outfile,varCopy{i},copyData);
        else
            error(['Unexpected dimensions. Please consider listing the variabel '...
                   varCopy{i} ' under ''varEdit''.'])
        end
    end
end
% Copy global attributes
copyNetCDFglobalAtt(RadarFile,outfile)


%% Write Bahamas data to NetCDF
fprintf('%s\n','')
disp('Write Bahamas data to NetCDF')
for i=1:length(varBahamas)
    disp(['    ' varBahamas{i}])
    % Copy schema from orig file
    schemaCopy = ncinfo(BahamasFile,varBahamas{i});
    % Remove global fill value
    schemaCopy.FillValue = [];
    % Remove size, let it be determined automatically
    schemaCopy.Size = [];
    % Rename time dimension
    if ncVarInFile(BahamasFile,'utc_time')
        schemaCopy.Dimensions(strcmp({schemaCopy.Dimensions.Name},'utc_time')).Name = 'time';
    else
        schemaCopy.Dimensions(strcmp({schemaCopy.Dimensions.Name},'tid')).Name = 'time';
    end
    % Add Atribute 'yrange'
    schemaCopy.Attributes(end+1).Name = 'yrange';
    schemaCopy.Attributes(end).Value = [min(dataBahamasTimeAdjusted{i}) max(dataBahamasTimeAdjusted{i})];
    % Write schema to new file
    ncwriteschema(outfile,schemaCopy);
%     % Read data from orig file
%     dataCopy = ncread(RadarFile,varBahamas{i});
    % Write data to outfile
    ncwrite(outfile,varBahamas{i},dataBahamasTimeAdjusted{i});
end

%% Write Radar data to NetCDF
fprintf('%s\n','')
disp('Write Radar data to NetCDF')
for i=1:length(varEdit)
    disp(['    ' varEdit{i}])
    % Copy schema from orig file
    schemaCopy = ncinfo(RadarFile,varEdit{i});
    % Add fill value information
    schemaCopy.Attributes(end+1).Name = 'fill_value';
    schemaCopy.Attributes(end).Value = 'NaN';
    % Set format to 'netcdf4_classic', compatible with bahamas data
    schemaCopy.Format = outfileInfo.Format;
    % Remove size, let it be determined automatically
    schemaCopy.Size = [];
    % Rename height dimension
    schemaCopy.Dimensions(strcmp({schemaCopy.Dimensions.Name},'range')).Name = 'height';
    % Adjust length to vertical coordinate
    schemaCopy.Dimensions(strcmp({schemaCopy.Dimensions.Name},'height')).Length = length(verticalCoordinate);
    % Write schema to new file
    ncwriteschema(outfile,schemaCopy);
    
    % Change missing value in data from -Inf to specified in function call
    dataRadarCorr{i}(isinf(dataRadarCorr{i})) = missingvalue;
    
    % Write data to outfile
    ncwrite(outfile,varEdit{i},single(dataRadarCorr{i}));
end
    
%% Calculate dBZ
fprintf('%s\n','')
disp('Calculate dBZ')
if ismember('Zg',varEdit)
    
    
%     Zg(Zg==missingvalue) = -Inf;
    % Calculate dBZ
    dBZg = 10 .* log10(Zg);
    
    % Only keep real part of array (imaginary numbers were created when
    % taking log10 of -Inf: log10(-Inf) = Inf +      1.36437635384184i)
    dBZg = real(dBZg);
    % And convert positive infinity back to negative infinity
    dBZg(isinf(dBZg)) = -Inf;
    
    % Replace -Inf with missingvalue
%     dBZg(isinf(dBZg)) = missingvalue;
    
    % Copy netCDF scheme
    schemaCopy = ncinfo(outfile,'Zg');
    % Change name
    schemaCopy.Name = 'dBZg';
    % Remove global fill value
    schemaCopy.FillValue = [];
    % Delete size information
    schemaCopy.Size = [];
    % Change long name attribute
    schemaCopy.Attributes(strcmp({schemaCopy.Attributes.Name},'long_name')).Value = 'Reflectivity dBzg';
    schemaCopy.Attributes(strcmp({schemaCopy.Attributes.Name},'units')).Value = ' ';
    schemaCopy.Attributes(strcmp({schemaCopy.Attributes.Name},'yrange')).Value = [min(min(dBZg)) max(max(dBZg))];
    
    % Write schema to new file
    ncwriteschema(outfile,schemaCopy);
    
    % Apply missing value to dBZ variable
    dBZg(isinf(dBZg)) = missingvalue;
    
    % Write data to outfile
%     ncwrite(outfile,schemaCopy.Name,single(dBZg));
    ncwrite(outfile,schemaCopy.Name,dBZg);
else
    fprintf('%s\n','')
    disp('No Reflectivity Z found. Skipping dBZ calculation...')
end

%% Flags
fprintf('%s\n','')
disp('Create flags')

% Convert logical to double
turnInd = uint8(turnInd);
nccreate(outfile,'curveFlag','Dimensions',{'time',inf})
ncwrite(outfile,'curveFlag',turnInd)
ncwriteatt(outfile,'curveFlag','units',' ')
ncwriteatt(outfile,'curveFlag','long_name','flag for roll angle > 3 deg, regarded as turn')
ncwriteatt(outfile,'curveFlag','yrange',[0 1])

%% Add to global attributes

if nargin>3 && strcmp(varargin{1},'nolobes')
    ncwriteatt(outfile,'/','version_history',...
        ['v' versionNumber '.' subversionNumber ': data flipped, time offset corrected, flight attitude corrected, sidelobes not removed'])
else
    ncwriteatt(outfile,'/','version_history',...
        ['v' versionNumber '.' subversionNumber ': data flipped, time offset corrected, flight attitude corrected'])
end
ncwriteatt(outfile,'/','conversion_information',...
    ['converted by Heike Konow on ' datestr(now,'dd.mm.yyyy HH:MM') ', using: "' mfilename '.m"'])


%------------- END OF CODE --------------