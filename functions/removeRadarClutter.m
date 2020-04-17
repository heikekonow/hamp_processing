function Z = removeRadarClutter(Z)

%% Preparation
% Replace inf with nan
Z(isinf(Z)) = nan;
% Replace radar signal with 1
Z(~isnan(Z)) = 1;

%% 1: shift left/right
% Shift matrix left/right
Z_left = [Z(:,2:end) nan(size(Z,1),1)];
Z_right = [nan(size(Z,1),1) Z(:,1:end-1)];

% Copy variable
y = Z;
% Mark pixels with no left/right neighboring signal pixels
y((Z==1) & isnan(Z-Z_left) & isnan(Z-Z_right)) = 5;


%% 2: shift up/down
% Shift remaing matrix up/down
y_up = [y(2:end,:);nan(1,size(y,2))];
y_down = [nan(1,size(y,2));y(1:end-1,:)];

% Copy variable
a = y;
% Mark pixels with no neighboring signal pixels
a((y==1) & isnan(y-y_up) & isnan(y-y_down)) = 7;

%% Apply
a(a~=1) = nan;

%% 3: shift left/right
% Shift matrix left/right
a_left = [a(:,2:end) nan(size(a,1),1)];
a_right = [nan(size(a,1),1) a(:,1:end-1)];

% Copy variable
b = a;
% Mark pixels with no neighboring signal pixels
b((a==1) & isnan(a-a_left) & isnan(a-a_right)) = 9;

%% Apply
b(b~=1) = nan;

%% Shift up/down
% Shift matrix up/down
b_up = [b(2:end,:);nan(1,size(b,2))];
b_down = [nan(1,size(b,2));b(1:end-1,:)];

%% Output variable
% Copy variable
Z = b;
% Mark pixels with no neighboring signal pixels
Z((b==1) & isnan(b-b_up) & isnan(b-b_down)) = 9;

Z(Z~=1) = nan;