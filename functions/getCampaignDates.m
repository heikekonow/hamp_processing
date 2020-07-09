function narvaldates = getCampaignDates(campaign)

[NARVALdates, ~] = flight_dates;
if strcmp(campaign,'2016')
    narvalind = strcmp(NARVALdates(:,3),'NARVAL-II') | ...
                strcmp(NARVALdates(:,3),'NAWDEX');
elseif strcmp(campaign,'NARVAL-I')
    narvalind = strcmp(NARVALdates(:,3),'NARVAL-South') | ...
                strcmp(NARVALdates(:,3),'NARVAL-North');
elseif strcmp(campaign,'all')
    narvalind = true(size(NARVALdates(:,3)));
else
    narvalind = strcmp(NARVALdates(:,3),campaign);
end
narvaldates = NARVALdates(narvalind,1);