%% unifyGrid_dropsondes
%   unifyGrid_dropsondes - Transfer dropsonde data to uniform grid
%   Read the data from original data files and do some quality checks
%   (remove increasing height, remove spikes), interpolate data gaps. The
%   checked data is then transfered to the uniform grid and some extra
%   information is saved to be used later for netCDF file generation.
%
%   In general, three types of data are created (with rh as example):
%       - uniSonderh:       a height time matrix with measurements filled at the
%                           exact time/height point as they occured
%       - uniSonderh_inst:  a height time matrix with measurements filled
%                           the height they occured but with an assumed
%                           instantaneous drop, i.e. entire profile with
%                           only one time stamp)
%       - uniSonderh_sondes:  a matrix with height/sonde_number dimensions;
%                           all sondes on the uniform height grid but
%                           directly in succession
%
%   In addition, an interpolation flag is added for each variable. This has
%   the suffix _intFlag.
%
%   Syntax:  unifyGrid_dropsondes(pathtofolder,flightdate,uniHeight,uniTime,uniData,sondeVars)
%
%   Inputs:
%       pathtofolder -  Path to base data folder
%       flightdate -    string yyyymmdd for data to be converted
%       uniHeigh -      array for uniform height grid
%       uniTime -       array for uniform time grid
%       uniData -       matrix with uniform time/height grid
%       sondeVars -     list of dropsonde variable names to convert
%
%   Outputs:
%       none; data is saved in [pathtofolder 'all_mat/uniData_dropsondes' flightdate '.mat']
%
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   June 2017; Last revision: April 2020

%------------- BEGIN CODE --------------

function unifyGrid_dropsondes(pathtofolder,flightdate,uniHeight,uniTime,uniData,sondeVars)

% For debugging: set testPlots to true to check interpolated and original
% temperature profile from sonde number f
testPlots = false;
f = 2;

% No need to change this unless there are problems with interpolation
interpolate = true;


% Set path to output file
outfile = [pathtofolder 'all_mat/uniData_dropsondes' flightdate '.mat'];

% If output file already exists, delete it
if exist(outfile,'file')
    delete(outfile)
end

extra_info = cell(1,4);


%% Dropsonde data

% List files from specified date
filename = listFiles([pathtofolder 'dropsonde/*' flightdate '*']);

% Loop dropsonde files found
for j=1:length(filename)
    % Set path to file
    filepath = [pathtofolder 'dropsonde/' filename{j}];
    
    % Output
    disp(num2str(j))
    
    % Read time and height
    sondeTime = ncread(filepath,'time');
    % Check if time variable only contains seconds since ...
    if sondeTime(1) < sdn2unixtime(datenum(2000,1,1))
        % Get launch time from file name
        launchTimeString = filename{j}(2:16);
        launchTime = datenum(launchTimeString, 'yyyymmdd_HHMMSS');
        
        sondeTime = launchTime + 1/24/60/60 .* sondeTime;
    else
        sondeTime = unixtime2sdn(sondeTime);
    end
    sondeHeight = ncread(filepath,'gpsalt');
    
    % Flip data so that time is increasing
    sondeTime = flipud(sondeTime);
    sondeHeight = flipud(sondeHeight);
    
    % Find indices of nan entries
    nanIndex_tmp = isnan(sondeHeight);
    % Copy height variable for height decrease check
    sondeHeightCpy = sondeHeight;
    sondeHeightCpy(nanIndex_tmp) = [];
    
    % Remove instances with height increase during drop
    sondeHeight = removeHeightIncrease(sondeHeight);
    
    % Find indices of nan entries
    nanIndex{j} = isnan(sondeHeight);
    % Delete nan entries
    sondeHeight(nanIndex{j}) = [];
    sondeTime(nanIndex{j}) = [];
    
    % If data should be interpolated, save height data to variable
    if interpolate
        sondeHeightForInterp{j} = sondeHeight;
    end
    
    % Write launch time to variable
    uniSondeLaunchTime(j) = sdn2unixtime(sondeTime(1));
        
    % Get indices for dropsonde and unified time
    [indTimeUni{j},indHeightUni{j},indSonde{j}] = get_indHeightTimeDropsonde(uniTime,uniHeight,sondeTime,sondeHeight);
    % Get indices for dropsonde and unified height
    [indTimeUni_inst{j},indHeightUni_inst{j},indSonde_inst{j}] = ...
                                         get_indHeightTimeDropsonde(uniTime,uniHeight,sondeTime,sondeHeight,'notime');
end

% If dropsondes were released
if ~isempty(filename)
    
    
    % Loop dropsonde variables
    for i=1:length(sondeVars)
        disp(sondeVars{i})
        
         % Preallocate arrays
        uniDataDropsonde = uniData;
        uniDataDropsonde_inst = uniData;
        interpolateMat = zeros(size(uniData));
    
        nanSondeNumber=zeros(1,length(filename));
        % Loop dropsonde files
        for j=1:length(filename)
            % Set path to file
            filepath = [pathtofolder 'dropsonde/' filename{j}];
  
            % Read data
            data{j} = ncread(filepath,sondeVars{i});

            % Flip data so that time is increasing
            data{j} = flipud(data{j});

            % Delete nan height entries
            data{j}(nanIndex{j}) = [];
            
            % Delete spikes in data
            data{j} = filterSpikes(data{j});
            
            % Delete first value in profile (is either nan or unplausible
            % value, i.e. 99)
            data{j}(1) = nan;
                    
            % Interpolate data if desired
            if interpolate
                % Use function as before, but keep in mind that with
                % profiles, height is "time"
                if sum(isnan(data{j})) <= length(data{j})-2
                    
                    % Get indices of dropsonde height values
                     [~, index, ~] = unique(sondeHeightForInterp{j});
                     
                     % Look for missing dropsonde index values in
                     % comparison to general height array
                     index = setdiff(1:length(data{j}),index);
                     
                     % Set data at missing heights to nan
                     data{j}(index) = NaN;
                     
                     % Interplate profile data
                     [dataInt{j}, interpolate_flag{j}] = ...
                         interpolateData(sondeHeightForInterp{j},data{j},10);
                     data{j} = dataInt{j};
                end
            end

            % Transfer data onto unified grid at time according to times of
            % individual data points (i.e. not the same time for all
            % measurements of one dropsonde)
            for k=1:length(indSonde{j})
                uniDataDropsonde(indHeightUni{j}(k),indTimeUni{j}(k)) = data{j}(indSonde{j}(k));
            end
            
            % Transfer data onto unified grid at time according to  start
            % time of dropsonde (i.e. the same time for all measurements 
            % of one dropsonde)
            for k=1:length(indSonde_inst{j})
                if ~isnan(indHeightUni_inst{j}(k)) && ~isnan(indSonde_inst{j}(k))
                    uniDataDropsonde_inst(indHeightUni_inst{j}(k),indTimeUni_inst{j}) = data{j}(indSonde_inst{j}(k));
                    
                    interpolateMat(indHeightUni_inst{j}(k),indTimeUni_inst{j}) = ...
                        interpolate_flag{j}(indSonde_inst{j}(k));
                end
            end
            
            % Check if entire sonde profile is filled with nans
            if sum(isnan(uniDataDropsonde_inst(:,indTimeUni_inst{j})))==length(uniHeight)
                % Add current sonde number to nan sonde index
                nanSondeNumber(j) = j;
            end
        end
        
        % Read units and long name
        unitsTemp = ncreadatt(filepath,sondeVars{i},'units');
        % If variable is sonde time, add string 'sonde' to discrimitate
        % from time array
        if strcmp(sondeVars{i}, 'time')
            longNameTemp = ['sonde ' ncreadatt(filepath,sondeVars{i},'long_name')];
            sondeVars{i} = 'sonde_time';
        else
            longNameTemp = ncreadatt(filepath,sondeVars{i},'long_name');
        end
        
        % Add long name information
        longNameTemp_inst = [longNameTemp ', instantaneous drop'];
        longNameTemp_sondes = [longNameTemp ', single sondes'];
        
        % Write variable information
        extra_info(end+1,:) = {sondeVars{i},unitsTemp,longNameTemp,['uniSonde' sondeVars{i}]};
        extra_info(end+1,:) = {[sondeVars{i} '_inst'],unitsTemp,longNameTemp_inst,['uniSonde' sondeVars{i} '_inst']};
        extra_info(end+1,:) = {[sondeVars{i} '_sondes'],unitsTemp,longNameTemp_sondes,['uniSonde' sondeVars{i} '_sondes']};
        extra_info(end+1,:) = {[sondeVars{i} '_intFlag'],'',[longNameTemp '; interpolation flag'],['uniSonde' sondeVars{i} '_interpolateFlag']};
        
        % Reduce variable data to only sondes
        uniDataDropsonde_sondes = uniDataDropsonde_inst(:,...
                sum(isnan(uniDataDropsonde_inst),1)~=length(uniHeight));
            
        uniDataDropsonde_flag = interpolateMat(:,...
                sum(isnan(uniDataDropsonde_inst),1)~=length(uniHeight));
            
        % If sonde file with only nans exist, reproduce this
        if size(uniDataDropsonde_sondes,2)<length(filename)
            nanSondeNumber = nanSondeNumber(nanSondeNumber~=0);
            tmp = nan(length(uniHeight),length(filename));
            index=setdiff(1:length(filename),nanSondeNumber);
            tmp(:,index)=uniDataDropsonde_sondes(:,:);
            
            % Fill with empty profile
            clear uniDataDropsonde_sondes
            uniDataDropsonde_sondes = tmp;
            clear tmp
        end
            
        % Rename variables
        eval(['uniSonde' sondeVars{i} ' = uniDataDropsonde;'])
        eval(['uniSonde' sondeVars{i} '_inst = uniDataDropsonde_inst;'])
        eval(['uniSonde' sondeVars{i} '_sondes = uniDataDropsonde_sondes;'])
        eval(['uniSonde' sondeVars{i} '_intFlag = uniDataDropsonde_flag;'])

    end
    
    % Generate sonde number array
    uniSondeNumber = 1:size(uniDataDropsonde_sondes,2);
    % Write variable information
    extra_info(end+1,:) = {'uniSondeNumber','','Dropsonde number','uniSondeNumber'};
    extra_info(end+1,:) = {'uniSondeLaunchTime','seconds since 1970-01-01 00:00:00 UTC','Dropsonde launch time','uniSondeLaunchTime'};
    
    % If test figures should be plotted
    if testPlots
        
        % Call plotting function
        plotFigure(pathtofolder, f)
    end
    
    % Clear variables
    clear indTimeUni indHeightUni indSonde uniT
end


%%
extra_info(end+1,:) = {'flightdate','','Date of flight','flightdate'};
extra_info(end+1,:) = {'time','seconds since 1970-01-01 00:00:00 UTC','time','uniTime'};
extra_info(end+1,:) = {'height','m','height','uniHeight'};

%% Save data

disp('Saving')
disp(' ')
% Delete first entry from extra_info cell
extra_info(1,:) = [];

% Clear universal arrays
clear uniData uniDataDropsonde uniDataDropsonde_inst unitsTemp uniDataDropsonde_sondes 

% Save data to file
save(outfile,'uni*','flightdate','extra_info')
end

function plotFigure(f)

    % Set path to f-th dropsonde file
        filepath = [pathtofolder 'dropsonde/' filename{f}];
        % read data
        sondeT = ncread(filepath,'tdry');
        sondeHeight = ncread(filepath,'gpsalt');
        sondeT(isnan(sondeHeight)) = [];
        sondeTime = ncread(filepath,'time');
        
        % Change time format if necessary
        if sondeTime(1) < sdn2unixtime(datenum(2000,1,1))
            % Get launch time from file name
            launchTimeString = filename{f}(2:16);
            launchTime = datenum(launchTimeString, 'yyyymmdd_HHMMSS');

            sondeTime = launchTime + 1/24/60/60 .* sondeTime;
        else
            sondeTime = unixtime2sdn(sondeTime);
        end
        
        % Delete nan entries
        sondeTime(isnan(sondeHeight)) = [];
        sondeHeight(isnan(sondeHeight)) = [];
        
        % Copy variable
        uniT = uniSondetdry_sondes(:,f);
        
        % If variable is empty
        if isempty(uniT)
            
            % Look for profile closest in time
            absDiff = abs(uniTime-sondeTime(end));
            indMin = find(absDiff==min(absDiff));
            uniT = uniSondetdry_inst(:,indMin);
        end

        % plot test figure
        figure
        set(gcf,'Position',[1922 181 618 938])
        % Subfigure 1
        subplot(2,1,1)
        plot(sondeT,sondeHeight)
        ylabel('Height')
        xlabel('T')
        finetunefigures
        % Subfigure 2
        subplot(2,1,2)
        plot(uniT,uniHeight)
        ylabel('Height')
        xlabel('T')
        finetunefigures
end

%------------- END OF CODE --------------