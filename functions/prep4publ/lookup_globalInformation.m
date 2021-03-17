function information = lookup_globalInformation(instrument,measDate,versionInDatabase,comment)

%add information about Campaign Names, Source (Instrument Names) 

instrumentNames = {
        'radar','HAMP cloud radar';
        'radiometer','HAMP radiometer';
        'dropsondes','Vaisala drop sondes';
        'bahamas','BAsic HAlo Measurement And Sensor system (BAHAMAS)'}; 
    
indInstr = strcmp(instrument,instrumentNames(:,1)); 

campaignName = getCampaignName(measDate); 


information.Title = ['HAMP measurements on HALO Aircraft during ' campaignName]; %set the campaign Name as information
information.Institute = 'Meteorological Institute, Universitaet Hamburg; Max Planck Institute for Meteorology; Institute for Geophysics and Meteorology, University of Cologne; DLR Institute for Physics of the Atmosphere, German Aerospace Center';
information.Contact_person = 'Heike Konow (heike.konow@uni-hamburg.de)';
information.Source = instrumentNames{indInstr,2}; % HAMP radar, HAMP radiometer, Vaisala xxx, BAHAMAS
information.Conventions = 'CF-1.6 where applicable';
% information.Version = '';
information.Author = 'Konow, Heike; Jacob, Marek; Ewald, Florian; Ament, Felix; Crewell, Susanne; Hagen, Martin; Hirsch, Lutz; Jansen, Friedhelm; Mech, Mario; Stevens, Bjorn';
information.Comment = 'none'; %add  the comment from the input
information.Level = 'l1';
information.Version_in_database = ['v' versionInDatabase]; %add the versionInDatabase from the input 
%information.Licence = 'For non-commercial use only. This data is subject to the SAMD data policy to be found at 
%www.icdc.cen.uni-hamburg.de/projekte/samd.html and in the SAMD Observation Data Product standard.';
information.Licence = 'Creative Commons Attribution NonCommercial ShareAlike 4.0 International (CC BY-NC-SA 4.0)';
% information.Dependencies = 'external';
