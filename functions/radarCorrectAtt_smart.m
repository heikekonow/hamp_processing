%% radarCorrectTimeAngles_smart
%   radarCorrectTimeAngles_smart - Combines data from Mira radar and Smart 
%                          navigation data into one file and corrects for
%                          flight attitude
%           - Loads Smart and Mira data files
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
%   Syntax:  radarCorrectTimeAngles_smart(RadarFile,versionNumber,netCDFPath)
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
%       see script: runRadarSmartAttComb
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
%   August 2019; Last revision: 

%%

function radarCorrectAtt_smart(RadarFile,versionNumber,netCDFPath,varargin)

%------------- BEGIN CODE --------------


ind_folder_string = regexp(RadarFile,'/radar/');
campaignPath = RadarFile(1:ind_folder_string);
smartPath = [campaignPath 'smartnav/'];

subversionNumber = '1';


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

% Search for corresponding smart nav data file
smartFilePos = listFiles([smartPath '*GPSPos*'], 'full');
smartFileIMS = listFiles([smartPath '*IMS*'], 'full');

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

varEdit = {'SNRg','VELg','RMSg','LDRg','HSDco','HSDcx','Zg'};


%% Read smart nav data

[timeSmartIMS, roll, pitch] = read_smart_ascii(smartFileIMS{1}, 'time', 'roll', 'pitch');
[timeSmartPos, alt, lat, lon] = read_smart_ascii(smartFilePos{1}, 'time', 'Alt', 'Lat', 'Lon');


%% Adjust time series
disp('Adjust time series')
fprintf('%s\n','')
% round times to avoid numerical deviations
tSmartIMS = dateround(timeSmartIMS,'second');
tSmartPos = dateround(timeSmartPos,'second');
[tBothSmart,indSmartIMS,indSmartPos] = intersect(tSmartIMS,tSmartPos);

roll = roll(indSmartIMS);
pitch = pitch(indSmartIMS);
alt = alt(indSmartPos);
lat = lat(indSmartPos);
lon = lon(indSmartPos);

tRadar = dateround(tRadar,'second');
% find common entries
[tBoth,indSmart,indRadar] = intersect(tBothSmart,tRadar);
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

% If data matrix is filled with nans, replace with -Inf (set missing value)
dataRadar{strcmp(varEdit,'Zg')}(isnan(dataRadar{strcmp(varEdit,'Zg')})) = missingvalule;

% Adjust to common time steps
dataRadarTimeAdjusted = cellfun(@(x) x(:,indRadar),dataRadar,'UniformOutput',false);
hGPS = alt(indSmart);
rollAngle = roll(indSmart);
pitchAngle = pitch(indSmart);
latitude = lat(indSmart);
longitude = lon(indSmart);


%% Correct Flight Attitude
disp('Correct Attitude')
fprintf('%s\n','')

% Look for roll angles larger than 3 deg, i.e. turning
% Create flag value for turning
% turnInd = (rollAngle>3|rollAngle<-3);
turnInd = (abs(rollAngle)>5);


% Get maximum altitude 
alt_max = max(hGPS);
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

%% Convert Time

% Convert sdn to unix time
tUnixSec = round(sdn2unixtime(tBoth));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize netCDF file


%% Write dimensions, time and range
disp('Write Data')
fprintf('%s\n','')

% Copy time scheme
schemaCopy = ncinfo(RadarFile,'time');
% Delete size information
schemaCopy.Size = [];
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
    % Write data to outfile
    ncwrite(outfile,varEdit{i},single(dataRadarCorr{i}));
end
    
%% Calculate dBZ
fprintf('%s\n','')
disp('Calculate dBZ')
if ismember('Zg',varEdit)
    % Rename Zg variable
    Zg = dataRadarCorr{strcmp(varEdit,'Zg')};
    % Calculate dBZ
    dBZg = 10 .* log10(Zg);
    
    % Only keep real part of array (imaginary numbers were created when
    % taking log10 of -Inf: log10(-Inf) = Inf + 1.36437635384184i)
    dBZg = real(dBZg);
    % And convert positive infinity back to negative infinity
    dBZg(isinf(dBZg)) = -Inf;
    
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
    
    % Write data to outfile
    ncwrite(outfile,schemaCopy.Name,single(dBZg));
else
    fprintf('%s\n','')
    disp('No Reflectivity Z found. Skipping dBZ calculation...')
end

%% Save attitude data to netcdf 
% (alt, lat, lon, roll, pitch)
smartVars = {'altitude', 'latitude', 'longitude', 'pitch', 'roll'};
smartDims = {{'time', length(tUnixSec)}, {'time', length(tUnixSec)}, ...};
             {'time', length(tUnixSec)}, {'time', length(tUnixSec)}, ...
             {'time', length(tUnixSec)}};
smartData = {hGPS, latitude, longitude, pitchAngle, rollAngle};

smartLongn = {'Altitude', 'Latitude', 'Longitude', 'Pitch angle', 'Roll angle'};
smartUnit = {'m', 'deg North', 'deg East', 'deg', 'deg'};

for i=1:length(smartVars)
    nccreate(outfile, smartVars{i}, 'Dimensions', smartDims{i}, ...
        'Datatype', 'double');
    
    ncwrite(outfile, smartVars{i}, smartData{i});
    
    ncwriteatt(outfile, smartVars{i}, 'long_name', smartLongn{i});
    ncwriteatt(outfile, smartVars{i}, 'units', smartUnit{i});
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
        ['v' versionNumber '.' subversionNumber ': smart data used to flip data and correct aircraft attitude, sidelobes not removed'])
else
    ncwriteatt(outfile,'/','version_history',...
        ['v' versionNumber '.' subversionNumber ': data flipped, time offset corrected, flight attitude corrected'])
end
ncwriteatt(outfile,'/','conversion_information',...
    ['converted by Heike Konow on ' datestr(now,'dd.mm.yyyy HH:MM') ', using: "' mfilename '.m"'])


%------------- END OF CODE --------------