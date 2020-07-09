function [ncVarNames, ncDims, varData, varInfo] = ...
                addMaskToOutput(maskfile, flightdates_use, ncVarNames, ncDims, varData, varInfo)

% %% Specify which radar mask data to load
% if str2double(flightdates_use{i})<20160000
% campaign = 'NARVAL-I';
% else
% campaign = '2016';
% end
% 
% maskfile = [getPathPrefix 'ucp_hamp_work_data/radarMask_' campaign '.mat'];

load(maskfile,'radarInfoMask','flightdates_mask','key')

ind_dateMask = strcmp(flightdates_use,flightdates_mask);

ncVarNames{end+1,1} = 'radarInfoMask';

% ind_copyDims = strcmp(ncVarNames,'unidBZg');
% if sum(ind_copyDims)~=0
%     ncDims{end+1,1} = ncDims{ind_copyDims,1};
% else
ind_time = strcmp(ncVarNames,'uniTime');
ind_height = strcmp(ncVarNames,'uniHeight');
ncDims{end+1,1} = [ncDims{ind_height},ncDims{ind_time}];
%                         end


varData{end+1} = radarInfoMask{ind_dateMask};
varInfo{end+1,1} = [num2str(key{1,1}) ': ' key{1,2} '; ' ...
                num2str(key{2,1}) ': ' key{2,2} '; ' ...
                num2str(key{3,1}) ': ' key{3,2} '; ' ...
                num2str(key{4,1}) ': ' key{4,2}];
varInfo{end,2} = '';
varInfo{end,3} = 'data_flag';
% varInfo{end,4} = 'quality_flag';
varInfo{end,4} = 'radarInfoMask';