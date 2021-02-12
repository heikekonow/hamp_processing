%% freqString = getHAMPfrequencyString(frequency)
%
% Use this function to get the module name string for a given frequency
%
% Explanation for different radiometer modules
% 1: 183,   f>180           (G band)
% 2: 11990, f>=90 & f<180   (WF band)
% 3: KV,    f<90            (KV band)

function freqString = getHAMPfrequencyString(frequency)


% Translate frequency to string from table above
if frequency >= 180
    freqString = '183';
elseif frequency>=90 && frequency<180
    freqString = '11990';
elseif frequency < 90
    freqString = 'KV';
else
    error('Frequency not found')
end