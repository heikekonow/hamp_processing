function make_radarSeaSurfaceMask(flightdates_mask,maskFile)

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
    % ! Obs: use version 2.3 for this analysis since side lobes during
    % turns have not been removed in this data set
    radarfiles = listFiles([getPathPrefix  setCampaignFolder(flightdates_mask{i}) 'all_nc/*' ...
                        flightdates_mask{i} '*v2.3*.nc'],'fullpath');
    
    % Output
    disp(flightdates_mask{i})
    
    % Check if radar was working
    if ncVarInFile(radarfiles{end},'dBZ')
        
        % Read data
        z = ncread(radarfiles{end},'dBZ');
        t = unixtime2sdn(ncread(radarfiles{end},'time'));
        h = ncread(radarfiles{end},'height');
        
        % Remove -inf values
        z(~isfinite(z)) = nan;
        
        landmask_nan = double(landMask{i});
        landmask_nan(landmask_nan==0) = nan;

        landmask = landMask{i};
        
        ind_SeaSurf = sum(~isnan(z(1:4,:)),1)~=0;
%         ind_SeaSurf(ind_SeaSurf==0) = nan;
        
        % Generate empty array for surface mask
        seaSurfaceMask{i} = false(length(h),length(t));
        
        seaSurfaceMask{i}(1:4,ind_SeaSurf & ~landmask') = true;
        
%         if i==22
%             % Plot resulting figure
%             fh = figure;
%             set(gcf, 'color','white');
%             imagesc(t,h,z)
%             addWhiteToColormap
%             set(gca,'YDir','normal')
%             set(gca,'XLim',[736618.408189553 736618.458438197],...
%                     'YLim',[-225 4750])
%             datetick('x','HH:MM','Keeplimits')
%             title(flightdates_mask{i})
%             hold on
%             plot(t,landmask_nan-100,'rx')
%             figure(fh)
%             hold on
% 
%             [row,col] = find(seaSurfaceMask{i});
%             plot(t(col),h(row),'x','Color',[.8 .8 .8])
%             export_fig(['/data/share/narval/work/heike/NANA_campaignData/figures/findSeaSurf_' flightdates_mask{i} '_1'],'-pdf')
%             
%             set(gca,'XLim',[736618.46626664 736618.468793588],...
%                     'YLim',[-225 365])
%             datetick('x','HH:MM','Keeplimits')
%             export_fig(['/data/share/narval/work/heike/NANA_campaignData/figures/findSeaSurf_' flightdates_mask{i} '_2'],'-pdf')
%         end
    end
    
    disp(' ')
end


%% Saving data
save(maskFile,'seaSurfaceMask','-append')