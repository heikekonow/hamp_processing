%% assess_radar_data
%   assess_radar_data - code for assessing errors in radar data
%
%       Set 'figures' to true to go through plots of radar reflectivity for
%       each flight and note indices of beginning and end of errors in
%       radarErrorsLookup.m
%
%       Set 'calc' to true to calculate an error index array according to
%       Bahamas time array that indicates data availability.
%
%       If both are set to false, error data will be only loaded into the
%       program and an overview plot is generated.
%
%
%   Syntax:  assess_radar_data
%
%   Inputs:
%       none
%
%   Outputs:
%       none; error index file in [DATAPATH]/mat/ directory
%
%
%
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   June 2017; Last revision: April 2020

%------------- BEGIN CODE --------------
%%

% General housekeeping
% clear; close all

%% Set parameters
% If figures should be produced
figures = false;
% If error time steps should be calculated from indices
calc = false;

% Set campaign to investigate
campaign = 'EUREC4A';

% Set minimum altitude for observations
minalt = 4000;

%% Get dates and folder paths

% Get dates for campaign
dates = getCampaignDates(campaign);
% Set path to data
basefolder = [getPathPrefix getCampaignFolder(dates{1})];
pathRadar = [basefolder 'radar/'];



%%
if figures
    % Preallocate arrays
    dBZ = cell(1,length(dates));
    Z = cell(1,length(dates));
    
    % Loop all flight dates
    for i=1:length(dates)
        
        % List files in data folder
        files = listFiles([pathRadar '*' dates{i} '*.nc'], 'full');
        
        % Loop all files for flight day
        for j=1:length(files)
            
            % Read reflectivity
            Z{i}{j} = ncread(files{j},'Zg');
        end
        
        % Concatenate data
        Z{i} = [Z{i}{:}];
        
        % Calculate dBZ
        dBZ{i} = 10 .* log10(Z{i});
        dBZ{i} = real(dBZ{i});

        % Create figure
        figure
        % Set figure size
        set(gcf,'Position',[475 557 1409 534])

        % Plot reflectivity
        imagesc(dBZ{i})

        % Adjust figure
        addWhiteToColormap
        tick2text(gca,'xformat','%.0f')
        title(dates{i})

        % Pause code to analyse figure manually:
        % Zoom in to figure and note down beginning and ending of error
        % segments
        pause

        % Close figure
        close
    end
end

%%
if calc
    % Load error indices
    errors = radarErrorsLookup;
    
    
    pathBahamas = [basefolder 'bahamas/'];
    
    % Preallocate arrays
    bahamasFile = cell(1,length(dates));
    tBahamas = cell(1,length(dates));
    hBahamas = cell(1,length(dates));
    tRadar = cell(1,length(dates));
    errorInd = cell(1,length(dates));
    
    % Loop flight dates
    for i=1:length(dates)
        
        % List radar files
        files = listFiles([pathRadar '*' dates{i} '*.nc'], 'full');
        
        % Find date index in errors
        indDate = strcmp(errors(:,1), dates{i});
        
        % If files were found
        if ~isempty(files)
            
            % Output
            disp(dates{i})
            
            % Loop radar files
            for j=1:length(files)
                tRadar{i}{j} = unixtime2sdn(ncread(files{j},'time'));
            end
            
            % Concatenate data
            tRadar{i} = vertcat(tRadar{i}{:});
        
            % List BAHAMAS files
            bahamasFile{i} = cell2mat(listFiles([pathBahamas '*' dates{i} '*.nc'], 'full'));
            % Read BAHAMAS time
            tBahamas{i} = unixtime2sdn(ncread(bahamasFile{i},'TIME'));
            % Read BAHAMAS altitude
            hBahamas{i} = ncread(bahamasFile{i},'IRS_ALT');
            
            % Find indices of altitude above minimum altitude
            indH_minalt(1) = find(hBahamas{i}>minalt,1,'first');
            indH_minalt(2) = find(hBahamas{i}>minalt,1,'last');
            
            % Find times with altitudes above minimum altitude
            tH_minalt(1) = tBahamas{i}(indH_minalt(1));
            tH_minalt(2) = tBahamas{i}(indH_minalt(2));
            
            % Create error array
            errorInd{i} = zeros(1,length(tRadar{i}));
            % Set error array to one for error time steps
            errorInd{i}(errors{indDate,2}) = 1;
            
            % Set error array to three for times below minimum altitude
            errorInd{i}(1:find(tRadar{i}<tH_minalt(1),1,'last')) = 3;
            errorInd{i}(find(tRadar{i}>tH_minalt(2),1,'first'):end) = 3;

        
        % If no radar data was found
        else
            % List BAHAMAS files
            bahamasFile{i} = cell2mat(listFiles([pathBahamas '*' dates{i} '*.nc'], 'full'));
            % Read BAHAMAS time
            tBahamas{i} = unixtime2sdn(ncread(bahamasFile{i},'TIME'));
            % Read BAHAMAS altitude
            hBahamas{i} = unixtime2sdn(ncread(bahamasFile{i},'IRS_ALT'));
            
            % Find indices of altitude above minimum altitude
            indH_minalt(1) = find(hBahamas{i}>minalt,1,'first');
            indH_minalt(2) = find(hBahamas{i}>minalt,1,'last');
            
            % Find times with altitudes above minimum altitude
            tH_minalt(1) = tBahamas{i}(indH_minalt(1));
            tH_minalt(2) = tBahamas{i}(indH_minalt(2));
            
            % Create error index and set to one, since there are no radar
            % data
            errorInd{i} = ones(1,length(tBahamas{i}));
        end
    end
    
    % Calculate percentages
    percentage = cell2mat(cellfun(@(x) round(sum(x~=0)./length(x).*100,3),errorInd,'UniformOutput',false));
    
    % Check if folder exists and create if not
    checkandcreate(basefolder, 'mat')
    
    % Save file
    save([basefolder 'mat/radarErrorAssessment_' campaign])
else
    % Save file
    load([basefolder 'mat/radarErrorAssessment_' campaign])
end

%% Plot

% Create labels for flight dates
datelabels = [repmat('RF',length(dates),1) num2str([1:length(dates)]','%02d') repmat(', ',length(dates),1) ...
                datestr(datenum(dates,'yyyymmdd'),'dd.mm.')];

% Ppen figure and set size
figure
set(gcf,'Position',[95 349 656 721])

% Plot horizontal bars
bh = barh(1:length(dates),[percentage' 100-percentage'],'stacked');

% Change bar colors
set(bh(2),'FaceColor',[79, 129, 189]./255,'EdgeColor',[1 1 1])
set(bh(1),'FaceColor',[183, 187, 194]./255,'EdgeColor',[1 1 1])
% Add labels to y axis
set(gca,'YTickLabel',datelabels)
% Make pretty
finetunefigures
setFontSize(gcf,14)
grid off
set(gca,'TickLength',[ 0 0 ])
set(gca,'YDir','reverse')
set(gca,'YLim',[0.5 length(dates)+0.5])
xlabel('(%)')

% Change axes properties
ax1 = gca;
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

% Add legend
lh = legend(bh,'no data','data');

% Check if folder exists and create if not
checkandcreate(basefolder, 'figures')

% Save figure
export_fig([basefolder 'figures/radarErrorAssessment_' campaign],'-pdf')



%------------- END OF CODE --------------



