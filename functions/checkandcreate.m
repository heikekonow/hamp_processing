function checkandcreate(pathtofolder, foldername)
    
    % Check if folder exists
    if ~exist([pathtofolder foldername], 'dir')
        % Create missing folder
        mkdir([pathtofolder foldername])
        disp(['Subfolder ' foldername ' did not exist... has been created.'])
    end
end