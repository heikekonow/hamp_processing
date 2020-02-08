function foldername = getCampaignFolder(flightdates)
% ! Renamed this function from setCampaignFolder to getCampaignFolder in
% November 2017, HK

if iscell(flightdates)

    if str2double(flightdates{1})<20160000 && str2double(flightdates{end})<20160000
        foldername = 'NARVAL-I_campaignData/';
    elseif str2double(flightdates{1})>20160000 && str2double(flightdates{end})<20190000
        foldername = 'NANA_campaignData/';
    elseif str2double(flightdates{1})>20200000 && str2double(flightdates{end})<20210000
        foldername = 'EUREC4A_campaignData/';
    else
        error('Flight dates span more than one campaign year. Please specify.')
    end
    
elseif ischar(flightdates)
    
    if str2double(flightdates)<20160000
        foldername = 'NARVAL-I_campaignData/';
    elseif str2double(flightdates)>20160000 && str2double(flightdates)<20190000
        foldername = 'NANA_campaignData/';
    elseif str2double(flightdates)>20190000
        foldername = 'EUREC4A_campaignData/';
    else
        error('Did not find a campaign for this date. Please check.')
    end
    
else
    if flightdates<20160000
        foldername = 'NARVAL-I_campaignData/';
    elseif flightdates>20160000 && flightdates<20190000
        foldername = 'NANA_campaignData/';
    elseif flightdates>20190000
        foldername = 'EUREC4A_campaignData/';
    else
        error('Did not find a campaign for this date. Please check.')
    end
    
end