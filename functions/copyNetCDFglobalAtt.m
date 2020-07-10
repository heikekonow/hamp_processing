function copyNetCDFglobalAtt(infile,outfile)

% Function for copying a netcdf global attributes to a new file

if ~exist(outfile,'file')
    error(['The file ' outfile ' does not exist. Please create first...'])
end

% Read flight date and numbers
[NARVALdates, NARVALdatenum] = flight_dates;

% Read nc file information
infileInfo = ncinfo(infile);

% Read flight date
t = ncread(infile,'time');
flightDate = floor(unixtime2sdn(t(1)));
indFlightInfo = NARVALdatenum==flightDate;
flightNumber = NARVALdates{indFlightInfo,2};
flightMission = NARVALdates{indFlightInfo,3};

clear t

% List global attributes
glAttNames = cellstr(char(infileInfo.Attributes(:).Name));
glAttValues = cellstr(char(infileInfo.Attributes(:).Value));

% Replace information
glAttValues{cellfun(@(x) strcmp(x,'location'),glAttNames)} = 'HALO aircraft, D-ADLR';
glAttValues{cellfun(@(x) strcmp(x,'institution'),glAttNames)} = 'ZMAW Hamburg';

%% Split attribute names and values to change order
% find entry 'source' to insert additional fields before
indCopy = find(strcmp(glAttNames,'source'));
% split attribute names and values
glAttNamesCopy = glAttNames(indCopy:end);
glAttValuesCopy = glAttValues(indCopy:end);
glAttNames = glAttNames(1:indCopy-1);
glAttValues = glAttValues(1:indCopy-1);

%% Add additional information
glAttNames{end+1} = 'authors';
glAttValues{end+1} = 'Lutz Hirsch, Heike Konow';

glAttNames{end+1} = 'contact';
glAttValues{end+1} = 'lutz.hirsch@mpimet.mpg.de, heike.konow@zmaw.de';
glAttNames{end+1} = 'mission';
glAttValues{end+1} = flightMission;
glAttNames{end+1} = 'flight number';  
glAttValues{end+1} = flightNumber;

%% Concatenate attribute names and values
glAttNames = vertcat(glAttNames,glAttNamesCopy);
glAttValues = vertcat(glAttValues,glAttValuesCopy);

% Write global attributes
cellfun(@(x,y) ncwriteatt(outfile,'/',x,y),glAttNames,glAttValues);