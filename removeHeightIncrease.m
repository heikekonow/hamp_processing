function height_purged = removeHeightIncrease(height_orig)
    
    % If height does not decrease continually, delete values in
    % beginning of profile (close to aircraft). Height allocation
    % is not reliable in these cases.
    %
    % Set number of height levels from start that can be deleted
    nfirst = 20;
    
    % Copy variable
    height_purged = height_orig;
    % Find indices of non-nan heights
    ind_nonNanHeights = find(~isnan(height_orig));
    % Calculate differences between neighboring values
    heightDiffs = diff(height_orig(~isnan(height_orig)));
    % Find height increases
    ind_heightIncrease = find(heightDiffs>=0);
    
    % If all height increases are below first 'nfirst' values > problem, deal
    % with that later :-)
    if ~isempty(ind_heightIncrease) && ...
                sum(ind_heightIncrease>nfirst)==numel(ind_heightIncrease)
%         error('Problem with dropsonde height...')
        height_purged(ind_nonNanHeights((ind_heightIncrease)+1)) = nan;
    % If only some or all are above first 'nfirst' values > delete those above
    % first 'nfirst'
    elseif ~isempty(ind_heightIncrease)
        % Delete values from start to last height increase above first
        % 'nfirst'
        % values
        height_purged(1:max(ind_nonNanHeights(ind_heightIncrease(ind_heightIncrease<=nfirst)+1))) = nan;
    end
    
end