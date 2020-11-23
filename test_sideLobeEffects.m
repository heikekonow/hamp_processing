clear; close all

flightdate = '20200205';
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
rollInd = nan(size(t));
rollInd(abs(roll)>6) = 1;

rollIndMat = abs(roll)>6;
rollIndMat = repmat(rollIndMat', size(h, 1), 1);

% xl = [737826.591666667 737826.595138889];
xl = [737826.592401302 737826.594654623];
% xl = [1580911937.81016 1580912219.27843];
% xl = [1580912129.60952 1580912160.45595];
% xl = [1580912037 1580912068];


%%
% figure
% set(gcf, 'Position', [189 118 923 789])
% subplot(3,1,1:2)
% ph = pcolor(t, h, z);
% ph.EdgeColor = 'none';
% title(flightdate)
% set(gca, 'YDir', 'normal')
% addWhiteToColormap
% xlim(xl)
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% ylim([0 3500])
% hold on
% plot(t, rollInd, 'xk')
% hold off
% ylabel('Height (m)')
% finetunefigures
% ah = gca;
% ah.XTickLabel = [];
% 
% subplot(3,1,3)
% plot(t, roll)
% xlim(xl)
% finetunefigures
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% grid on
% xlabel('Roll (deg)')

%%
figure
set(gcf, 'Position', [193 52 923 903])

subplot(3,1,1)
ph = pcolor(t, h, z);
ph.EdgeColor = 'none';
title(flightdate)
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
datetick('x', 'HH:MM:SS' ,'keeplimits')
ylim([0 3500])
ch = colorbar;
ch.Label.String = 'dBZ';
hold on
plot(t, rollInd, 'xk')
hold off
ylabel('Height (m)')
finetunefigures
ah = gca;
ah.XTickLabel = [];

subplot(3,1,2)
% ph = pcolor(t, h, ldr);
% ph.EdgeColor = 'none';
% title('LDR')
imagesc(t, h, ldr)
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
datetick('x', 'HH:MM:SS' ,'keeplimits')
ylim([0 3500])
ch = colorbar;
ch.Label.String = 'LDR';
caxis([0 0.01])
% hold on
% plot(t, rollInd, 'xk')
% hold off
ylabel('Height (m)')
finetunefigures
ah = gca;
ah.XTickLabel = [];

subplot(3,1,3)
% ph = pcolor(t, h, rms);
% ph.EdgeColor = 'none';
imagesc(t, h, rms)
% title('RMS')
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
datetick('x', 'HH:MM:SS' ,'keeplimits')
ylim([0 3500])
ch = colorbar;
ch.Label.String = 'RMS (m/s)';
% hold on
% plot(t, rollInd, 'xk')
% hold off
ylabel('Height (m)')
finetunefigures


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
figure
set(gcf, 'Position', [193 52 923 903])

subplot(7,1,1:2)
ph = pcolor(t, h, z);
ph.EdgeColor = 'none';
title('dBZ')
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
ylim([0 3500])
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
% removeScientificLabel(gca, 'x')

subplot(7,1,3:4)
ph = pcolor(t, h, ldrM);
ph.EdgeColor = 'none';
title(['LDR > ' num2str(ldrThres)])
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
ylim([0 3500])
ylabel('Height (m)')
datetick('x', 'HH:MM:SS' ,'keeplimits')
% colorbar
caxis([0 2])
hold on
plot(t, rollInd, 'xk')
hold off
finetunefigures
ah = gca;
ah.XTickLabel = [];
% removeScientificLabel(gca, 'x')

subplot(7,1,5:6)
ph = pcolor(t, h, rmsM);
ph.EdgeColor = 'none';
title(['RMS > ' num2str(rmsThres)])
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
ylim([0 3500])
ylabel('Height (m)')
datetick('x', 'HH:MM:SS' ,'keeplimits')
% colorbar
caxis([0 2])
hold on
plot(t, rollInd, 'xk')
hold off
finetunefigures
ah = gca;
ah.XTickLabel = [];
% removeScientificLabel(gca, 'x')


subplot(7,1,7)
yyaxis left
plot(t, roll, 'x')
xlim(xl)
datetick('x', 'HH:MM:SS' ,'keeplimits')
ylabel('Roll (deg)')
removeScientificLabel(gca, 'y')
yyaxis right
ylabel('Height (m)')
plot(t, alt, 'o')
datetick('x', 'HH:MM:SS' ,'keeplimits')
removeScientificLabel(gca, 'y')
finetunefigures
xlabel(['time UTC, ' flightdate])
% removeScientificLabel(gca, 'x')

%%

sMat = repmat(s', size(h, 1), 1);
altMat = repmat(h, 1, size(t,1));
geoMask = altMat<sMat;
sideLobeMask = ((rms>rmsThres | ldr>ldrThres) | geoMask) & rollIndMat;
% sideLobeMask = geoMask & rollIndMat;

zMasked = z;
zMasked(sideLobeMask) = nan;

% 
% %%
% figure
% set(gcf, 'Position', [856 82 748 903])
% 
% subplot(4,1,1)
% ph = pcolor(t, h, z);
% ph.EdgeColor = 'none';
% title('dBZ')
% set(gca, 'YDir', 'normal')
% addWhiteToColormap
% xlim(xl)
% ylim([0 2500])
% caxis([-38 30])
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% % colorbar
% hold on
% plot(t, rollInd, 'xk')
% hold off
% ylabel('Height (m)')
% finetunefigures
% ah = gca;
% ah.XTickLabel = [];
% % removeScientificLabel(gca, 'x')
% 
% subplot(4,1,2)
% ph = pcolor(t, h, ldrM);
% ph.EdgeColor = 'none';
% title(['LDR > ' num2str(ldrThres)])
% set(gca, 'YDir', 'normal')
% addWhiteToColormap
% xlim(xl)
% ylim([0 2500])
% ylabel('Height (m)')
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% % colorbar
% caxis([0 2])
% hold on
% plot(t, rollInd, 'xk')
% hold off
% finetunefigures
% ah = gca;
% ah.XTickLabel = [];
% % removeScientificLabel(gca, 'x')
% 
% subplot(4,1,3)
% ph = pcolor(t, h, rmsM);
% ph.EdgeColor = 'none';
% title(['RMS > ' num2str(rmsThres)])
% set(gca, 'YDir', 'normal')
% addWhiteToColormap
% xlim(xl)
% ylim([0 2500])
% ylabel('Height (m)')
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% % colorbar
% caxis([0 2])
% hold on
% plot(t, rollInd, 'xk')
% hold off
% finetunefigures
% ah = gca;
% ah.XTickLabel = [];
% % removeScientificLabel(gca, 'x')
% 
% 
% subplot(4,1,4)
% ph = pcolor(t, h, double(sideLobeMask));
% ph.EdgeColor = 'none';
% title(['RMS > ' num2str(rmsThres)])
% set(gca, 'YDir', 'normal')
% addWhiteToColormap
% xlim(xl)
% ylim([0 2500])
% ylabel('Height (m)')
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% % colorbar
% caxis([0 2])
% hold on
% plot(t, rollInd, 'xk')
% hold off
% finetunefigures
% ah = gca;
% ah.XTickLabel = [];


%%
figure
set(gcf, 'Position', [856 82 748 903])

subplot(4,1,1)
ph = pcolor(t, h, z);
ph.EdgeColor = 'none';
title('dBZ')
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
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
% removeScientificLabel(gca, 'x')

subplot(4,1,2)
ph = pcolor(t, h, double(sideLobeMask));
ph.EdgeColor = 'none';
title(['LDR > ' num2str(ldrThres)])
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
ylim([0 2500])
ylabel('Height (m)')
datetick('x', 'HH:MM:SS' ,'keeplimits')
% colorbar
caxis([0 2])
hold on
plot(t, rollInd, 'xk')
hold off
finetunefigures
ah = gca;
ah.XTickLabel = [];
% removeScientificLabel(gca, 'x')

subplot(4,1,3)
ph = pcolor(t, h, zMasked);
ph.EdgeColor = 'none';
title(['RMS > ' num2str(rmsThres)])
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim(xl)
ylim([0 2500])
ylabel('Height (m)')
datetick('x', 'HH:MM:SS' ,'keeplimits')
% colorbar
caxis([-38 30])
hold on
plot(t, rollInd, 'xk')
hold off
finetunefigures
ah = gca;
ah.XTickLabel = [];
% removeScientificLabel(gca, 'x')


% subplot(4,1,4)
% ph = pcolor(t, h, double(sideLobeMask));
% ph.EdgeColor = 'none';
% title(['RMS > ' num2str(rmsThres)])
% set(gca, 'YDir', 'normal')
% addWhiteToColormap
% xlim(xl)
% ylim([0 2500])
% ylabel('Height (m)')
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% % colorbar
% caxis([0 2])
% hold on
% plot(t, rollInd, 'xk')
% hold off
% finetunefigures
% ah = gca;
% ah.XTickLabel = [];


%%
% figure
% ph = pcolor(time, range, db);
% ph.EdgeColor = 'none';
% addWhiteToColormap
% xlim(xl)
% ylim([6000 15000])
% ah = gca;
% set(gcf, 'color','white');
% ah.Box = 'off';
% set(gca, 'FontSize', 12,'FontWeight','bold')
% lh = get(gca,'Children');
% removeScientificLabel(gca, 'y')
% removeScientificLabel(gca, 'x')
% datetick('x', 'HH:MM:SS' ,'keeplimits')


%%

% xl2 = [737826.592786914 737826.593007514];
% figure
% set(gcf, 'Position', [455 164 1048 766])
% 
% surf = alt ./ cosd(roll) ./ cosd(pitch);
% 
% subplot(3,1,1:2)
% ph = pcolor(time, range, db);
% ph.EdgeColor = 'none';
% addWhiteToColormap
% xlim(xl)
% ylim([9435 13732])
% ah = gca;
% finetunefigures
% lh = get(gca,'Children');
% removeScientificLabel(gca, 'y')
% removeScientificLabel(gca, 'x')
% hold on
% plot(t, surf, 'xk')
% xlim(xl2)
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% 
% subplot(3,1,3)
% plot(t, roll, 'x-k')
% hold on
% plot(t, pitch, 'x-g')
% xlim(xl2)
% ylim([-5 30])
% finetunefigures
% datetick('x', 'HH:MM:SS' ,'keeplimits')
% yyaxis right
% ylabel('Height (m)')
% plot(t, alt, 'o')
% removeScientificLabel(gca, 'y')
% grid on

%%

% evalInd = find(t<xl(2), 1, 'last')-5;
% % evalInd = 18008;
% roll(evalInd)
% alt(evalInd)
% 
% % tand(abs(roll(evalInd))) .* alt(evalInd)
% sind(abs(roll(evalInd))) * 1080