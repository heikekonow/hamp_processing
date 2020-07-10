clear; close all

filepath = '/Users/heike/Documents/eurec4a/data_processing/EUREC4A_campaignData/all_nc/radar_20200124_v0.5.nc';
z = ncread(filepath, 'dBZ');
t = ncread(filepath,'time');
h = ncread(filepath,'height');
figure
imagesc(t, h, z)
addWhiteToColormap
set(gca, 'YDir', 'normal')
xlim([1579876947.7374          1579877340.72291])
ylim([-15          2562.41211782406])


I = zeros(size(z));
I(~isinf(z)) = 1;
I(isnan(z)) = 0;
figure
imagesc(t, h, I)
set(gca, 'YDir', 'normal')
xlim([1579876947.7374          1579877340.72291])
ylim([-15          2562.41211782406])

%%
se = strel('square',2);
J = imopen(I, se);

%%
K = imclose(I, se);
L = imopen(K, se);

figure
imagesc(t, h, L)
set(gca, 'YDir', 'normal')
xlim([1579876947.7374          1579877340.72291])
ylim([-15          2562.41211782406])
title('L')

%%
figure
imagesc(t, h, J)
set(gca, 'YDir', 'normal')
xlim([1579876947.7374          1579877340.72291])
ylim([-15          2562.41211782406])
title('J')

%%
l = logical(L);

% zn = ones(size(z)) .* -888;
zn = nan(size(z));
zn(l) = z(l);
zn(isinf(z)) = -inf;

figure
imagesc(t, h, zn)
set(gca, 'YDir', 'normal')
addWhiteToColormap
xlim([1579876947.7374          1579877340.72291])
ylim([-15          2562.41211782406])
title('zn')