close all

flightdate = '20200119';
readNew = true;

sdnSecond = 1/24/60/60;


testPlot = true;
opendap = true;

tOffset = 0;

%% Read radar data
if readNew
    clear tTurn offsTurn
    
    radarfile = listFiles([getPathPrefix getCampaignFolder(flightdate) 'radar/*' flightdate '*'], 'full', 'mat');

    Zg = ncread(radarfile, 'Zg');
    dBZ = 10 .* log10(Zg);

    range = ncread(radarfile, 'range');
    timeRadar = ncread(radarfile, 'time');


    %% Read bahamas data
    if opendap
        bahamasfile = ['https://macsserver.physik.uni-muenchen.de/products/dap/eurec4a/nav/EUREC4A_HALO_BAHAMAS-SPECMACS-100Hz-final_' flightdate 'a.nc'];
        
        timeBahamas = ncread(bahamasfile, 'time') .* 1e-6;
        roll = ncread(bahamasfile, 'roll');
        pitch = ncread(bahamasfile, 'pitch');
        alt = ncread(bahamasfile, 'height');
    else
        bahamasfile = listFiles([getPathPrefix getCampaignFolder(flightdate) 'bahamas/*' flightdate '*'], 'full', 'mat');

        timeBahamas = ncread(bahamasfile, 'TIME');
        roll = ncread(bahamasfile, 'IRS_PHI');
        pitch = ncread(bahamasfile, 'IRS_THE');
        alt = ncread(bahamasfile, 'IRS_ALT');
    end
end

%% Plot data

l = 1;


fh = figure(1);
fh.Position = [745 497 934 453];
plotComp(timeRadar, range, dBZ, timeBahamas, roll, pitch, alt)
title(flightdate)

xlOrig = xlim;
ylOrig = ylim;

disp('----------------------')
prompt = 'Zoom into first aircraft turn. Do calculated surface and radar surface signal match? (y/n)';

s = input(prompt,'s');

if strcmp(s, 'y')
    
    disp('')
    disp('----------------------')
    disp(['Great! The time offset is 0 sec for flight on ' flightdate])
    tOffset = 0;
    
%     fprintf('Great! The time offset is 0 sec for flight on %s. \nYou can add the following as a new line to the file timeOffsetLookup.m, but this is not necessary: \n', flightdate);
%     fprintf('''%s'', %d;\n', flightdate, tOffset);
    xl = xlim;
    yl = ylim;

    tTurn(l) = xl(1);
    offsTurn(l) = tOffset;

    l = l+1;

    prompt = 'Do you want to analyze another turn during this flight? (y/n)';
    s = input(prompt,'s');
    if strcmp(s, 'y')
        testPlot = true;
        xl = xlOrig;
        yl = ylOrig;
    else
        testPlot = false;
    end
%     
%     testPlot = false;
%     xl = xlim;
%     yl = ylim;
elseif strcmp(s, 'n')
    
    disp('')
    disp('----------------------')
    prompt = 'How many seconds should the radar data be shifted? (negative: to the left, positive: to the right)';
    tOffset = str2double(input(prompt,'s'));
    xl = xlim;
    yl = ylim;
elseif ~isempty(regexp(s, '[0-9]', 'once')) 
    
    tOffset = tOffset + str2double(s);
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
        xl = xlim;
        yl = ylim;
        
        tTurn(l) = xl(1);
        offsTurn(l) = tOffset;
        
        l = l+1;
        
        prompt = 'Do you want to analyze another turn during this flight? (y/n)';
        s = input(prompt,'s');
        if strcmp(s, 'y')
            testPlot = true;
            xl = xlOrig;
            yl = ylOrig;
        else
            testPlot = false;
        end
        
    elseif ~isempty(regexp(s, '[0-9]', 'once')) 
    
        tOffset = tOffset + str2double(s);
        xl = xlim;
        yl = ylim;

        
        
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

%%

disp('')
disp('----------------------')
fprintf('The following time offsets were found: \n');
disp([floor(sdn2unixtime(tTurn')), offsTurn'])

%% Figure

figure
plot(unixtime2sdn(floor(sdn2unixtime(tTurn))), offsTurn, '-ok', 'MarkerSize', 12, 'Linewidth', 2)
finetunefigures
datetick('x','keeplimits')
xlabel('Time UTC')
ylabel('Time offset (s)')
title(flightdate)


%% Save data and figure
offsettable = table(floor(sdn2unixtime(tTurn')), offsTurn',...
                'VariableNames', {'time', 'offset'});
outpath = [getPathPrefix getCampaignFolder(flightdate) ...
                'radarOffsetAnalysis/'];
            
outfile = [outpath 'radarOffsetAnalysis_' num2str(flightdate)];


writetable(offsettable, [outfile  '.txt'])
export_fig(outfile, '-png', gcf)


%% Final test


% disp('')
% disp('----------------------')
% fprintf('Here is the final test figure. If everything looks good, \nplease add the following as a new line to the file timeOffsetLookup.m: \n');
% 
% fprintf('''%s'', %d;\n', flightdate, tOffset);
% 
% figure(1)
% plotComp(timeRadar+tOffset, range, dBZ, timeBahamas, roll, pitch, alt)
% xlim(xl)
% ylim(yl)
% datetickzoom('x', 'HH:MM:SS', 'keeplimits')

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