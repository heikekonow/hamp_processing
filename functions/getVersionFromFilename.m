function versionstr = getVersionFromFilename(filename, varargin)

ind = regexp(filename, '_v');
ind2 = regexp(filename, '\.nc');
versionstr = filename(ind+2:ind2-1);

if any(strcmp(varargin, 'num'))
    versionstr = str2double(versionstr);
end