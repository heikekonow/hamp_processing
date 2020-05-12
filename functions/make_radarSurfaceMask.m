function make_radarSurfaceMask(flightdates_mask,maskFile)

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
surfaceMask = cell(length(flightdates_mask),1);

% Loop all dates from file
for i=1:length(flightdates_mask)
    
    % Find radar files from day. 
    % ! Obs: use version 2.3 for this analysis since side lobes during
    % turns have not been removed in this data set
%     if str2double(flightdates_mask)<20160000
%         radarfiles = listFiles([getPathPrefix 'NARVAL-I_campaignData/all_nc/*' flightdates_mask{f} '*v2.3*.nc'],'fullpath');
%     else
%         radarfiles = listFiles([getPathPrefix 'NANA_campaignData/all_nc/*' flightdates_mask{i} '*v2.3*.nc'],'fullpath');
%     end 
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

        % Omit the first and last two minutes of each flight in land mask, since
        % the radar has not been operating durign these times...
        landmask(1:120) = false;
        landmask(end-120:end) = false;
        
        % Remove noise and set to nan
        z(logical(noiseMask{i})) = nan;
        
        % Calculate maximum reflectivity for each profile
        zMax = max(z,[],1,'omitnan');
        % Remove maximum reflectivity values over sea
        zMax(~landmask) = nan;
        
%         av_zMax = mean(zMax,'omitnan');
%         std_zMax = std(zMax,'omitnan');
        
        % Preallocate
        indZMax = nan(size(landmask_nan));
        hSurf = nan(length(t),1);
        
        % Get indices of profiles without reflectivity measured
        ind_noReflectivityProfile = sum(isnan(z),1)==length(h);
        
        % Loop time
        for j=1:length(t)
            % Check if landmask is 1 
            %    and at least one measurement in radar profile
            %    and profile's reflectivity maximum is larger 30 dBZ %%%%%than average zMaximum - 1 standard deviation
            %    !!!! change this value after radar data has been recalculatede !!!
            if ~isnan(landmask_nan(j)) && ~ind_noReflectivityProfile(j) && zMax(j)>=30%av_zMax-std_zMax
                indZMax(j) = find(z(:,j)==zMax(j));
                hSurf(j) = h(indZMax(j));
%                 plot(t(j),hSurf(j),'xk')
            end
        end

        %% Fill gaps in surface height
        
        % Find first and last time step over land
        % (in doing this, gaps in the beginning and the end of the flight
        % without supporting surface height data are not filled)
        ind_first = find(~isnan(hSurf),1,'first');
        ind_last = find(~isnan(hSurf),1,'last');
        
        % Preallocate
        hSurf_filledNan = nan(size(hSurf));
        % Fill gaps of surface height and write into time vector
        % accordingly
        hSurf_filledNan(ind_first:ind_last) = fillgaps(hSurf(ind_first:ind_last),20);

        % Threshold of 30 dBZ worked for NAWDEX but not for NARVAL-II, to
        % be sure, just discard the lowest three to four range gates
%         ind_SeaSurf = double(sum(z(1:4,:)>=30,1)~=0);
%         ind_SeaSurf(ind_SeaSurf==0) = nan;

        % Remove time steps over ocean and with empty profiles
        hSurf_filledNan(~landmask) = nan;
        hSurf_filledNan(ind_noReflectivityProfile) = nan;
        
        % Generate empty array for surface mask
        surfaceMask{i} = false(length(h),length(t));
%         seaSurfaceMask{i} = zeros(length(h),length(t));
        
        % Preallocate
        ind_hSurf = nan(length(t),1);
        
        % Loop time
        for j=1:length(t)
            
            % If time step is over land and surface height is not nan
            if landmask(j) && ~isnan(hSurf_filledNan(j))
                
                % Find range gate in which surface height falls in
                diff_hSurf = abs(hSurf_filledNan(j)-h);
                ind_hSurf(j) = max(find(diff_hSurf==min(diff_hSurf)));
                
                % Write one to surface mask from bottom to surface height
                % plus two range gates (just to be sure)
                surfaceMask{i}(1:ind_hSurf(j)+2,j) = true;
            end
        end
                
% % %         % Plot resulting figure
% % %         fh = figure;
% % %         imagesc(t,h,z)
% % %         addWhiteToColormap
% % %         set(gca,'YDir','normal')
% % %         datetick('x','HH:MM')
% % %         title(flightdates_mask{i})
% % %         hold on
% % %         plot(t,landmask_nan-100,'rx')
% % %         ylim([-1000 15000])
% % %         figure(fh)
% % %         hold on
% % %         plot(t,hSurf,'xk')
% % %         plot(t,hSurf_filledNan,'co')
% % %         plot(t,ind_SeaSurf-50,'+g') 
        
    end
    
    disp(' ')
end

%% Saving data
save(maskFile,'surfaceMask','-append')