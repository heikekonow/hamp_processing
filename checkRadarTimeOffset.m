clear; close all

flightdate = '20200126';

sdnSecond = 1/24/60/60;


testPlot = true;

%% Read radar data
radarfile = listFiles([getPathPrefix getCampaignFolder(flightdate) 'radar/*' flightdate '*'], 'full', 'mat');

Zg = ncread(radarfile, 'Zg');
dBZ = 10 .* log10(Zg);

range = ncread(radarfile, 'range');
timeRadar = ncread(radarfile, 'time');

%% Read bahamas data
bahamasfile = listFiles([getPathPrefix getCampaignFolder(flightdate) 'bahamas/*' flightdate '*'], 'full', 'mat');
timeBahamas = ncread(bahamasfile, 'TIME');
roll = ncread(bahamasfile, 'IRS_PHI');
pitch = ncread(bahamasfile, 'IRS_THE');
alt = ncread(bahamasfile, 'IRS_ALT');



%% Plot data
fh = figure(1);
plotComp(timeRadar, range, dBZ, timeBahamas, roll, pitch, alt)

disp('----------------------')
prompt = 'Zoom into aircraft turn. Do calculated surface and radar surface signal match? (y/n)';

s = input(prompt,'s');

if strcmp(s, 'y')
    
    disp('')
    disp('----------------------')
    disp(['Great! The time offset is 0 sec for flight on ' flightdate])
    tOffset = 0;
    
%     fprintf('Great! The time offset is 0 sec for flight on %s. \nYou can add the following as a new line to the file timeOffsetLookup.m, but this is not necessary: \n', flightdate);
%     fprintf('''%s'', %d;\n', flightdate, tOffset);
%     
    testPlot = false;
    xl = xlim;
    yl = ylim;
elseif strcmp(s, 'n')
    
    disp('')
    disp('----------------------')
    prompt = 'How many seconds should the radar data be shifted? (negative: to the left, positive: to the right)';
    tOffset = str2double(input(prompt,'s'));
    xl = xlim;
    yl = ylim;
else
    error('Please provide ''y'' or ''n'' as answer')
end

%% Test offset

% tOffset = -8;

while testPlot
    figure(1)
    plotComp(timeRadar, range, dBZ, timeBahamas, roll, pitch, alt, tOffset)
    xlim(xl)
    ylim(yl)
    datetickzoom('x', 'HH:MM:SS', 'keeplimits')
    
    disp('')
    disp('----------------------')
    prompt = 'Do calculated surface and radar surface signal match now? (y/n)';
    s = input(prompt,'s');
    
    if strcmp(s, 'y')
        disp(['Great! The time offset is ' num2str(tOffset) ' seconds for flight on ' flightdate])
        
        testPlot = false;
        
    elseif strcmp(s, 'n')
        
        disp('')
        disp('----------------------')
        prompt = 'How many seconds should the radar data be shifted additionally? (negative: to the left, positive: to the right)';
        tOffset = tOffset + str2double(input(prompt,'s'));
        xl = xlim;
        yl = ylim;
    else
        error('Please provide ''y'' or ''n'' as answer')
    end

    
end

%% Final test


disp('')
disp('----------------------')
fprintf('Here is the final test figure. If everything looks good, \nplease add the following as a new line to the file timeOffsetLookup.m: \n');

fprintf('''%s'', %d;\n', flightdate, tOffset);

figure(1)
plotComp(timeRadar+tOffset, range, dBZ, timeBahamas, roll, pitch, alt)
xlim(xl)
ylim(yl)
datetickzoom('x', 'HH:MM:SS', 'keeplimits')

%% Functions

function plotComp(timeRadar, range, dBZ, timeBahamas, roll, pitch, alt, tOffset)
    
    sfcCalc = alt ./ cosd(roll) ./ cosd(pitch);
    
%     timeRadar = datetime(timeRadar, 'ConvertFrom', 'posixtime');
%     timeBahamas = datetime(timeBahamas, 'ConvertFrom', 'posixtime');
    
    timeRadar = unixtime2sdn(timeRadar);
    timeBahamas = unixtime2sdn(timeBahamas);
    
    
    imagesc(timeRadar, range, dBZ)
    addWhiteToColormap
    
    hold on
    
    if exist('tOffset', 'var')
        tOffset = 1/24/60/60 .* tOffset;
        
        plot(timeBahamas, sfcCalc, 'x', 'Color', [.7 .7 .7])
        plot(timeBahamas-tOffset, sfcCalc, 'xk')
    else
        plot(timeBahamas, sfcCalc, 'xk')
    end
    
    datetickzoom('x', 'HH:MM:SS')
    
    finetunefigures
%     % Set Background Color to white
%     set(gcf, 'color','white');
%     % No Box, Ticks pointing out
%     set(gca, 'Box','off')
    
    setFontSize(gca,14)
    
    zoom on
    hold off
end