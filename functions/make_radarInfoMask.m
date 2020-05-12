function make_radarInfoMask(flightdates_mask,maskFile,varargin)

% File to load land mask from and to write surface mask to
% maskFile = [getPathPrefix 'ucp_hamp_work_data/radarMask.mat'];

% Load data
load(maskFile,'noiseMask','surfaceMask','seaSurfaceMask','calibrationMask','flightdates_mask')


key = {0,'good';
       1,'noise';
       2,'surface';
       3,'sea'
       4,'radar calibration'};

radarInfoMask = cell(length(flightdates_mask),1);

for i=1:length(flightdates_mask)
    radarInfoMask{i} = zeros(size(noiseMask{i}));
    
    radarInfoMask{i}(surfaceMask{i}) = 2;
    
    radarInfoMask{i}(seaSurfaceMask{i}) = 3;
    
    radarInfoMask{i}(calibrationMask{i}) = 4;
    
    % make noise at last to overwrite all other masks
    radarInfoMask{i}(noiseMask{i}) = 1;
    
    if nargin>2 && strcmp(varargin{1},'figures')
        
        bahamasfile = listFiles([getPathPrefix getCampaignFolder(flightdates_mask{i})  'all_nc/*bahamas*' flightdates_mask{i} '*.nc'],'fullpath');
        t = ncread(bahamasfile{end},'time');
        h = ncread(bahamasfile{end},'height');
        if ~issdn(t(1))
            t = unixtime2sdn(t);
        end
        
        fh = figure;
        cm = brewermap(5,'Set1');
        cm(1,:) = [];
        set(gcf, 'color','white');
        imagesc(t,h,radarInfoMask{i})
        colormap(cm)
        addWhiteToColormap
        set(gca,'CLim',[0 max(cell2mat(key(:,1)))])
        ch = colorbar;
        ch.Ticks = ch.Limits(1)+ch.Limits(2)/size(colormap,1)/2 : ch.Limits(2)/size(colormap,1) : ch.Limits(2);
        ch.TickLabels = key(:,2);
        set(gca,'YDir','normal')
%         set(gca,'XLim',[736618.408189553 736618.458438197],...
%                 'YLim',[-225 4750])
        datetick('x','HH:MM','Keeplimits')
        title(flightdates_mask{i})
        xlabel('Time (UTC)')
        ylabel('Height (m)')
        setFontSize(gca,12)
        if i==22
%             export_fig([getPathPrefix 'NANA_campaignData/figures/radarMask_' flightdates_mask{i} '_1'],'-pdf')
            export_fig([getPathPrefix 'NANA_campaignData/figures/radarMask_' flightdates_mask{i} '_1'],'-png')
        end
    end
end

key = {1,'noise';
       2,'surface';
       3,'sea'
       4,'radar calibration'};

%% Saving data
save(maskFile,'radarInfoMask','key','-append')