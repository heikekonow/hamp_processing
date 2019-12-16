function checkfolderstructure(pathtofolder)


    checkandcreate(pathtofolder, 'all_mat')
    checkandcreate(pathtofolder, 'all_nc')
    checkandcreate(pathtofolder, 'radar_mira')
    
    checkdatafolders(pathtofolder, 'bahamas')
    checkdatafolders(pathtofolder, 'dropsonde')
    checkdatafolders(pathtofolder, 'radar')
    checkdatafolders(pathtofolder, 'radiometer')

    function checkandcreate(pathtofolder, foldername)
        if ~exist([pathtofolder foldername], 'dir')
           mkdir([pathtofolder foldername])
           disp(['Subfolder ' foldername ' did not exist... has been created.'])
        end
    end

    function checkdatafolders(pathtofolder, foldername)
        if ~exist([pathtofolder foldername], 'dir')
            mkdir([pathtofolder foldername])
            disp(['Subfolder ' foldername ' did not exist... has been created. Don''t forget to add data.'])
        elseif isempty(dir2([pathtofolder 'radar_mira']))
            error(['Subfolder ' foldername ' is empty... Don''t forget to add data.'])
        end
    end

end