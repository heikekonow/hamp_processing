function out = cellflat(celllist)
% CELLFLAT is a helper function to flatten nested cell arrays. 
% 
% CELLFLAT(celllist) searches every cell element in cellist and put them on
% the top most level. Therefore, CELLFLAT linearizes a cell array tree
% structure. 
%
% Example: cellflat({[1 2 3], [4 5 6],{[7 8 9 10],[11 12 13 14 15]},{'abc',{'defg','hijk'},'lmnop'}}) 
% 
% Output: 
%Columns 1 through 7
%     [1x3 double]    [1x3 double]    [1x4 double]    [1x5 double]    'abc'    'defg'    'hijk'
%   Column 8 
%     'lmnop'
%
% cellflat(({{1 {2 3}} 'z' {'y' 'x' 'w'} {4 @iscell 5} 6}) )
% Output: 
% [1]    [2]    [3]    'z'    'y'    'x'    'w'    [4]    @iscell    [5]    [6]
%
% Version: 1.0
% Author: Yung-Yeh Chang, Ph.D. (yungyeh@hotmail.com)
% Date: 12/31/2014
% Copyright 2015, Yung-Yeh Chang, Ph.D.
% See Also: cell
%
% Copyright (c) 2017, Yung-Yeh
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if ~iscell(celllist)
    error('CELLFLAT:ImproperInputAugument','Input argument must be a cell array');
end
out = {};
for idx_c = 1:numel(celllist)
    if iscell(celllist{idx_c})
        out = [out cellflat(celllist{idx_c})];
    else
        out = [out celllist(idx_c)];
    end
end