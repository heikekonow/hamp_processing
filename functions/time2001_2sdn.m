%% time2001_2sdn
%   time2001_2sdn - Convert Time (seconds since 01.01.1970 00:00:00) to
%                   Matlab serial date numbers
%
%   Syntax:  tSDN = time2001_2sdn(t2001)
%
%   Inputs:
%       t2001 - time in seconds since 01.01.2001 00:00:00
%
%   Outputs:
%       tSDN - time as Serial Date Number
%
%   Example: 
%       t2001 = 492331967;
%       unixtime2sdn(t2001)
%
%       ans =
%           736550.286655093
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: sdn2unixtime
%
%   Author: Dr. Heike Konow
%   Meteorological Institute, Hamburg University
%   email address: heike.konow@uni-hamburg.de
%   Website: http://www.mi.uni-hamburg.de/
%   January 2014; Last revision: June 2015

%%
function tSDN = time2001_2sdn(t2001)
% Convert Time 2001 (seconds since 01.01.2001 00:00:00) to Matlab serial
% date number

secondsPerDay = 86400;

if isinteger(t2001)
    t2001 = double(t2001);
end

tSDN = t2001 ./ secondsPerDay + datenum(2001,1,1,0,0,0);