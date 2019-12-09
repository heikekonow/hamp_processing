function ind = indRadiometerTimeJumps(radiometerTime,varargin)

oneSecond = 1/24/60/60;

diffTime = diff(radiometerTime);

if nargin==1
    ind = abs(diffTime)>60*oneSecond;
else
    ind = abs(diffTime)>varargin{1}*oneSecond;
end