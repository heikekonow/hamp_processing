clear; close all

pathname = '/Users/heike/Documents/eurec4a/data_processing/EUREC4A_campaignData/data4publ/';

%%
files = listFiles([pathname '*radar*'], 'full');

for i=1:length(files)
    plot_radar(files{i})
end

%% 

files = listFiles([pathname '*radiometer*'], 'full');

for i=1:length(files)
    plot_radiometer(files{i})
end

%% FUNCTIONS %%

function plot_radar(filepath)

    dbz = ncread(filepath, 'dbz');
    ldr = ncread(filepath, 'ldr');
    t = eurec4atime2sdn(ncread(filepath, 'time'));
    h = ncread(filepath, 'height');

    missvalDBZ = ncreadatt(filepath, 'dbz', 'missing_value');
    missvalLDR = ncreadatt(filepath, 'ldr', 'missing_value');

    dbz(dbz == missvalDBZ) = nan;
    ldr(ldr == missvalDBZ) = nan;

    %%

    figure

    set(gcf,'Position',[284 60 1048 796])

    subplot(2,1,1)
    s = pcolor(t, h, dbz);
    s.EdgeColor = 'none';
    ylabel('height (m)')
    cb = colorbar;
    cb.Label.String = 'dBZ';
    finetunefigures
    datetick('x','HH:MM')
    title(datestr(t(1), 'YYYYmmDD'))
    caxis([-50 50])


    subplot(2,1,2)
    s = pcolor(t, h, ldr);
    s.EdgeColor = 'none';
    ylabel('height (m)')
    cb = colorbar;
    cb.Label.String = 'LDR (dB)';
    finetunefigures
    datetick('x','HH:MM')
end


function plot_radiometer(filepath)

    f = ncread(filepath, 'freq_sb');
    tb = ncread(filepath, 'tb');
    t = eurec4atime2sdn(ncread(filepath, 'time'));

    %%
    f_183 = f(f>180);
    f_11990 = f(f>=90 & f<180);
    f_KV = f(f<90);

    BT_183 = tb(f>180, :);
    BT_11990 = tb(f>=90 & f<180, :);
    BT_KV = tb(f<90, :);


    %%
    figure

    set(gcf,'Position',[792 641 1910 976])

    subplot(3,1,1)
    plot(t,BT_11990,'LineWidth',2)
    datetick('x','HH:MM')
    ylabel('BT (K), 11990')
    title(datestr(t(1), 'YYYYmmDD'))
    finetunefigures
    % ylim([220 330])
    ylim([min(min(BT_11990))-10 max(max(BT_11990))+40])
    l = cellstr(num2str(f_11990));
    plotLegendAsColoredText(gca,l,[0.15 0.89],0.03)

    subplot(3,1,2)
    plot(t,BT_KV,'LineWidth',2)
    datetick('x','HH:MM')
    ylabel('BT (K), KV')
    % ylim([120 350])
    ylim([min(min(BT_KV))-10 max(max(BT_KV))+40])
    finetunefigures
    l = cellstr(num2str(f_KV));
    plotLegendAsColoredText(gca,l,[0.15 0.582],0.03)

    subplot(3,1,3)
    plot(t,BT_183,'LineWidth',2)
    datetick('x','HH:MM')
    ylabel('BT (K), 183')
    finetunefigures
    % ylim([220 320])
    yl = [min(min(BT_183))-10 max(max(BT_183))+40];
    l = cellstr(num2str(f_183));
    plotLegendAsColoredText(gca,l,[0.15 0.305],0.03)
end