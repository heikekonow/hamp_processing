%% checkfolderstructure
%   checkfolderstructure - check if neccessary folder structure for
%           processing exits, otherwise create folders
%       
%
%   Syntax:  checkfolderstructure(pathPrefix, flightdates_use)
%
%   Inputs:
%       pathPrefix      - base folder of data directories
%       flightdates_use - flight dates to process, this is neccessary for
%                         campaign folder name
%
%   Outputs:
%       none; directories created in base folder
%
%   Example:
%
%       checkfolderstructure('/Users/heike/Documents/eurec4a/data_processing/',...
%                               {'20200119', '20200122'})
%
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   April 2020; Last revision:

function checkfolderstructure(pathPrefix, flightdates_use)
    
    % Concatenate folder path
    pathtofolder = [pathPrefix, getCampaignFolder(flightdates_use)];
    
    % Check if neccessary folders exist, otherwise create
    checkandcreate(pathtofolder, 'all_mat')
    checkandcreate(pathtofolder, 'all_nc')
    checkandcreate(pathtofolder, 'radar_mira')
    
    % Check if neccessary folders exist, otherwise create, and check if
    % there is data inside data folders
    checkdatafolders(pathtofolder, 'bahamas')
    checkdatafolders(pathtofolder, 'dropsonde')
    checkdatafolders(pathtofolder, 'radar')
    checkdatafolders(pathtofolder, 'radiometer')
    checkdatafolders([pathtofolder 'radiometer/'], '183')
    checkdatafolders([pathtofolder 'radiometer/'], '11990')
    checkdatafolders([pathtofolder 'radiometer/'], 'KV')
    

    %% Functions
    
    % Function to check if folder exists and create if it's missing
    function checkandcreate(pathtofolder, foldername)
        if ~exist([pathtofolder foldername], 'dir')
           mkdir([pathtofolder foldername])
           disp(['Subfolder ' foldername ' did not exist... has been created.'])
        end
    end
    
    % Function to check if folder exists, otherwise create, and check if
    % data is inside folder
    function checkdatafolders(foldertocheck, foldername)
        if ~exist([foldertocheck foldername], 'dir')
            mkdir([foldertocheck foldername])
            disp(['Subfolder ' foldername ' did not exist... has been created. Don''t forget to add data.'])
        elseif isempty(dir2([foldertocheck foldername]))
            error(['Subfolder ' foldername ' is empty... Don''t forget to add data.'])
        end
    end

end