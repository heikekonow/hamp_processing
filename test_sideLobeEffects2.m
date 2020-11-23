clear; close all

flightdate = '20200130';
filepath = '/Users/heike/Documents/eurec4a/data_processing/EUREC4A_campaignData/radar/20200205_0936_uncalib_prelim.nc';

t = unixtime2sdn(readdata(flightdate, 'time'));
z = readdata(flightdate, 'dBZ');
h = readdata(flightdate, 'height');
roll = readdata(flightdate, 'roll');
pitch = readdata(flightdate, 'pitch');
ldr = readdata(flightdate, 'LDR');
snr = readdata(flightdate, 'SNR');
rms = readdata(flightdate, 'RMS');
alt = readdata(flightdate, 'altitude');

Zg = ncread(filepath, 'Zg');
LDRg = ncread(filepath, 'LDRg');
RMSg = ncread(filepath, 'RMSg');
VELg = ncread(filepath, 'VELg');
range = ncread(filepath, 'range');
time = unixtime2sdn(ncread(filepath, 'time'));
db = 10 .* log(Zg);

%%

ldrThres = 0.01;
ldrM = ldr;
ldrM(ldr>=ldrThres) = 1;
ldrM(ldr<ldrThres) = 2;

rmsThres = 1.5;
rmsM = rms;
rmsM(rms>=rmsThres) = 1;
rmsM(rms<rmsThres) = 2;

%%
rollInd = nan(size(t));
rollInd(abs(roll)>6) = 1;

rollIndMat = abs(roll)>6;
rollIndMat = repmat(rollIndMat', size(h, 1), 1);

% xl = {[737826.592401302 737826.594654623];
%       [737826.745841089 737826.751394371];
%       [737826.532446675 737826.537617869];
%       [737826.579381566 737826.585501424];
%       [737826.588737331 737826.600688127]};

xl = {[737820.534467738 737820.545577231];
      [737820.510471235 737820.518247879];
      [737820.561201217 737820.569583834]};
  
%%
s = alt .* (1 ./ cosd(roll) ./ cosd(pitch) - 1) + 60;
sMat = repmat(s', size(h, 1), 1);
altMat = repmat(h, 1, size(t,1));
geoMask = altMat<sMat;
% sideLobeMask = ((rms>rmsThres | ldr>ldrThres) | geoMask) & rollIndMat;
sideLobeMask = geoMask & rollIndMat;

zMasked = z;
zMasked(sideLobeMask) = nan;


%%

for i=1:size(xl, 1)
    
    figure
    set(gcf, 'Position', [193 52 923 903])


    subplot(5,1,1)
    %
    ph = pcolor(t, h, z);
    ph.EdgeColor = 'none';
    title('dBZ')
    set(gca, 'YDir', 'normal')
    addWhiteToColormap
    xlim(xl{i})
    ylim([0 2500])
    caxis([-38 30])
    datetick('x', 'HH:MM:SS' ,'keeplimits')
    % colorbar
    hold on
    plot(t, rollInd, 'xk')
    hold off
    ylabel('Height (m)')
    finetunefigures
    ah = gca;
    ah.XTickLabel = [];


    subplot(5,1,2)
    %
    ph = pcolor(t, h, ldrM);
    ph.EdgeColor = 'none';
    title(['LDR > ' num2str(ldrThres)])
    set(gca, 'YDir', 'normal')
    addWhiteToColormap
    xlim(xl{i})
    ylim([0 2500])
    caxis([0 2])
    datetick('x', 'HH:MM:SS' ,'keeplimits')
    % colorbar
    hold on
    plot(t, rollInd, 'xk')
    hold off
    ylabel('Height (m)')
    finetunefigures
    ah = gca;
    ah.XTickLabel = [];


    subplot(5,1,3)
    %
    ph = pcolor(t, h, rmsM);
    ph.EdgeColor = 'none';
    title(['RMS > ' num2str(rmsThres)])
    set(gca, 'YDir', 'normal')
    addWhiteToColormap
    xlim(xl{i})
    ylim([0 2500])
    caxis([0 2])
    datetick('x', 'HH:MM:SS' ,'keeplimits')
    % colorbar
    hold on
    plot(t, rollInd, 'xk')
    hold off
    ylabel('Height (m)')
    finetunefigures
    ah = gca;
    ah.XTickLabel = [];


    subplot(5,1,4)
    %
    ph = pcolor(t, h, double(sideLobeMask));
    ph.EdgeColor = 'none';
    title('comb. mask')
    set(gca, 'YDir', 'normal')
    addWhiteToColormap
    xlim(xl{i})
    ylim([0 2500])
    caxis([0 2])
    datetick('x', 'HH:MM:SS' ,'keeplimits')
    % colorbar
    hold on
    plot(t, rollInd, 'xk')
    hold off
    ylabel('Height (m)')
    finetunefigures
    ah = gca;
    ah.XTickLabel = [];

    subplot(5,1,5)
    %
    ph = pcolor(t, h, zMasked);
    ph.EdgeColor = 'none';
    title('dBZ, masked')
    set(gca, 'YDir', 'normal')
    addWhiteToColormap
    xlim(xl{i})
    ylim([0 2500])
    caxis([-38 30])
    datetick('x', 'HH:MM:SS' ,'keeplimits')
    % colorbar
    hold on
    plot(t, rollInd, 'xk')
    hold off
    ylabel('Height (m)')
    finetunefigures
    ah = gca;
    ah.XTickLabel = [];
end