%% getVersionInfo
%   getVersionInfo - function for getting version history information about
%           unified grid data
%
%   Syntax:  versionInfo = getVersionInfo(version,subversion,varargin)
%
%   Inputs:
%       version - Version number
%       subversion - Subversion number
%       'all'   - optional input to get all previous information until
%                 given version/subversion
%
%   Outputs:
%       versionInfo - cell with string(s)
%
%   Example: 
%       versionInfo = 
%             'v0.0: Raw data without any modification'
%             'v0.1: Lidar data added'
%
%   Other m-files required: dataVersionInfo
%
%
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   September 2016; Last revision: 

%%
function versionInfo = getVersionInfo_eurec4a(version,subversion,varargin)

% Read information
versionInfoIn = dataVersionInfo_eurec4a;

% Find indices for given version and subversion number
indV = cell2mat(versionInfoIn(:,1))==version;
indS = cell2mat(versionInfoIn(:,2))==subversion;

% Find index for current version/subversion combination
indUse = find(indV&indS);

% If only information of given version is wanted
if nargin==2
    % Write information to variable
    versionInfo = ...
      ['v' num2str(version) '.' num2str(subversion) ': ' versionInfoIn{indUse,3}];

% If all previous informations are wante
elseif strcmp(varargin,'all')
    % Get all entries
    versionNums = versionInfoIn(1:indUse,1);
    subversionNums = versionInfoIn(1:indUse,2);
    versionInfoText = versionInfoIn(1:indUse,3);
    
    % Preallocate
    versionInfo = cell(numel(versionNums),1);
    
    % Loop all entries that should be considered
    for i=1:length(versionNums)
        % Write information to variable
        versionInfo{i} = ...
            ['v' num2str(versionNums{i}) '.' num2str(subversionNums{i}) ': ' ...
                versionInfoText{i}];
    end
end