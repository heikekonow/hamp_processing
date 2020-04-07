%% run_testRadarBahamasShiftTime
%   run_testRadarBahamasShiftTime - Runscript for time offset testing 
%   
%   The impact of time offsets is tested by regridding radar data to
%   a grid perpendicular to the earth's surface. To this end, data off the
%   aircraft's attitude from BAHAMAS measurements is used. If BAHAMAS and
%   radar times are in sync, variation of surface heigth (from reflectivity
%   maximum) is minimal. In contrast, every deviation of times results in
%   higher standard deviation of surface heights along the flight.
%
%   Different modes of test can be defined in the header to test different
%   effects of time offsets: 
%           in 'normal' mode, effects +/- 2 seconds around an assumed offset
%                   (defined in file timeOffsetLookup.m) are tested
%           in 'vary' mode, differences of offsets in the first and second
%                   half of the flight are tested around a previously
%                   determined offset (defined in timeOffsetLookup.m)
%           in 'mask' mode, some time intervals (defined in
%                   timeOffsetUseMask.m) are omitted, additionally, the
%                   'normal' mode for offset determination is used
%
%   Analysis should first be done in 'normal' or 'mask' mode to determine
%   the best fitting time offset. The found values should then be written
%   into timeOffsetLookup.m. As a next step, differences of first and
%   second half can be analysed using 'vary' mode.
%   
%   The option savedata can be set to store the results in matlab-data
%   folder
%
%   Syntax:  run_testRadarBahamasShiftTime
%
%   Inputs:
%       - make sure that folder paths are set to correct locations
%       - select desired mode
%       - set savedata to true to store data
%
%   Outputs:
%       figures with standard deviation of 
%       *.mat file with data if option 'savedata' is set to true
%
%
%   Other m-files required: testRadarBahamasShiftTime, listFiles,
%                           finetunefigures
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: testRadarBahamasShiftTime
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   March 2015; Last revision: April 2020

%%


%------------- BEGIN CODE --------------


% General housekeeping
clear; close all

%% INPUT

% %%%%%%%%%%%%%%%%%%
% Select mode
% normal:   check offsets around assumed offset by +/- 2 seconds
% vary:     vary assumed offset between first and second half of flight by
%           -2 seconds
% mask:     mask previously defined time intervals (i.e. error measurements)
mode = 'mask';
% %%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%
% Save data?
savedata = 0;
% %%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%
% Campaign name
campaignName = 'NAWDEX';
% campaignName = 'NARVAL-II';
% %%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%
% Set path where radar data files (*.mmclx) can be found
% NARVAL-I
% RadarPath = '/data/share/u231/u231107/HAMP/mira36_all_v2/';
% NARVAL-II
% RadarPath = '/Users/heike/Work/NARVAL-II/data/work/radar/';
% Combined Data from both campaigns
% RadarPath = '/Users/heike/Work/NANA_campaignData/radar/';
RadarPath = '/data/share/narval/work/heike/NANA_campaignData/radar/';
% %%%%%%%%%%%%%%%%%%


%% Preparations

% %%%%%%%%%%%%%%%%%%
% Specify, if only selected times should be processed
% NARVAL-II and NAWDEX
% selectTime = '';
if strcmp(campaignName,'NARVAL-II')
    % NARVAL-II
    % selectTime = {'*201608*'};
elseif strcmp(campaignName,'NAWDEX')
    % NAWDEX
    selectTime = {'*201609*'; '*201610*'};
else
    error('Please specify valid campaign name')
end

% %%%%%%%%%%%%%%%%%%
% List all radar data files in directory RadarPath
% NARVAL-I
% radarFiles = listFiles([RadarPath '*_v2.mmclx']);
% NARVAL-II
% radarFiles = listFiles([RadarPath selectTime '*.nc']);
% NAWDEX
% radarFiles = [listFiles([RadarPath selectTime{1} '*.nc']);...
%     listFiles([RadarPath selectTime{2} '*.nc'])];
% This should work for all times defined above
radarFiles = listFiles([repmat(RadarPath,length(selectTime),1) ...
    cell2mat(selectTime(:)) repmat('*.nc',length(selectTime),1)]);

% !!!!!!!! Attention! Change later, when radar data from RF13 (NAWDEX) is
% reprocessed !!!!!!!
% radarFiles(strncmp('20161018',radarFiles(:),8)) = [];
% radarFiles = radarFiles(strncmp('20161018',radarFiles(:),8));

% Preallocate cells
std_zMax = cell(length(radarFiles),1);
std_zMax_Sfc = cell(length(radarFiles),1);
tOffsets = cell(length(radarFiles),1);
zMax = cell(length(radarFiles),1);

%% Test time offset

% Loop all files found
for i=1:length(radarFiles)
    % Display file info
    disp(radarFiles{i})
    
    % Shift radar and bahamas times against each other
    
    % Cases for different type of analysis (as defined in the beginning)
    if strcmp(mode,'normal')       % offset +/- 2 seconds
        [std_zMax{i},std_zMax_Sfc{i},tOffsets{i},zMax{i}] = ...
                testRadarBahamasShiftTime([RadarPath radarFiles{i}],'');
    elseif strcmp(mode,'vary')     % different offsets in first and second half of flight
        [std_zMax{i},std_zMax_Sfc{i},tOffsets{i},zMax{i}] = ...
                testRadarBahamasShiftTime([RadarPath radarFiles{i}],'vary');
    elseif strcmp(mode,'mask')     % mask time intervals
        [std_zMax{i},std_zMax_Sfc{i},tOffsets{i},zMax{i}] = ...
                testRadarBahamasShiftTime([RadarPath radarFiles{i}],'mask');
    end
%     
end

% Save data
if savedata
    if strcmp(computer,'MACI64')
        save(['/Users/heike/Work/matlab-data/std_ZmaxHeigh_' mode '.mat'],'std_zMax','tOffsets','std_zMax_Sfc','zMax','radarFiles')
    else
        % % % save('../matlab-data/std_ZmaxHeightMask.mat','std_zMax','tOffsets','std_zMax_Sfc','zMax','radarFiles')
        save(['../matlab-data/std_ZmaxHeigh_' mode '.mat'],'std_zMax','tOffsets','std_zMax_Sfc','zMax','radarFiles')
    end
end

%% Plot results

close all

if strcmp(mode,'normal')|| strcmp(mode,'mask')
    figure(1)
    set(gcf,'Position',[1923 484 1276 635])
end
if strcmp(mode,'vary')
    figure(2)
    set(gcf,'Position',[1923 273 1276 846])
    % xString = {'to/to+2','to/to+1','to/to','to+1/to','to+2/to'};
    xString = {'to/to-2','to/to-1','to/to','to-1/to','to-2/to'};
end
for i=1:length(radarFiles)
    datestring = radarFiles{i}(1:8);
    
    if strcmp(mode,'normal') || strcmp(mode,'mask')
        figure(1)
        subplot(3,5,i)
%         plot(tOffsets{i},std_zMax{i},'LineWidth',2)
        plot(tOffsets{i},std_zMax_Sfc{i},'LineWidth',2)
        finetunefigures
        xlabel('Time Offset (s)')
        ylabel('std')
        xlim([tOffsets{i}(1) tOffsets{i}(end)])
        title(datestring)
        setFontSize(gcf,14)
    end
    
    if strcmp(mode,'vary')
        figure(2)
        subplot(4,4,i)
    %     plot(tOffsets{i},std_zMax_Sfc{i})
%         plot(std_zMax_Sfc{i},'LineWidth',2)
        plot(std_zMax_Sfc{i},'LineWidth',2)
        finetunefigures
        xlabel('Time Offset (s)')
        ylabel('std')
        xlim([1 5])
    %     xlim([tOffsets{i}(1) tOffsets{i}(end)])
        title(datestring)
        set(gca,'XTickLabel',xString)
        setFontSize(gcf,14)
    end
end

savefile = [RadarPath(1:36) 'figures/' campaignName '_tOffset_' mode];
export_fig(savefile,'-png')

% Code for saving figure and copying to dropbox folder (to include in tex
% file for report)
%
% export_fig('/Users/heike/Work/NANA_campaignData/figures/n2_tOffset','-png')
% !cp /Users/heike/Work/NANA_campaignData/figures/n2_tOffset.png /Users/heike/Dropbox/Apps/ShareLaTeX/HAMP_Data_Processing/figures/

%------------- END OF CODE --------------