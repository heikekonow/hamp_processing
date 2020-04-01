function versionstr = getVersionFromFilename(filename)

ind = regexp(filename, '_v');
ind2 = regexp(filename, '\.nc');
versionstr = filename(ind+2:ind2-1);