function varargout = read_smart_ascii(filename, varargin)

% filename = '/Users/heike/Documents/eurec4a/data/20190517/NavCommand_Horidata/Nav_GPSPos0000.Asc';
% filename = '/Users/heike/Documents/eurec4a/data/20190517/NavCommand_Horidata/Nav_IMS0000.Asc';
fid = fopen(filename);

%% Read Header
% Read header while first character is #

readLine = true;

l = 1;

varnames = cell(2,1);
unit = cell(2,1);
equation = cell(2,1);

i = 1;

while readLine
    
    line = fgetl(fid);
    
    disp(line)
    
    if ~isempty(line) && strcmp(line(1), '#')
        readLine = true;
        
        if strcmp(line(3:9), 'Started')
            slashpos = regexp(line, '/');
            colonpos = regexp(line, ':');
            
            startdate = line(slashpos(1)-2:slashpos(2)+4);
            startdate_dt = datetime(startdate, 'InputFormat', 'MM/dd/yyyy');
        end
        % Analyse column information
        if strcmp(line(3:8), 'Column')
            colonpos = regexp(line, ':');
            commapos = regexp(line, ',');
            brackpos = regexp(line, '[\[\]]');
            equpos = regexp(line, 'Col = ');
            
            if length(commapos) > 1
            
                varnames{l} = line(commapos(1)+1:commapos(2)-1);
                unit{l} = line(brackpos(1)+1:brackpos(2)-1);
                equation{l} = line(equpos(1)+6:commapos(end)-1);
                
            else
                varnames{l} = line(colonpos(1)+1:commapos(1)-1);
                unit{l} = '';
                equation{l} = '';
            end
            
            l = l+1;
        end
        
    else
        readLine = false;
    end
    
    i = i+1;
end

% fclose(fid);
%% Manipulate strings

varnames = cellfun(@(x) strtrim(x), varnames, 'uni', 0);
unit = cellfun(@(x) strtrim(x), unit, 'uni', 0);
equation = cellfun(@(x) strtrim(x), equation, 'uni', 0);

%% Read Data

% specify format
f = '%30.15f';

% data = textscan(fid, '%4d %10.4f %14.10f %14.10f %9.4f %5.3f %5.3f %5.3f');
data = textscan(fid, repmat(f, 1, length(varnames)) );
fclose(fid);

%% Write variables

for i=1:length(varnames)
    eval([varnames{i} ' = data{i};'])
end

%% Convert time

time = TIntrplEx;

startdate_arr = repmat(datenum(startdate_dt), length(time), 1);
time = startdate_arr + time/24/60/60;

%% Save output variables

for i=1:nargout
    eval(['varargout{i} = ' varargin{i} ';'])
end
