function [tBoth,Z,hGPS,roll,pitch] = adjustRadarBahamasOffset(tRadar,tBahamas,...
                                                timeOffset,Z,hGPS,roll,pitch)



% Adjust time by adding offset
tRadar = tRadar + 1/24/60/60 * timeOffset;

% round times to avoid numerical deviations
tBahamas = dateround(tBahamas,6);
tRadar = dateround(tRadar,6);

% find common entries
[tBoth,indBahamas,indRadar] = intersect(tBahamas,tRadar);

% Adjust to common time steps
Z = Z(:,indRadar);
hGPS = hGPS(indBahamas);
roll = roll(indBahamas);
pitch = pitch(indBahamas);