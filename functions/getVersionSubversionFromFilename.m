function [vers, subvers] = getVersionSubversionFromFilename(filename, varargin)

ind = regexp(filename, '_v');
ind2 = regexp(filename, '\.nc');
versionstr = filename(ind+2:ind2-1);

indDot = regexp(versionstr, '\.');
vers = versionstr(1:indDot-1);
subvers = versionstr(indDot+1:end);

% if any(strcmp(varargin, 'num'))
%     versionstr = str2double(versionstr);
% end