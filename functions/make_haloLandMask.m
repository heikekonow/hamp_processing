function make_haloLandMask(flightdates_mask,outfile,varargin)

% Set file paths
% outfile = [getPathPrefix 'ucp_hamp_work_data/radarMask.mat'];
ls_path = [getPathPrefix getCampaignFolder(flightdates_mask{1}) 'aux/lsmask-world8-var.dist5.5.zip.nc'];

if isempty(listFiles(ls_path))
    error('Land mask file not found. Please download the file lsmask-world8-var.dist5.5.nc from https://www.ghrsst.org/ghrsst-data-services/tools/')
end

% % Define dates to use
% flightdates_mask = get_campaignDates('2016');

% Read data
lat_lsmask = ncread(ls_path,'lat');
lon_lsmask = ncread(ls_path,'lon');
dst = ncread(ls_path,'dst');

% Rename
lsmask = dst;

if nargin==2 || any(strcmp(varargin,'simple'))
    % Switch values: 
    %   original: 0 indicates land; numbers >0 show distance from coast in
    %             pixels (??); fill values <0 indicate sea
    %   new:      1 indicates land; set all sea values to 0
    lsmask(lsmask==0) = 1;
    lsmask(lsmask<0) = 0;
    lsmask(lsmask>1) = 0;
end

% Clear variable
clear dst

% Preallocate
landMask = cell(length(flightdates_mask),1);

% Loop flights
for f=1:length(flightdates_mask)
    % Get file names
    filepath = listFiles([getPathPrefix  getCampaignFolder(flightdates_mask{f}) 'all_nc/*bahamas*' flightdates_mask{f} '*.nc'],'fullpath', 'latest');
    
    % Read position data
    lat = ncread(filepath,'lat');
    lon = ncread(filepath,'lon');
    
    % Preallocate according to uni data format
    landMask{f} = zeros(length(lat),1);
    
    disp([num2str(f)])
    
    % Loop time
    for i=1:length(lat)
        
        if mod(i,500)==0
            disp([num2str(i) ' / ' num2str(length(lat))])
        end
        
        
        if ~isnan(lat(i)) || ~isnan(lon(i))
           
            % Calculate differences of aircraft position to land sea mask grid
            lat_diff = abs(lat(i)-lat_lsmask);
            lon_diff = abs(lon(i)-lon_lsmask);

            % Get indices of closest latitude/longitude grid
            lat_ind = find(lat_diff==min(lat_diff),1,'first');
            lon_ind = find(lon_diff==min(lon_diff),1,'first');
% 
%             if f==2 && i==21728
%                 disp('')
%             end
            % Copy value into variable
            landMask{f}(i) = lsmask(lon_ind,lat_ind);
        else
            landMask{f}(i) = landMask{f}(i-1);
        end
    end
    if nargin==2 || any(strcmp(varargin,'simple'))
        % Convert to logical
        landMask{f} = logical(landMask{f});
    end
end

%% Write data
% If file already exists, write in append mode to keep the other variables
% in the file, otherwise, generate a new one
if exist(outfile,'file')
    save(outfile,'landMask','flightdates_mask','-append')
else
    save(outfile,'landMask','flightdates_mask','-v7.3')
end