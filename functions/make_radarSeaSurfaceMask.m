function make_radarSeaSurfaceMask(flightdates_mask,maskFile, numRangeGatesForSeaSurface)

% File to load land mask from and to write surface mask to
% maskFile = [getPathPrefix 'ucp_hamp_work_data/radarMask.mat'];

% Rename variable
flightdates_mask_input = flightdates_mask;

% Load data
load(maskFile,'noiseMask','landMask','flightdates_mask')

% Check if dates match
if ~isequal(flightdates_mask_input,flightdates_mask)
    error('Flight dates don''t match please check input dates and dates in file')
else
    clear flightdates_mask_input
end

% Preallocate
seaSurfaceMask = cell(length(flightdates_mask),1);

% Loop all dates from file
for i=1:length(flightdates_mask)
    
    % Find radar files from day. 
    radarfiles = listFiles([getPathPrefix  getCampaignFolder(flightdates_mask{i}) ...
                 'all_nc/radar*' flightdates_mask{i} '*.nc'],'fullpath');
    
    % Look for version numbers below v1.0 to ensure that side lobes haven't
    % been removed from the data yet
%     versionNum = cellfun(@(x) getVersionFromFilename(x, 'num'), radarfiles);
%     ind_version = find(versionNum < 1, 1, 'last');
    
    [version, subversion] = cellfun(@(x) getVersionSubversionFromFilename(x), radarfiles, 'UniformOutput', false);
    
    version = cellfun(@str2num, version);
    subversion = cellfun(@str2num, subversion);
    ind_version = (version<1 & subversion==max(subversion));
    
    % Output
    disp(flightdates_mask{i})
    
    % Check if radar was working
    if ncVarInFile(radarfiles{ind_version},'dBZ')
        
        % Read data
        z = ncread(radarfiles{ind_version},'dBZ');
        t = unixtime2sdn(ncread(radarfiles{ind_version},'time'));
        h = ncread(radarfiles{ind_version},'height');
        
        % Remove -inf values
        z(~isfinite(z)) = nan;
        
        
%         landmask_nan = double(landMask{i});
%         landmask_nan(landmask_nan==0) = nan;
        
        % Rename
        landmask = landMask{i};
        
        % Find instances where there is radar signal in any of the lowest
        % four range gates
        ind_SeaSurf = sum(~isnan(z(1:numRangeGatesForSeaSurface,:)),1)~=0;
        
        % Generate empty array for surface mask
        seaSurfaceMask{i} = false(length(h),length(t));
        
        % Set lowest four range gates to sea surface if there was a radar
        % signal in any of them and HALO was not over land
        seaSurfaceMask{i}(1:numRangeGatesForSeaSurface, ind_SeaSurf & ~landmask') = true;
        
    end
    
    disp(' ')
end


%% Saving data
save(maskFile,'seaSurfaceMask','-append')