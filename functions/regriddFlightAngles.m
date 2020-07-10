function var_interp = regriddFlightAngles(range,rollAngle,pitchAngle,hGPS,z,var)

%% Calculate vertical coordinates
% Calculate height on axis perpendicular to earth: 
% h = range * cos(rollAngle) * cos(pitchAngle)
h = repmat(range,1,length(rollAngle)) .* ...
    repmat(cosd(rollAngle)',length(range),1) .* repmat(cosd(pitchAngle)',length(range),1);

% Convert 'distance from aircraft' to height by substracting it from flight
% altitude
h2 = repmat(hGPS',size(h,1),1) - h;

% Define vertical grid for measurements to be interpolated on
% z = -500:30:14000;

% Check if variable is cell
if iscell(var)
    % Preallocate
    var_interp = cell(length(var),1);
    % Loop all variables
    for j = 1:length(var)
        % Generate empty field of nan
        var_interp{j} = nan(length(z),size(h2,2));
        for i=1:size(h2,2)
            % Interpolate data on desired grid (linear)
%             var_interp{j}(:,i) = interp1(h2(:,i),var{j}(:,i),z);

            % Interpolate data on desired grid (nearest)
            var_interp{j}(:,i) = interp1(h2(:,i),var{j}(:,i),z, 'nearest');

        end
    end
else
    % Generate empty field of nan
    var_interp = nan(length(z),size(h2,2));
    for i=1:size(h2,2)
        if sum(isnan(h2(:,i)),1)==0
            % Interpolate data on desired grid (linear)
%             var_interp(:,i) = interp1(h2(:,i),var(:,i),z);

            % Interpolate data on desired grid (nearest)
            var_interp(:,i) = interp1(h2(:,i),var(:,i),z, 'nearest');
        end
    end
end