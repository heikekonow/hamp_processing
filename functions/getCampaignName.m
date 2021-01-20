function campaign = getCampaignName(flightdate)

NARVALdates = flight_dates;

ind = strcmp(NARVALdates(:,1), flightdate);

campaign = NARVALdates{ind, 3};