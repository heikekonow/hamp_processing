function copyNetCDFVariable(infile,varname,outfile)

% Function for copying a netcdf variable to a new file

if ~exist(outfile,'file')
    error(['The file ' outfile ' does not exist. Please create first...'])
end

% Read nc file information
outfileInfo = ncinfo(outfile);

 % Copy schema from original file
schemaCopy = ncinfo(infile,varname);
% Set format to 'netcdf4_classic', compatible with bahamas data
schemaCopy.Format = outfileInfo.Format;
% Write schema to new file
ncwriteschema(outfile,schemaCopy);
% Read data from orig file
dataCopy = ncread(infile,varname);
% Write data to outfile
ncwrite(outfile,varname,dataCopy);