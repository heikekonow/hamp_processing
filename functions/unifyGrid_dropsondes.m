function unifyGrid_dropsondes(pathtofolder,flightdate,uniHeight,uniTime,uniData,sondeVars)

interpolate = 1;

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
    
    % Select Dropsonde variables to consider
%     sondeVars = {'pres','tdry','dp','rh','u_wind','v_wind','wspd','wdir','dz',...
%                  'mr','vt','theta','theta_e','theta_v','lat','lon'};
    
    % Preallocate arrays
    uniDataDropsonde = uniData;
    uniDataDropsonde_inst = uniData;
    
    % Loop dropsonde variables
    for i=1:length(sondeVars)
        disp(sondeVars{i})
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
%             disp(num2str(j))
                    
            % Interpolate data if desired
            if interpolate
                % Use function as before, but keep in mind that with
                % profiles, height is "time"
%                 if j==6 && i==2 %&& j==24
%                     disp(num2str(j))
%                 end
                if sum(isnan(data{j})) <= length(data{j})-2
                     [~,index]=unique(sondeHeightForInterp{j});
                     index=setdiff(1:length(data{j}),index);
                     data{j}(index)=NaN;
                     dataInt{j} = interpolateData(sondeHeightForInterp{j},data{j},10);
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
                end
            end
            if sum(isnan(uniDataDropsonde_inst(:,indTimeUni_inst{j})))==length(uniHeight)
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
        
        longNameTemp_inst = [longNameTemp ', instantaneous drop'];
        longNameTemp_sondes = [longNameTemp ', single sondes'];
        
        extra_info(end+1,:) = {sondeVars{i},unitsTemp,longNameTemp,['uniSonde' sondeVars{i}]};
        extra_info(end+1,:) = {[sondeVars{i} '_inst'],unitsTemp,longNameTemp_inst,['uniSonde' sondeVars{i} '_inst']};
        extra_info(end+1,:) = {[sondeVars{i} '_sondes'],unitsTemp,longNameTemp_sondes,['uniSonde' sondeVars{i} '_sondes']};
        
        % Reduce variable data to only sondes
        uniDataDropsonde_sondes = uniDataDropsonde_inst(:,...
                sum(isnan(uniDataDropsonde_inst),1)~=length(uniHeight));
            
        % If sonde file with only nans exist, reproduce this
        if size(uniDataDropsonde_sondes,2)<length(filename)
            nanSondeNumber = nanSondeNumber(nanSondeNumber~=0);
            tmp = nan(length(uniHeight),length(filename));
            index=setdiff(1:length(filename),nanSondeNumber);
            tmp(:,index)=uniDataDropsonde_sondes(:,:);
            
%             l = 1;
%             
%             tmp(:,1:nanSondeNumber(l)-1) = ...
%                 uniDataDropsonde_sondes(:,1:nanSondeNumber(l)-1);
%             
%             if length(nanSondeNumber)>1
%                 for l=nanSondeNumber(2):length(nanSondeNumber)                  
%                     tmp(:,nanSondeNumber(l-1)+1:nanSondeNumber(l)-1) = ...
%                 uniDataDropsonde_sondes(:,nanSondeNumber(l-1):nanSondeNumber(l)-1);
%                 end
%             end
%             
%             tmp(:,nanSondeNumber(l)+1:end) = ...
%                 uniDataDropsonde_sondes(:,nanSondeNumber(l):end);
            
            clear uniDataDropsonde_sondes
            uniDataDropsonde_sondes = tmp;
            clear tmp
        end
            
        % Rename variables
        eval(['uniSonde' sondeVars{i} ' = uniDataDropsonde;'])
        eval(['uniSonde' sondeVars{i} '_inst = uniDataDropsonde_inst;'])
        eval(['uniSonde' sondeVars{i} '_sondes = uniDataDropsonde_sondes;'])
        % Preallocate new arrays
        uniDataDropsonde = uniData;
        %%% Muss hier nicht auch die zweite Variable neu allociert werden??
        % uniDataDropsonde_inst = uniData;
    end
    
    uniSondeNumber = 1:size(uniDataDropsonde_sondes,2);
    extra_info(end+1,:) = {'uniSondeNumber','','Dropsonde number','uniSondeNumber'};
    extra_info(end+1,:) = {'uniSondeLaunchTime','seconds since 1970-01-01 00:00:00 UTC','Dropsonde launch time','uniSondeLaunchTime'};
    
%     % If test figures should be plotted
%     if testPlots
%         % Set path to second dropsonde file
%         filepath = [pathtofolder 'dropsonde/' filename{2}];
%         % read data
%         sondeT = ncread(filepath,'tdry');
%         sondeHeight = ncread(filepath,'gpsalt');
%         sondeT(isnan(sondeHeight)) = [];
%         sondeTime = ncread(filepath,'time');
%         sondeTime = unixtime2sdn(sondeTime);
%         sondeTime(isnan(sondeHeight)) = [];
%         sondeHeight(isnan(sondeHeight)) = [];
%         
%         uniT = uniSondetdry_inst(:,uniTime==sondeTime(end));
% 
%         if isempty(uniT)
%             absDiff = abs(uniTime-sondeTime(end));
%             indMin = find(absDiff==min(absDiff));
%             uniT = uniSondetdry_inst(:,indMin);
%         end
% 
%         % plot test figure
%         figure
%         set(gcf,'Position',[1922 181 618 938])
%         subplot(2,1,1)
%         plot(sondeT,sondeHeight)
%         ylabel('Height')
%         xlabel('T')
%         finetunefigures
%         subplot(2,1,2)
%         plot(uniT,uniHeight)
%         ylabel('Height')
%         xlabel('T')
%         finetunefigures
%     end

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
save(outfile,'uni*','flightdate','extra_info')%, 'sondeTime')


