function [varnames,ncdims,data,extra_info] = prepareMat2NetCDF(matfile)
% Clear workspace
% % clear
load(matfile)

clear matfile

% Get info about all variables
a = whos;

% List variables that are dimensions
dimensions = {'uniTime','uniHeight','uniRadiometer11990_freq',...
              'uniRadiometer183_freq','uniRadiometerKV_freq',...
              'uniSondeNumber','uniRadiometer_freq'};
          
% Write variable names to variable
varnames = {a.name}';
% Write variable sizes to variable
sizes = {a.size}';

% dimensions_tmp = dimensions;

% Loop all dimensions, listed above
for i=1:length(dimensions)
    % Find index of curent dimension
    ind = strcmp(dimensions{i},varnames);
    if sum(ind)~=0 % dimension is in this dataset
        % Get size of current dimension
        dim_size(i) = sizes(ind);
        % Delete size info about current dimension
        sizes(ind) = [];
        % Delete variable name of current dimension
        varnames(ind) = [];
    else % dimension is not in this dataset
        dimensions{strcmp(dimensions,dimensions{i})} = [];
    end
end

% Delete empty cells in dimension names ...
dimensions(cellfun(@isempty,dimensions)) = [];
% ... and dimension sizes
dim_size(cellfun(@isempty,dim_size)) = [];

% Delete size information of variable 'extra_info'
sizes(strcmp(varnames,'extra_info')) = [];
% Delete variable name of variable 'extra_info'
varnames(strcmp(varnames,'extra_info')) = [];
% Delete size information of variable 'corrCommentString'
sizes(strcmp(varnames,'corrCommentString')) = [];
% Delete variable name of variable 'corrCommentString'
varnames(strcmp(varnames,'corrCommentString')) = [];

% Concatenate dimension sizes and variable size 
% Here, just the order is changed so that the dimensions will be written
% first into the netcdf file
sizes = [dim_size';sizes];
% Write size information in matrix
dim_size = cell2mat(dim_size');
% Concatenate dimension and variable names
varnames = [dimensions';varnames];

% Loop all variables (including dimensions)
for i=1:length(varnames)
    % Get size of current variable
    varsize = sizes{i}(sizes{i}~=1);
    % Test if variable is character array
    test = eval(['ischar(' varnames{i} ')']);
    % Loop all variable dimensions (i.e. 1D for vectors, 2D for matrices)
    for j=1:length(varsize)
        % Find corresponding dimension for variable
        % If variable size corresponds to one of the dimension sizes
        if ismember(varsize(j),dim_size) && ~test
            % Find index of corresponding dimension
            ind_dim = find(sum(dim_size==varsize(j)==1,2));
            % Get dimension length
            disp([num2str(i) ',' num2str(j) ' ' varnames{i}])
            % If more than one dimension has this length (i.e. sonde
            % numnber and radiometer frequency)
            if length(ind_dim)>1
                % If variable is a dimension
                if ismember(varnames{i},dimensions)
                    % Identify variable index
                    ind_dim = find(strcmp(varnames{i},dimensions));
                    % Get dimension length
                    dimLength = dim_size(ind_dim,dim_size(ind_dim,:)~=1);
                % If variable is ordinary variable
                else
                    % Check length of variable's other dimension
                    otherdimlength = varsize(varsize~=varsize(j));
                    % If other dimension is 1
                    if isempty(otherdimlength)
                        otherdimlength = sizes{i}(sizes{i}~=varsize(j));
                    end
                    % If variable is time series -> radiometer measurement
                    if otherdimlength == length(uniTime)
                        foundcell = strfind(dimensions(ind_dim),'Radiometer');
                        % Identify variable index
                        ind_dim = ind_dim(cellfun(@(x) ~isempty(x),foundcell));
                        % Get dimension length
                        dimLength = dim_size(ind_dim,dim_size(ind_dim,:)~=1);
                    elseif otherdimlength == length(uniHeight)
                        foundcell = strfind(dimensions(ind_dim),'Sonde');
                        % Identify variable index
                        ind_dim = ind_dim(cellfun(@(x) ~isempty(x),foundcell));
                        % Get dimension length
                        dimLength = dim_size(ind_dim,dim_size(ind_dim,:)~=1);
                    elseif otherdimlength == 1
                        foundcell = strfind(dimensions(ind_dim),'Sonde');
                        % Identify variable index
                        ind_dim = ind_dim(cellfun(@(x) ~isempty(x),foundcell));
                        % Get dimension length
                        dimLength = dim_size(ind_dim,dim_size(ind_dim,:)~=1);
                    end
                end
            else
                % Get dimension length
                dimLength = dim_size(ind_dim,dim_size(ind_dim,:)~=1);
            end
            % Write information pair to variable, i.e. {'uniTime',[38290]}
            ncdims_tmp{1,j} = {dimensions{ind_dim},dimLength};
            
        % Else, if variable is character array, i.e. flightdate
        elseif test
            % Convert string to numbers
            eval([varnames{i} ' = str2num(' varnames{i} ');'])
            % Set dimension to 1
            ncdims_tmp{1} = 1;
        end
    end
    % If variable 'ncdims_tmp' exists
    if exist('ncdims_tmp','var')
        % Add dimension 1 to dimensions
        ncdims{i,:} = [ncdims_tmp{:}];
        clear ncdims_tmp
    end
    % Write data into cell array
    eval(['data{i} = ' varnames{i} ';'])
end
