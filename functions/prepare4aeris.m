function prepare4aeris(version)
% Code to rename output files according to EUREC4A naming convetion and for
% copying files in outgoing folder

% Specify file name prefix
filenameprefix = 'EUREC4A_HALO_';

% Get folder paths to data and to outgoing folder
pathtofolder = [getPathPrefix getCampaignFolder('20200119')];
outputfolder = [getPathPrefix getCampaignFolder('20200119') 'to_aeris/'];

% Check if outgoing folder exists, if not, create
if ~exist(outputfolder, 'dir')
   mkdir(outputfolder)
   disp(['Subfolder ' outputfolder ' did not exist... has been created.'])
end

% Convert version to string if given as number
if ~ischar(version)
    version = num2str(version);
end

% List files that match version number
files = listFiles([pathtofolder 'all_nc/*' version '*.nc']);

% Only convert files that don't already match naming convention
convertfiles = find(~strncmp(files, filenameprefix, 12));

% Loop all files to convert
for i=1:length(convertfiles)
    
    % Path to input and output files
    infile = [pathtofolder 'all_nc/' files{convertfiles(i)}];
    outfile = [outputfolder filenameprefix files{convertfiles(i)}];
    
    % Copy file and rename
    copyfile(infile, outfile)
end