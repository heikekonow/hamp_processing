function [tb, f] = removeRadiometerErrors(dateuse, dataversion)

% clear; close all
% dateuse = '20160810';
% dataversion = '2.2';

load([getPathPrefix getCampaignFolder(dateuse) 'aux/errorFlag.mat'], 'errorFlag', 'sawtoothFlag', 'date')

file = listFiles([getPathPrefix getCampaignFolder(dateuse) 'all_nc/radiometer*' dateuse '*' dataversion '*.nc'],...
                    'latest', 'full');
tb = ncread(file, 'tb');
t = ncread(file, 'time');
f = ncread(file, 'frequency');

% 1: 183,   f>180
% 2: 11990, f>=90 & f<180
% 3: KV,    f<90

for i=1:3
    
    if i==1
        index = f>180;
    elseif i==2
        index = f>=90 & f<180;
    elseif i==3
        index = f<90;
    end
    
    dateindex = strcmp(date, dateuse);
    
%     figure
%     set(gcf, 'Position', [1949 49 1048 1056])
%     subplot(3,1,1)
%     plot(t, tb(index, :))
    
    tb(index,errorFlag{dateindex, i}) = nan;
%     subplot(3,1,2)
%     plot(t, tb(index, :))
    
    tb(index,sawtoothFlag{dateindex, i}) = nan;
%     subplot(3,1,3)
%     plot(t, tb(index, :))
    
end