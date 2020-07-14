function varNew = removeRadarClutter(var)

% Define structuring element
structuringElement = strel('square',2);

%% Create bit mask from variable
% Fill with zeros
bitMask = zeros(size(var));
% Set everything not -inf to 1
bitMask(~isinf(var)) = 1;
% Set nans back to 0
bitMask(isnan(var)) = 0;

%% Remove clutter with morphological operations
% Close bit mask
bitMask = imclose(bitMask, structuringElement);
% Open bit mask
bitMask = imopen(bitMask, structuringElement);

%% Apply mask
% Create logical mask
logicalMask = logical(bitMask);

% Create new array
varNew = nan(size(var));
% Copy data from original array only where mask is true
varNew(logicalMask) = var(logicalMask);
% Add -inf information to new array
varNew(isinf(var)) = -inf;