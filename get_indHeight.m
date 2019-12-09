%% get_indHeight
%   get_indHeight - Gets indices in measurement height array that correspond
%   with uniform heights
%
%   Syntax:  indHeight = get_indHeight(uniHeight,instrHeight,varargin)
%
%   Inputs:
%       uniHeight - Array of uniform height intervals
%       instrHeight - Array with measurement heights
%       varargin - Possible additional string ('bahamas') to work with
%                  bahamas data
%
%   Outputs:
%       indHeight - Array of height indices corresponding to uniform
%                   heights
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   Version history:
%       #0 - originally separate functions for normal and Bahamas data
%       #1 - combination of files get_indHeight.m and get_indHeightBahamas.m
%           with additional input string ('bahamas')
%
%   See also: 
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   March 2016; Last revision: June 2016

%%
function indHeight = get_indHeight(uniHeight,instrHeight,varargin)

%------------- BEGIN CODE --------------

% If no extra information is provided
if nargin==2
    % Preallocate
    indHeight = nan(length(uniHeight),1);
    % Loop all uniform height intervals
    for i=1:length(uniHeight)
        % Calculate difference between each height interval and all others
        absDifference = abs(instrHeight-uniHeight(i));

        % Find index of minimal height difference, i.e. the height interval
        % closest to selected uniform height interval
        indMinim = find(absDifference==min(absDifference),1,'first');

        % Check to see if height difference is not too large
        if absDifference(indMinim)<29
            % Save height index
            indHeight(i) = indMinim;
        end

    end
% If additional info is given
elseif nargin==3
    % Check Name
    if strcmp(varargin{1},'bahamas')
        indHeight = nan(length(instrHeight),1);
        % Loop all instrument heights
        for i=1:length(instrHeight)
        % Calculate difference between each height interval and all others
            absDifference = abs(uniHeight-instrHeight(i));
            
            % If instrument height is not nan
            if ~isnan(instrHeight(i))
                
                % Find index of minimal height difference, i.e. the height interval
                % closest to selected instrument height interval
                indMinim = find(absDifference==min(absDifference),1,'first');
                
                % Check to see if height difference is not too large
                if absDifference(indMinim)<29
                    % Save height index
                    indHeight(i) = indMinim;
                end
            end

        end
    else
        error('Only Bahamas is implemented. Use argument ''bahamas''.')
    end
else
     error('Wrong number of input arguments')
end

end

%------------- END OF CODE --------------