function [lookuptable,instrOrder] = varnames_lookup

uniVarNames = {
    'uniTime'
    'uniHeight'
    'uniRadiometer11990_freq'
    'uniRadiometer183_freq'
    'uniRadiometerKV_freq'
    'uniSondeNumber'
    'flightdate'
    'uniBacksc'
    'uniBahamasP'
    'uniBahamasP_1d'
    'uniBahamasRH'
    'uniBahamasRH_1d'
    'uniBahamasT'
    'uniBahamasT_1d'
    'uniBahamasU'
    'uniBahamasU_1d'
    'uniBahamasV'
    'uniBahamasV_1d'
    'uniBahamasW'
    'uniBahamasW_1d'
    'uniBahamasalt'
    'uniBahamasalt_1d'
    'uniBahamasheading'
    'uniBahamasheading_1d'
    'uniBahamaslat'
    'uniBahamaslat_1d'
    'uniBahamaslon'
    'uniBahamaslon_1d'
    'uniBahamasmixratio'
    'uniBahamasmixratio_1d'
    'uniBahamaspitch'
    'uniBahamaspitch_1d'
    'uniBahamasroll'
    'uniBahamasroll_1d'
    'uniBahamastheta'
    'uniBahamastheta_1d'
    'uniBahamasspeed_gnd'
    'uniBahamasspeed_gnd_1d'
    'uniBahamasvv'
    'uniBahamasvv_1d'
    'uniLDRg'
    'uniMR'
    'uniRMSg'
    'uniRadiometer11990'
    'uniRadiometer183'
    'uniRadiometerKV'
    'uniSNRg'
    'uniSondeLaunchTime'
    'uniSondedp'
    'uniSondedp_inst'
    'uniSondedp_sondes'
    'uniSondedz'
    'uniSondedz_inst'
    'uniSondedz_sondes'
    'uniSondelat'
    'uniSondelat_inst'
    'uniSondelat_sondes'
    'uniSondelon'
    'uniSondelon_inst'
    'uniSondelon_sondes'
    'uniSondemr'
    'uniSondemr_inst'
    'uniSondemr_sondes'
    'uniSondepres'
    'uniSondepres_inst'
    'uniSondepres_sondes'
    'uniSonderh'
    'uniSonderh_inst'
    'uniSonderh_sondes'
    'uniSondetdry'
    'uniSondetdry_inst'
    'uniSondetdry_sondes'
    'uniSondetheta'
    'uniSondetheta_e'
    'uniSondetheta_e_inst'
    'uniSondetheta_e_sondes'
    'uniSondetheta_inst'
    'uniSondetheta_sondes'
    'uniSondetheta_v'
    'uniSondetheta_v_inst'
    'uniSondetheta_v_sondes'
    'uniSondeu_wind'
    'uniSondeu_wind_inst'
    'uniSondeu_wind_sondes'
    'uniSondev_wind'
    'uniSondev_wind_inst'
    'uniSondev_wind_sondes'
    'uniSondevt'
    'uniSondevt_inst'
    'uniSondevt_sondes'
    'uniSondewdir'
    'uniSondewdir_inst'
    'uniSondewdir_sondes'
    'uniSondewspd'
    'uniSondewspd_inst'
    'uniSondewspd_sondes'
    'uniVELg'
    'uniZg'
    'unidBZg'
    'uniRadiometer'
    'uniRadiometer_freq'
    'radarInfoMask'
    'uniSondesonde_time'
    'uniSondesonde_time_inst'
    'uniSondesonde_time_sondes'
    'uniSondedp_intFlag'
    'uniSondedz_intFlag'
    'uniSondelat_intFlag'
    'uniSondelon_intFlag'
    'uniSondemr_intFlag'
    'uniSondepres_intFlag'
    'uniSonderh_intFlag'
    'uniSondetdry_intFlag'
    'uniSondetheta_e_intFlag'
    'uniSondetheta_intFlag'
    'uniSondetheta_v_intFlag'
    'uniSondeu_wind_intFlag'
    'uniSondev_wind_intFlag'
    'uniSondevt_intFlag'
    'uniSondewdir_intFlag'
    'uniSondewspd_intFlag' 
    'uniBahamasmixratio_interpolateFlag'
    'uniBahamasP_interpolateFlag'
    'uniBahamasRH_interpolateFlag'
    'uniBahamastheta_interpolateFlag'
    'uniBahamasU_interpolateFlag'
    'uniBahamasV_interpolateFlag'
    'uniBahamasW_interpolateFlag'
    'uniBahamasalt_interpolateFlag'
    'uniBahamasheading_interpolateFlag'
    'uniBahamaspitch_interpolateFlag'
    'uniBahamasroll_interpolateFlag'
    'uniBahamaslat_interpolateFlag'
    'uniBahamaslon_interpolateFlag'
    'uniBahamasT_interpolateFlag'
    'uniBahamasspeed_gnd_interpolateFlag'
    'uniBahamasvv_interpolateFlag'
    };

bahamasVarNames = {
    'time'
    'height'
    ''
    ''
    ''
    ''
    'date'
    ''
    'p_mat'
    'p'
    'rh_mat'
    'rh'
    'ta_mat'
    'ta'
    'u_mat'
    'u'
    'v_mat'
    'v'
    'w_mat'
    'w'
    'altitude_mat'
    'altitude'
    'heading_mat'
    'heading'
    'lat_mat'
    'lat'
    'lon_mat'
    'lon'
    'mr_mat'
    'mr'
    'pitch_mat'
    'pitch'
    'roll_mat'
    'roll'
    'theta_mat'
    'theta'
    'gs_mat'
    'gs'
    'vel_mat'
    'vel'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'mr_intFlag'
    'p_intFlag'
    'rh_intFlag'
    'theta_intFlag'
    'u_intFlag'
    'v_intFlag'
    'w_intFlag'
    'altitude_intFlag'
    'heading_intFlag'
    'pitch_intFlag'
    'roll_intFlag'
    'lat_intFlag'
    'lon_intFlag'
    'ta_intFlag'
    'gs_intFlag'
    'vv_intFlag'
    };
    


radarVarNames = {
    'time'
    'height'
    ''
    ''
    ''
    ''
    'date'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'LDR'
    ''
    'RMS'
    ''
    ''
    ''
    'SNR'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'VEL'
    'Z'
    'dBZ'
    ''
    ''
    'data_flag'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    };
    


sondeVarNames = {
    'time'
    'height'
    ''
    ''
    ''
    'sonde_number'
    'date'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'launch_time'
    'dp_mat'
    'dp_inst'
    'dp'
    'dz_mat'
    'dz_inst'
    'dz'
    'lat_mat'
    'lat_inst'
    'lat'
    'lon_mat'
    'lon_inst'
    'lon'
    'mr_mat'
    'mr_inst'
    'mr'
    'p_mat'
    'p_inst'
    'p'
    'rh_mat'
    'rh_inst'
    'rh'
    'ta_mat'
    'ta_inst'
    'ta'
    'theta_mat'
    'theta_e_mat'
    'theta_e_inst'
    'theta_e'
    'theta_inst'
    'theta'
    'theta_v_mat'
    'theta_v_inst'
    'theta_v'
    'u_mat'
    'u_inst'
    'u'
    'v_mat'
    'v_inst'
    'v'
    'tv_mat'
    'tv_inst'
    'tv'
    'dir_mat'
    'dir_inst'
    'dir'
    'spd_mat'
    'spd_inst'
    'spd'
    ''
    ''
    ''
    ''
    ''
    ''
    'sonde_time_mat'
    'sonde_time_inst'
    'sonde_time'
    'dp_intFlag'
    'dz_intFlag'
    'lat_intFlag'
    'lon_intFlag'
    'mr_intFlag'
    'pres_intFlag'
    'rh_intFlag'
    'ta_intFlag'
    'theta_e_intFlag'
    'theta_intFlag'
    'theta_v_intFlag'
    'u_wind_intFlag'
    'v_wind_intFlag'
    'tv_intFlag'
    'wdir_intFlag'
    'spd_intFlag'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    };
    


radiometerVarNames = {
    'time'
    ''
    'frequency'
    'frequency'
    'frequency'
    ''
    'date'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'tb'
    'tb'
    'tb'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'tb'
    'frequency'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    };
    


lidarVarNames = {
    'time'
    'height'
    ''
    ''
    ''
    ''
    'date'
    'bsc'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    'mr'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    };

lookuptable = [uniVarNames,...
                   bahamasVarNames,...
                   radarVarNames,...
                   sondeVarNames,...
                   radiometerVarNames,...
                   lidarVarNames];
instrOrder = {'all','bahamas','radar','dropsondes','radiometer','lidar'};