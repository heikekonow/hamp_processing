function time2EUREC4Atime(version, subversion, flightdates_use)

% number of days between 1970 and 2020
daysbetween = daysact('01-01-1970', '01-01-2020');
% number of seconds between 1970 and 2020
secondsbetween = daysbetween .* 24 .* 60 .* 60;
            
for i=1:length(flightdates_use)
    
    % List all files with version and subversion
    files = listFiles([getPathPrefix ...
                       getCampaignFolder(flightdates_use{i}) ...
                       'all_nc/*' flightdates_use{i} '*' num2str(version) '*' num2str(subversion) '*.nc'], 'full');
    
   for j=1:length(files)
        t = ncread(files{j}, 'time');
        
        if t(1)>1e9 % time is most likely epoch time (seconds since 1-1-1970)
            
            % Subtract seconds interval from unixtime
            tEurec = t - secondsbetween;
            
        else 
            error('Unexpected time format')
        end
        
        % Replace time in file
        ncwrite(files{j}, 'time', tEurec)
        % Replace time units attribute
        ncwriteatt(files{j}, 'time', 'units', 'seconds since 2020-01-01 00:00:00 UTC')
   end
end

