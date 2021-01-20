function run_removeRadiometerErrors(version, subversion, flightdates_use, varargin)

%   varargin:   set to 'testfig' to generate figures to control the resulting
%               data
%

% Generate version string
dataversion = [num2str(version) '.' num2str(subversion)];

% Loop all dates
for i=1:length(flightdates_use)
    
    % Display date
    disp(flightdates_use{i})
    
    % Get base folder path for data
    pathtofolder = [getPathPrefix getCampaignFolder(flightdates_use{i})];

    % Look for radiometer data file from which the errors should be removed
    datafile = listFiles([pathtofolder 'all_nc/*radiometer*' flightdates_use{i} '*' ...
                          dataversion '*'], 'full', 'mat');
	
	% If more than one file was found, return error
    if size(datafile, 1)>1
        error(['More than one radiometer data file found for current version (v' ...
                dataversion '). Please check and remove unneccesary files.']) 
    end
    
    % Remove errors in brightness temperatures
    [tb, ~] = removeTBErrors(flightdates_use{i}, dataversion);
    
    % Write new brightness temperatures to file
    ncwrite(datafile, 'tb', tb)
    
    % If figures should be created
    if ~isempty(varargin) && strcmp(varargin, 'testfig')
        
        % Read data
        t = ncread(datafile, 'time');
        f = ncread(datafile, 'frequency');
        
        % Create figure
        figure
        set(gcf, 'Position', [499 57 1048 918])
        
        % Plot brightness temperatures
        subplot(3,1,1)
        plot(t, tb(f>=180, :))
        finetunefigures
        title('180')
        
        subplot(3,1,2)
        plot(t, tb(f>=90 & f<180, :))
        finetunefigures
        title('119/90')
        
        subplot(3,1,3)
        plot(t, tb(f<90, :))
        finetunefigures
        title('KV')
        
    end

end