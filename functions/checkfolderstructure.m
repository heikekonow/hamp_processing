function checkfolderstructure(pathPrefix, flightdates_use)
    
    pathtofolder = [pathPrefix, getCampaignFolder(flightdates_use)];

    checkandcreate(pathtofolder, 'all_mat')
    checkandcreate(pathtofolder, 'all_nc')
    checkandcreate(pathtofolder, 'radar_mira')
    
    checkdatafolders(pathtofolder, 'bahamas')
    checkdatafolders(pathtofolder, 'dropsonde')
    checkdatafolders(pathtofolder, 'radar')
    checkdatafolders(pathtofolder, 'radiometer')
    checkdatafolders([pathtofolder 'radiometer/'], '183')
    checkdatafolders([pathtofolder 'radiometer/'], '11990')
    checkdatafolders([pathtofolder 'radiometer/'], 'KV')
    

    %% Functions

    function checkandcreate(pathtofolder, foldername)
        if ~exist([pathtofolder foldername], 'dir')
           mkdir([pathtofolder foldername])
           disp(['Subfolder ' foldername ' did not exist... has been created.'])
        end
    end

    function checkdatafolders(foldertocheck, foldername)
        if ~exist([foldertocheck foldername], 'dir')
            mkdir([foldertocheck foldername])
            disp(['Subfolder ' foldername ' did not exist... has been created. Don''t forget to add data.'])
        elseif isempty(dir2([foldertocheck foldername]))
            error(['Subfolder ' foldername ' is empty... Don''t forget to add data.'])
        end
    end

end