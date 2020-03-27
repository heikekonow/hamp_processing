function addWhiteToColormap(varargin)


%save current colormap to variable
if nargin>=1
    figure_handle = varargin{1};
    cm = colormap(figure_handle);
else
    cm = colormap;
end

% add white as first color
cm = [1 1 1;cm];

% set as new colormap
if nargin>=1
    colormap(figure_handle,cm)
else
    colormap(cm)
end

end