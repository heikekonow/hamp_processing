function plotHAMPQuicklook_sepFiles(flightdates)


    version = 'latest';

    for i=1:length(flightdates)
         plotQuicklooks(flightdates{i},version,'save')
    end

end

function plotQuicklooks(date,version,varargin)

close all;

flightdate = date;

%%
    
folderpath = [getPathPrefix getCampaignFolder(date) 'all_nc/'];

if strcmp(version, 'latest')
    radarfile = listFiles([folderpath 'radar_' date '*.nc'], 'full', 'latest');
    radiometerfile = listFiles([folderpath 'radiometer_' date '*.nc'], 'full', 'latest');
    bahamasfile = listFiles([folderpath 'bahamas_' date '*.nc'], 'full', 'latest');
    dropsondesfile = listFiles([folderpath 'dropsondes_' date '*.nc'], 'full', 'latest');
else
    radarfile = [folderpath 'radar_' date '_v' version '.nc'];
    radiometerfile = [folderpath 'radiometer_' date '_v' version '.nc'];
    bahamasfile = [folderpath 'bahamas_' date '_v' version '.nc'];
    dropsondesfile = [folderpath 'dropsondes_' date '_v' version '.nc'];
end

savefig = 0;
fixerrors = 0;

if nargin>2
    if sum(strcmp(varargin,'save'))>0
        savefig = 1;
    end
    if sum(strcmp(varargin,'fixerrors'))>0
        fixerrors = 1;
    end
end

t = ncread(bahamasfile,'time');
t = double(unixtime2sdn(t));
alt = ncread(bahamasfile,'altitude');
h = ncread(bahamasfile,'height');
BT = ncread(radiometerfile,'tb');
f = ncread(radiometerfile,'frequency');

f_KV = f(1:14);
f_11990 = f(15:19);
f_183 = f(20:end);
BT_KV = BT(1:14,:);
BT_11990 = BT(15:19,:);
BT_183 = BT(20:end,:);

if fixerrors
    load([getPathPrefix 'NANA_campaignData/aux/errorFlag.mat'])
    
    instrument = '183';
    BT_183(:,errorFlag{strcmp(flightdate,date),strcmp(instrument,instr)}) = nan;
    BT_183(:,sawtoothFlag{strcmp(flightdate,date),strcmp(instrument,instr)}) = nan;
    
    BT_183(BT_183>400) = nan;
    BT_183(BT_183<150) = nan;
    
    instrument = 'KV';
    BT_KV(:,errorFlag{strcmp(flightdate,date),strcmp(instrument,instr)}) = nan;
    BT_KV(:,sawtoothFlag{strcmp(flightdate,date),strcmp(instrument,instr)}) = nan;
    
    BT_KV(BT_KV>400) = nan;
    BT_KV(BT_KV<120) = nan;
    
    instrument = '11990';
    BT_11990(:,errorFlag{strcmp(flightdate,date),strcmp(instrument,instr)}) = nan;
    BT_11990(:,sawtoothFlag{strcmp(flightdate,date),strcmp(instrument,instr)}) = nan;
    
end

date = flightdate;

if ncVarInFile(dropsondesfile,'ta')
    T_sonde = ncread(dropsondesfile,'ta');
    RH_sonde = ncread(dropsondesfile,'rh');
    t_start = ncread(dropsondesfile,'launch_time');
    t_start = unixtime2sdn(double(t_start));
end

lat = ncread(bahamasfile,'lat');
lon = ncread(bahamasfile,'lon');

if ncVarInFile(radarfile,'dBZ')
    dBZ = ncread(radarfile,'dBZ');
end

%%
figure

set(gcf,'Position',[792 641 1910 976])


subplot(5,3,1:2)
plot(t,BT_11990,'LineWidth',2)
datetick('x','HH:MM')
ylabel('BT (K), 11990')
finetunefigures
% ylim([220 330])
ylim([min(min(BT_11990))-10 max(max(BT_11990))+40])
l = cellstr(num2str(f_11990));
plotLegendAsColoredText(gca,l,[0.15 0.89],0.03)

subplot(5,3,4:5)
plot(t,BT_KV,'LineWidth',2)
datetick('x','HH:MM')
ylabel('BT (K), KV')
% ylim([120 350])
ylim([min(min(BT_KV))-10 max(max(BT_KV))+40])
finetunefigures
l = cellstr(num2str(f_KV));
plotLegendAsColoredText(gca,l,[0.15 0.72],0.03)

subplot(5,3,7:8)
plot(t,BT_183,'LineWidth',2)
datetick('x','HH:MM')
ylabel('BT (K), 183')
finetunefigures
% ylim([220 320])
ylim([min(min(BT_183))-10 max(max(BT_183))+40])
l = cellstr(num2str(f_183));
plotLegendAsColoredText(gca,l,[0.15 0.55],0.03)

subplot(5,3,[10,11,13,14])
if ncVarInFile(radarfile,'dBZ')
    ih = imagesc(t,h,dBZ);
else
    imagesc(t,h,nan(length(t),length(h)))
end
addWhiteToColormap
set(gca,'ydir','normal')
datetick('x','HH:MM')
ylabel('Height (m)')
xlabel('Time (UTC)')
ylim([0 round(max(alt)+300)])
finetunefigures
cm = cbrewer('seq','YlGnBu',9);
colormap(cm)
addWhiteToColormap

if ncVarInFile(radarfile,'dBZ')
    ch = adjustColorMap([-63 -60 -40 -20 0 20],[1,1,1;cm(2:5,:)],dBZ,ih,'cb');
    set(ch,'Position',[0.06 0.1 0.01 0.3])

    ch.Label.String = 'Reflectivity (dBZ)';
end

hold on
plot(t,alt,'k','LineWidth',2)

if ncVarInFile(dropsondesfile,'ta')
    sonde_ind = [2 5];
    
    if length(t_start)<sonde_ind(1)
        plot([t_start(1) t_start(1)],[0 max(alt)],'LineStyle','--','LineWidth',2)
        sonde_ind(1) = 1;
    else
        plot([t_start(sonde_ind(1)) t_start(sonde_ind(1))],[0 max(alt)],...
            'LineStyle','--','LineWidth',2)
    end
    if length(t_start)<sonde_ind(2)
        plot([t_start(end) t_start(end)],[0 max(alt)],'LineStyle','--','LineWidth',2)
        sonde_ind(2) = length(t_start);
    else
        plot([t_start(sonde_ind(2)) t_start(sonde_ind(2))],[0 max(alt)],'LineStyle','--',...
                'LineWidth',2)
    end

    hold off

    subplot(5,3,[3 6])
    plot(T_sonde(:,sonde_ind),h,'LineWidth',2)
    ylabel('Height (m)')
    xlabel('T (deg C)')
    finetunefigures

    subplot(5,3,[9 12])
    plot(RH_sonde(:,sonde_ind),h,'LineWidth',2)
    finetunefigures
    xlabel('RH (%)')
    ylabel('Height (m)')
end

subplot(5,3,15)
plot(lon,lat,'k','LineWidth',2)
xlabel('lon')
ylabel('lat')
xlim([round(min(lon))-1 round(max(lon))+1])
ylim([round(min(lat))-1 round(max(lat))+1])
finetunefigures

versionstring = findLatestVersionInfo(bahamasfile);
[a,~] = suplabel([datestr(t(1),'dd.mm.yyyy') ' - ' versionstring{1}],'t');
pos = a.Position;
set(a,'Position',pos+[0 -0.02 0 0])

setFontSize(gcf,14)

%% Save figure
if savefig

    figuredir = [getPathPrefix getCampaignFolder(date) 'figures/'];
    
    if ~exist(figuredir, 'dir')
        mkdir(figuredir)
    end
    
    figurename = [figuredir 'HAMP_quickl_' date '_v' getVersionFromFilename(bahamasfile)];
    
    export_fig(figurename, '-r100','-png','-painters')
end

end
%%
function versionstring = findLatestVersionInfo(file)
fileInfo = ncinfo(file,'/');
attNames = {fileInfo.Attributes(:).Name}';
findVersions = strfind(attNames,'Version');
indVersions = find(cell2mat(findVersions));

versionstring = attNames(max(indVersions));
end
