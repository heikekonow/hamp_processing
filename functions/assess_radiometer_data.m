%% assess_radiometer_data
%   assess_radiometer_data - use this to assess radiometer measurement errors
%   In the beginning of the program, set the mode for this program:
%       
%       Set figures = true if you want to look through figures from 
%           individual flights and note error and saw tooth occurrences.
%           Note error and saw tooth interval indices in file
%           'radiometerErrorsLookup.m'
%       Set calc = true if you want to calculate error percentages.
%       Set overview = true if you want to produce overview figure.
%
%   Syntax:  assess_radiometer_data(figures, calc, overview, campaign)
%
%   Inputs:
%       figures  - set to true to create figures to identify errors
%       calc     - set to true if error time steps should be calculated from indices
%       overview - set to true if overview figure should be produced
%       campaign - campaign name as string
%
%   Outputs:
%       none
%
%   Example: 
%       figures = false;
%       calc = false;
%       overview = true;
%       campaign = 'EUREC4A';
%
%       assess_radiometer_data(figures, calc, overview, campaign)
%
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   June 2017; Last revision: April 2020

%------------- BEGIN CODE --------------


function assess_radiometer_data(figures, calc, overview, campaign)

% Housekeeping 
close all

%% Get dates and folder paths

% Get dates for campaign
dates = getCampaignDates(campaign);
% Set path to data
basefolder = [getPathPrefix getCampaignFolder(dates{1})];
pathRadiometer = [basefolder 'radiometer/'];
pathBahamas = [basefolder 'bahamas/'];

radiometerStrings = {'183', '11990', 'KV'};

path = cellfun(@(x) [pathRadiometer x '/'], radiometerStrings, 'uni', false);

figurepath = '/Users/heike/Documents/eurec4a/analyses/radiometer_errors/';

% If figures should be generated
if figures
    % Loop dates
    for i=1:length(dates)
        
        % Preallocate cell array
        tb = cell(length(radiometerStrings),1);
        
        % Loop radiometers
        for j=1:length(radiometerStrings)
            
            % Get file path
            filepath = listFiles([path{j} '*' dates{i}(3:end) '*'], 'full', 'mat');
            
            if ~isempty(filepath)
                % Read data
                tb{j} = ncread(filepath,'TBs');
                f{j} = ncread(filepath, 'frequencies');

                % New figure
                figure
                % Set size and position
                set(gcf,'Position',[99 427 1711 629])
                % Plot brightness temperatures
                plot(tb{j}','LineWidth',2)
                tooltipstr('%.0f')
                % Change style of x ticks
                tick2text(gca,'xformat','%.0f')
                % Axes labels
                xlabel('Index')
                ylabel('Brightness temperature (K)')
                % Set figure title
                title([dates{i} ' - ' radiometerStrings{j} ])
                
                % Add legend
                dateindexSawtooth = cellstr(num2str(f{j}));
                plotLegendAsColoredText(gca,dateindexSawtooth,[0.15 0.89],0.03)
                
                % Make pretty
                finetunefigures
                setFontSize(gcf, 18);
                
                % Save figures
%                 export_fig([figurepath dates{i} '_' radiometerStrings{j}], '-png')
            end
        end
        
        % Pause code and analyse figure
        disp('Paused. Press any key to continue')
        pause

        clear tb t
        close all
    end
end

%% Convert indices to times
if calc
    % Load error indices
    [errors, sawtooth] = radiometerErrorsLookup;
    
    % Preallocate arrays
    errorcode = cell(10,3);
    tBahamas = cell(1,3);
    
    % Create figure
    figure
    set(gcf,'Position',[-1806 41 1731 1068])

%     k = 1;
    numPlotRows = 3;

    % Loop dates
    for i=1:length(dates)
        
        % Output
        disp([num2str(i) ' - ' dates{i}])

        % Get file path
        bahamasFile = listFiles([pathBahamas '*' dates{i} '*'], 'full', 'mat');
        
        % Read bahamas time
        tBahamas{i} = unixtime2sdn(ncread(bahamasFile,'TIME'));

        % Preallocate arrays
        t = cell(3,1);
        tUse = cell(3,1);
        
        
        % Loop radiometers
        for j=1:length(radiometerStrings)
            
            % Get index of radiometer module in error cell
            ind_errorRadiometer = strcmp([errors{2,:}], radiometerStrings{j});
            % Get index of radiometer module in error cell
            ind_sawtoothRadiometer = strcmp([sawtooth{2,:}], radiometerStrings{j});
            
            % Get file path for radiometer data
            filepath = listFiles([path{j} '*' dates{i}(3:end) '*'], 'full', 'mat');
            % Preallocate
            time = cell(1,size(filepath,1));
            
            % Loop all found files
            for m=1:size(filepath,1)
                 time{m} = time2001_2sdn(double(ncread(filepath(m,:),'time')));
            end
            % Transpose to concatenate
            time = time';
            % Concatenate
            t{j} = transpose(cell2mat(time));
            
            clear time
            
            % Identify jumps in radiometer time
            ind = indRadiometerTimeJumps(t{j});
            % Set times with jumps to nan
            t{j}(ind) = nan;
            % Copy
            tUse{j} = t{j};

            % Get index of dates in error cell
            dateindexError = strcmp(errors{1,ind_errorRadiometer}(:,1),dates{i});
            
            % Initialize error code array with zeros
            errorcode{i,j} = zeros(size(t{j}));
            
            % If errors were found
            if ~cellfun(@isempty,errors{1,ind_errorRadiometer}{dateindexError,2})
                % Create array from error intervals
                index = indexFromError(errors{1,ind_errorRadiometer}{dateindexError,2});
                % if error, set to 1
                errorcode{i,j}(index) = 1;
            end
            
            % Get index of dates in sawtooth cell
            dateindexSawtooth = find(strcmp(sawtooth{1,ind_sawtoothRadiometer}(:,1),dates{i}));
            % If sawtooth was found
            if ~cellfun(@isempty,sawtooth{1,ind_sawtoothRadiometer}{dateindexSawtooth,2})
                % Create array from error intervals
                index = indexFromError(sawtooth{1,ind_sawtoothRadiometer}{dateindexSawtooth,2});
                % if saw tooth set to 2
                errorcode{i,j}(index) = 2;
            end

            
            % if before take-off or after landing, set to 3
            errorcode{i,j}(1:find(tUse{j}<tBahamas{i}(1),1,'last')) = 3;
            errorcode{i,j}(find(tUse{j}>tBahamas{i}(end),1,'first'):end) = 3;
            
            % Copy variables
            e{i,j} = errorcode{i,j};
            tPlot{i,j} = t{j};
            % Remove entries before take off or after landing
            tPlot{i,j}(e{i,j}==3) = [];
            e{i,j}(e{i,j}==3) = [];

        end
        
        % Create subplot
        subplot(numPlotRows, ceil(length(dates)/numPlotRows), i)
        
        % Plot error time lines
        plot(tPlot{i,1},e{i,1},tPlot{i,2},e{i,2},tPlot{i,3},e{i,3},...
                'LineWidth',2)
        % Add legend
        if i==length(dates)
            legend({'183','11990','KV'},'Location',[0.46 0.25 0.05 0.07])
        end
        
        % Make pretty
        finetunefigures
        set(gca,'YLim',[-0.5 2.5],'YTick',[0 1 2])
        xlabel('Time (UTC)')
        title(dates{i})
        setFontSize(gcf,14)
        datetick('x','HH')
        
        % Clear variables
        clear tBah t

    end
    
    % Add comment for numbers
    th = annotation('textbox',[0.6,0.1,0.1,0.1],...
            'String',{'0: ok';'1: error';'2: saw tooth'},'Fontsize',14,...
            'EdgeColor','none');
    
    % Save figure
    export_fig([figurepath '/radiometerErrorsAssessment' campaign],'-pdf')

    % Percentage of saw tooth pattern
    p2 = cell2mat(cellfun(@(x) round(sum(x==2)./numel(x).*100,3),e,'UniformOutput',false));
    % Percentage of errors
    p1 = cell2mat(cellfun(@(x) round(sum(x==1)./numel(x).*100,3),e,'UniformOutput',false));

    % Save data
    save([basefolder 'mat/radiometerErrorAssessment_' campaign])
else
    % Load data
    load([basefolder 'mat/radiometerErrorAssessment_' campaign], ...
        'p1', 'p2')
end



%% Plot all in one

if overview
    % Greate labels for all flights
    datelabels = [repmat('RF',length(dates),1) num2str((1:length(dates))','%02d') ...
                    repmat(', ',length(dates),1) ...
                    datestr(datenum(dates,'yyyymmdd'),'dd.mm.')];

    % New figure
    figure
    % Set size and position
    set(gcf,'Position',[23 337 1377 733])

    % Define face colors
    facecolors = [ 53, 151, 143;
                  183, 187, 194; 
                   79, 129, 189];

    % Loop all radiometers
    for i=1:length(radiometerStrings)

        % Tight plot of subfigures
        subtightplot(1,3,i,[0.01,0.02],0.1,0.08)
        % Plot horizontal bars
        bh = barh(1:length(dates),[p2(:,i) p1(:,i) 100-p2(:,i)-p1(:,i)],'stacked');

        % Loop error types
        for j=1:3
            set(bh(j),'FaceColor',facecolors(j,:)./255,'EdgeColor',[1 1 1])
        end

        % Add labels to left figure
        if i==1
            set(gca,'YTickLabel',datelabels)
        else
            set(gca,'YTickLabel',[])
        end
        % Make pretty
        finetunefigures
        setFontSize(gcf,14)
        grid off
        set(gca,'TickLength',[ 0 0 ])
        set(gca,'YDir','reverse')
        set(gca,'YLim',[0.5 length(dates)+0.5])
        xlabel('(%)')

        % Add title
        th = title(radiometerStrings(i));

        % 
        ax1 = gca;
        % Create new axes at position of first axes
        ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
        % No ticks and white lines to remove axes lines from first axes
        set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top')

        % Add legend to first plot
        if i==1
            % Legend
            lh = legend(bh,'saw tooth','errors','data');
            % Change font size
            lh.FontSize = 14;
        end

    end

    % Save figure as pdf and png
    export_fig([figurepath 'radiometerAllErrorAssessment_' campaign],'-pdf')
    export_fig([figurepath 'radiometerAllErrorAssessment_' campaign],'-png','-r600')
end

end

% Create array from error intervals
function index = indexFromError(errorCell)

% Preallocate
index = cell(1,length(errorCell));
% Loop all intervals
for k=1:length(errorCell)
    % Create array
    index{k} = errorCell{k}(1):errorCell{k}(end);
end
% Concatenate arrays
index = cell2mat(index);

end



%------------- END OF CODE --------------