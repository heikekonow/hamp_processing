%% FUNCTION_NAME
%   FUNCTION_NAME - One line description of what the function or script performs (H1 line)
%   Optional file header info (to give more details about the function than in the H1 line)
%   Optional file header info (to give more details about the function than in the H1 line)
%   Optional file header info (to give more details about the function than in the H1 line)
%
%   Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
%   Inputs:
%       input1 - Description
%       input2 - Description
%       input3 - Description
%
%   Outputs:
%       output1 - Description
%       output2 - Description
%
%   Example: 
%       Line 1 of example
%       Line 2 of example
%       Line 3 of example
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   January 2014; Last revision: 

%%


%------------- BEGIN CODE --------------

function [std_zMax,std_zMax_Sfc,tOffsetVec,zMax] = testRadarBahamasShiftTime(RadarFile,varargin)

% set locations
% RadarFile = '/data/share/u231/u231107/HAMP/mira36_all_v2/20140118_all_g40_v2.mmclx';
% BahamasPath = '/data/share/u231/u231107/HAMP/bahamas_all/';
% BahamasPath = '/Users/heike/Work/NARVAL-II/data/work/bahamas/';
% BahamasPath = '/Users/heike/Work/NANA_campaignData/bahamas/';
BahamasPath = '/data/share/narval/work/heike/NANA_campaignData/bahamas/';
figuresSavePath = '/data/share/narval/work/heike/NANA_campaignData/figures/';

% define vertical grid
zGrid = -500:30:14000;

%% Load data
% Extract time information
tRadar = unixtime2sdn(double(ncread(RadarFile,'time')));

% Date as string
date = datestr(tRadar(1),'yyyymmdd');

% Search for corresponding bahamas data file
BahamasFile = listFiles([BahamasPath '*' datestr(tRadar(1),'yyyymmdd') '*.nc']);
BahamasFile = [BahamasPath BahamasFile{1}];

% load bahamas time
% tBahamas = unixtime2sdn(ncread(BahamasFile,'utc_time'));
tBahamas = unixtime2sdn(ncread(BahamasFile,'TIME'));

% Get offset for specific day
if strcmp(varargin{1},'vary')
    tOffsetVec = timeOffsetLookup(date);
%     tOffsetVec = timeOffsetLookupNewDONOTUSE(date);
else
    timeOffset = timeOffsetLookup(date);
    tOffsetVec = timeOffset-3:timeOffset+3;    
end

% location
% hGPS = ncread(BahamasFile,'galt');
hGPS = ncread(BahamasFile,'IRS_ALT');
% % flight data
% roll = ncread(BahamasFile,'roll');
% pitch = ncread(BahamasFile,'pitch');
roll = ncread(BahamasFile,'IRS_PHI');
pitch = ncread(BahamasFile,'IRS_THE');

% load radar data
range = double(ncread(RadarFile,'range'));
Z = ncread(RadarFile,'Zg');

if strcmp(varargin{1},'normal')
    % Get indices for curves
    curveIndex = curveIndexLookup(date);
end


if strcmp(varargin{1},'mask') || strcmp(varargin{1},'vary')
    tIndex = timeOffsetUseMask(date,tRadar);
    tRadar = tRadar(tIndex);
    Z = Z(:,tIndex);
end

if strcmp(varargin{1},'normal')
    figure
    set(gcf,'Position',[1923 183 811 936])
end

std_zMax = zeros(length(tOffsetVec),1);
std_zMax_Sfc = zeros(length(tOffsetVec),1);
zMax = cell(length(tOffsetVec),1);
for i=1:length(tOffsetVec)
    disp(num2str(tOffsetVec(i)))
    if strcmp(varargin{1},'vary')
        
        [~,Z_shift,hGPS_shift,roll_shift,pitch_shift] = adjustRadarBahamasOffsetVary(tRadar,tBahamas,...
                                                        tOffsetVec(i),Z,hGPS,roll,pitch);
        Zint = cellfun(@(x,y,z,a) regriddFlightAngles(range,x,y,z,zGrid,a),roll_shift,pitch_shift,hGPS_shift,Z_shift,'UniformOutput',false);
        zMax{i} = cellfun(@(x) SfcFromZMax(x,zGrid),Zint,'UniformOutput',false);
        
        std_zMax(i,1:length(zMax{i})) = cell2mat(cellfun(@(x) nanstd(x),zMax{i},'UniformOutput',false));
        for j=1:length(zMax{i})
            std_zMax_Sfc(i,j) = nanstd(zMax{i}{j}(zMax{i}{j}>-500&zMax{i}{j}<500));
        end
        
     
    else   
        
        [tBoth,Z_shift,hGPS_shift,roll_shift,pitch_shift] = adjustRadarBahamasOffset(tRadar,tBahamas,...
                                                        tOffsetVec(i),Z,hGPS,roll,pitch);
        Zint = regriddFlightAngles(range,roll_shift,pitch_shift,hGPS_shift,zGrid,Z_shift);

        zMax{i} = SfcFromZMax(Zint,zGrid);
        
        std_zMax(i) = nanstd(zMax{i});
        std_zMax_Sfc(i) = nanstd(zMax{i}(zMax{i}>-500&zMax{i}<500));
    end
    
    if strcmp(varargin{1},'normal')
        % Only keep values between -500m and 500m
        zMax{i}(zMax{i}<-500|zMax{i}>500) = NaN;

        subplot(4,2,i)
        plot(tBoth,zMax{i},'.k')
        xlim([tBoth(curveIndex(1)) tBoth(curveIndex(2))])
        datetick('x','HH:MM','Keeplimits')
        finetunefigures
        xlabel('time')
        ylabel('Surface height (m)')
        title(['Offset: ' num2str(tOffsetVec(i)) ' sec - std: ' ...
            num2str(nanstd(zMax{i}(curveIndex(1):curveIndex(2))),'%6.2f') ' m'])
        setFontSize(gcf,14)
    end
    
end

if strcmp(varargin{1},'')
    mode = 'normal';
else
    mode = varargin{1};
end

if strcmp(varargin{1},'normal')
    export_fig([figuresSavePath 'offsetTest_' mode '_' datestr(tBahamas(1),'yyyymmdd')],'-png')
end

%------------- END OF CODE --------------