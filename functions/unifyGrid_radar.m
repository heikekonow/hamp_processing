function unifyGrid_radar(pathtofolder,flightdate,uniHeight,uniTime,radarVars)

% Set path to output file
outfile = [pathtofolder 'all_mat/uniData_radar' flightdate '.mat'];

% Create empty variable according to unified grid
uniData = nan(length(uniHeight),length(uniTime));

extra_info = cell(1,4);

%% Radar data

% Select Radar variables to consider
% radarVars = {'dBZg','Zg','LDRg','RMSg','VELg','SNRg'};
% List files from specified date
filename = listFiles([pathtofolder 'radar_mira/mira*' flightdate '*']);

% Skip this step if no radar data is available
if ~isempty(filename)
    
    vNum = cell2mat(cellfun(@(x) str2double(get_versionNumber(x)),filename,'UniformOutput',false));
    indFile = find(vNum==max(vNum));
    
    % Loop all variables
    for i=1:length(radarVars)
        
        % Display variable info
        disp(radarVars{i})
        
        for j=1:length(indFile)
            
            % Set full path to file; set {end} to use latest radar file version
            filepath = [pathtofolder 'radar_mira/' filename{indFile(j)}];
            
            if i==1 % Only need to do this for one variable
                % Read time
                radarTime{j} = ncread(filepath,'time');
                % Convert to sdn
                radarTime{j} = unixtime2sdn(radarTime{j});
                % Read height
                radarHeight{j} = double(ncread(filepath,'height'));
                % Read radar status
                if ncVarInFile(filepath,'grst')
                    radarState{j} = ncread(filepath,'grst');
                end

               
            end

            % Read radar data data
            data{j} = ncread(filepath,radarVars{i});

            % Discard data where radar state was not 13; i.e. local oscillator
            % not locked and/or radiation off
            if exist('radarState','var')
                data{j}(:,radarState{j}~=13) = nan;
            end
        end
                
        % Convert cells to matrices
        data = [data{:}]; 
        
        if i==1
            radarHeight = [radarHeight{:}]; 
            radarTime = radarTime';
            radarTime = transpose(cell2mat(radarTime));
        
            % Check if all heights are the same
            if sum(sum(diff(radarHeight,1,2)))==0
                % Only keep first column
                radarHeight = radarHeight(:,1);
            else
                error('Check radar heights')
            end
        
            % Get index for height information
            indHeight = get_indHeight(uniHeight,radarHeight);
            % Get index for time information
            indTime = get_indTime(uniTime,radarTime);
            
            % Round time to seconds to avoid numerical deviations
            radarTime = dateround(radarTime', 'second');
        end
        
        

        % Combine data from different files
        eval(['uni' radarVars{i} ' = transferData(uniData,data,indHeight,indTime);'])

        % Clean up
        clear data
        
        % Read units and long name
        unitsTemp = ncreadatt(filepath,radarVars{i},'units');
        longNameTemp = ncreadatt(filepath,radarVars{i},'long_name');
        extra_info(end+1,:) = {radarVars{i},unitsTemp,longNameTemp,['uni' radarVars{i}]};
    end


end
%%
extra_info(end+1,:) = {'flightdate','','Date of flight','flightdate'};
extra_info(end+1,:) = {'time','seconds since 1970-01-01 00:00:00 UTC','time','uniTime'};
extra_info(end+1,:) = {'height','m','height','uniHeight'};

%% Save data

% Delete first entry from extra_info cell
extra_info(1,:) = [];

% Clear universal arrays
clear uniData unitsTemp 

% If output file already exists, delete it
if exist(outfile,'file')
    delete(outfile)
end

% Save data to file
save(outfile,'uni*','flightdate','extra_info')
end

function vNum = get_versionNumber(filename)

ind = regexp(filename,'_v');

vNum = filename(ind+2:ind+4);

end
