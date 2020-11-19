function varNew = removeRadarClutter(var, missingvalue, fillvalue)

% Define structuring element
structuringElement = strel('square',2);


%% Create masks for fill value and missing value
if isnan(fillvalue)
    fillMask = isnan(var);
else
    fillMask = var==fillvalue;
end

% if isnan(missingvalue)
%     missingMask = isnan(var);
% else
%     missingMask = var==missingvalue;
% end

%% Create bit mask from variable
% Fill with zeros
bitMask = zeros(size(var));
% Set everything not missingvalue to 1
% bitMask(~isinf(var)) = 1;
bitMask(var ~= missingvalue) = 1;

% % Set fillvalue back to 0
% if isnan(fillvalue)
%     bitMask(isnan(var)) = 0;
% else
%     bitMask(var == fillvalue) = 0;
% end

%% Remove clutter with morphological operations
% Close bit mask
bitMask = imclose(bitMask, structuringElement);
% Open bit mask
bitMask = imopen(bitMask, structuringElement);

%% Apply mask
% Create logical mask
logicalMask = logical(bitMask);

% Create new array
% varNew = nan(size(var));
varNew = ones(size(var)) .* missingvalue;

% Copy data from original array only where mask is true
varNew(logicalMask) = var(logicalMask);

% Add -inf information to new array
% varNew(fillMask) = fillvalue;
% varNew(isinf(var)) = -inf;