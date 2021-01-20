function [dimnames,dimlengths] = nclistdims(pathtofile)


ncid = netcdf.open(pathtofile,'NC_NOWRITE');
% [numdims,~,~,~] = netcdf.inq(ncid);
dimIDs = netcdf.inqDimIDs(ncid);
% dimnames = cell(numdims,1);
% dimids = cell(numvars,1);
dimnames = cell(length(dimIDs),1);
dimlengths = cell(length(dimIDs),1);

% netcdf.inqVar function starts counting with 0
for i = dimIDs
    [dimnames{i+1},dimlengths{i+1}] = netcdf.inqDim(ncid,i);
end

netcdf.close(ncid)