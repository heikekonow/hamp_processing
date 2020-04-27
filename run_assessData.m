%% run_assessData
%   run_assessData - assess radar and radiometer data to identify errors.
%   See description in code below
%
%   Syntax:  run_assessData
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   April 2020; Last revision: April 2020

%------------- BEGIN CODE --------------

%% Radar

% To assess quality of radar data, use the script below. 
% 1. In a first step set figures=true to go through all flights and identify 
%    error indices. These should be noted in the file radarErrorsLookup.m
% 2. Set calc=true to calculate percentages of errors

% %%% Set parameters %%%
% If figures should be produced
figures = false;
% If error time steps should be calculated from indices
calc = false;
% Set campaign to analyse
campaign = 'EUREC4A';
% Set minimum altitude for observations
minalt = 4000;
% %%%%%%%%%%%%%%%%%%%%%%

assess_radar_data(figures, calc, campaign, minalt)

%% Radiometer

% To assess quality of radiometer data, use the script below. 
% 1. In a first step set figures=true to go through all flights and identify 
%    error indices. These should be noted in the file radiometerErrorsLookupInt.m
% 2. Set calc=true to calculate percentages of errors
% 3. Set overview=true for overview figure

% %%% Set parameters %%%
% Set if figures should be produced
figures = false;
% Set if error time steps should be calculated from indices
calc = false;
% Set if overview figure should be produced
overview = true;
% Set campaign to analyse
campaign = 'EUREC4A';
% %%%%%%%%%%%%%%%%%%%%%%

assess_radiometer_data(figures, calc, overview, campaign)

%------------- END OF CODE --------------