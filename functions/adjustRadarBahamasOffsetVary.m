function [tBoth,Z,hGPS,roll,pitch] = adjustRadarBahamasOffsetVary(tRadar,tBahamas,...
                                                timeOffset,Z,hGPS,roll,pitch)

% Copy variables
H = hGPS;
R = roll;
P = pitch;
Zcopy = Z; clear Z hGPS roll pitch

% Create vector with offset values
tOffset = zeros(length(tRadar),5);

% tOffset(1:floor(length(tOffset)/2),1:3) = timeOffset;
% tOffset(1:floor(length(tOffset)/2),4) = timeOffset+1;
% tOffset(1:floor(length(tOffset)/2),5) = timeOffset+2;
% tOffset(floor(length(tOffset)/2):end,1) = timeOffset+2;
% tOffset(floor(length(tOffset)/2):end,2) = timeOffset+1;
% tOffset(floor(length(tOffset)/2):end,3:end) = timeOffset;

tOffset(1:floor(length(tOffset)/2),1:3) = timeOffset;
tOffset(1:floor(length(tOffset)/2),4) = timeOffset-1;
tOffset(1:floor(length(tOffset)/2),5) = timeOffset-2;
tOffset(floor(length(tOffset)/2):end,1) = timeOffset-2;
tOffset(floor(length(tOffset)/2):end,2) = timeOffset-1;
tOffset(floor(length(tOffset)/2):end,3:end) = timeOffset;

% tOffset = zeros(length(tRadar),1);
% tOffset(1:floor(length(tOffset)/2)) = timeOffset;
% tOffset(floor(length(tOffset)/2):end) = timeOffset+1;

for i=1:size(tOffset,2)
    % Adjust time by adding offset
    tR = tRadar + 1/24/60/60 .* tOffset(:,i);

    % round times to avoid numerical deviations
    tB = dateround(tBahamas,6);
    tR = dateround(tR,6);

    % find common entries
    [tBoth{i},indBahamas,indRadar] = intersect(tB,tR);

    % Adjust to common time steps
    Z{i} = Zcopy(:,indRadar);
    hGPS{i} = H(indBahamas);
    roll{i} = R(indBahamas);
    pitch{i} = P(indBahamas);
end

% % Adjust time by adding offset
% tRadar = tRadar + 1/24/60/60 .* tOffset;
% 
% % round times to avoid numerical deviations
% tBahamas = dateround(tBahamas,6);
% tRadar = dateround(tRadar,6);
% 
% % find common entries
% [tBoth,indBahamas,indRadar] = intersect(tBahamas,tRadar);
% 
% % Adjust to common time steps
% Z{1} = Zcopy(:,indRadar);
% hGPS{1} = H(indBahamas);
% roll{1} = R(indBahamas);
% pitch{1} = P(indBahamas);
% 
% %% Vary the other way 'round
% 
% % Create vector with offset values
% tOffset = zeros(length(tRadar),1);
% tOffset(1:floor(length(tOffset)/2)) = timeOffset+1;
% tOffset(floor(length(tOffset)/2):end) = timeOffset;
% 
% % Adjust time by adding offset
% tRadar = tRadar + 1/24/60/60 .* tOffset;
% 
% % round times to avoid numerical deviations
% tBahamas = dateround(tBahamas,6);
% tRadar = dateround(tRadar,6);
% 
% % find common entries
% [tBoth,indBahamas,indRadar] = intersect(tBahamas,tRadar);
% 
% % Adjust to common time steps
% Z{2} = Zcopy(:,indRadar);
% hGPS{2} = H(indBahamas);
% roll{2} = R(indBahamas);
% pitch{2} = P(indBahamas);