function cb = adjustColorMap(limits,colors,data,imagehandle,varargin)

c = ones([size(data) 3]);
if nargin>4
    draw_colorbar = 1;
else
    draw_colorbar = 0;
end

%%

if max(colors)>1
    colors = colors./255;
end

colorbar_mindist = min(diff(limits));

%% function

for i=1:length(limits)-1

    r_val = colors(i,1);
    g_val = colors(i,2);
    b_val = colors(i,3);
    
    if limits(i)==limits(i+1)
        [n,m] = ind2sub(size(data),find(data==limits(i+1)));
    else
        [n,m] = ind2sub(size(data),find(data>limits(i)&data<=limits(i+1)));
    end

    matrix_size = [size(data) 3];
    matrix_index_third_dim = {repmat(1,length(n),1),...
                              repmat(2,length(n),1),...
                              repmat(3,length(n),1)};

    r_ind = sub2ind(matrix_size,n,m,matrix_index_third_dim{1});
    g_ind = sub2ind(matrix_size,n,m,matrix_index_third_dim{2});
    b_ind = sub2ind(matrix_size,n,m,matrix_index_third_dim{3});

    c(r_ind) = r_val;
    c(g_ind) = g_val;
    c(b_ind) = b_val;

    imagehandle.CData = c;
    
    colorbar_distlength(i) = (limits(i+1)-limits(i))/min(diff(limits));
    
    if colorbar_distlength(i)==1
        colorbar_distlength(i) = colorbar_distlength * 5;
    end
    
    colorbar_colors{i} = repmat([r_val,g_val,b_val],int16(colorbar_distlength(i)),1);
end

% Add colors to values greater than upper limit
[n,m] = ind2sub(size(data),find(data>limits(end)));
matrix_size = [size(data) 3];
matrix_index_third_dim = {repmat(1,length(n),1),...
repmat(2,length(n),1),...
repmat(3,length(n),1)};
r_ind = sub2ind(matrix_size,n,m,matrix_index_third_dim{1});
g_ind = sub2ind(matrix_size,n,m,matrix_index_third_dim{2});
b_ind = sub2ind(matrix_size,n,m,matrix_index_third_dim{3});
c(r_ind) = r_val;
c(g_ind) = g_val;
c(b_ind) = b_val;
imagehandle.CData = c;

d = cellfun(@(x) size(x,1),colorbar_colors);
if sum(d(1) == d)>1
    colorbar_colors{1} = colorbar_colors{1}(1,:);
    colorbar_distlength(1) = 1;
end

% Colorbar
colorbar_colors = cell2mat(colorbar_colors');

colormap(colorbar_colors)

if draw_colorbar
    ch = colorbar;
    
    if limits(1)~=0
        ticklabels = limits;
        ticklabels(1) = [];
        
        t(1) = 0;
        for i=1:length(colorbar_distlength)
            t(i+1) = t(i) + colorbar_distlength(i)/sum(colorbar_distlength);
        end
    else
        ticklabels = limits;
        ticklabels(2) = [];

        t(1) = limits(1);
        for i=1:length(colorbar_distlength)
            t(i+1) = t(i) + colorbar_distlength(i)/sum(colorbar_distlength);
        end
    end

    ch.Ticks = t(2:end);
    ch.TickLabels = ticklabels;
    
    if nargout > 0
        cb = ch;
    end
end

%%%%%
% H. Konow; heike.konow@uni-hamburg.de, January 2017
%%%%%
