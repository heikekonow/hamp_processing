function setFontSize(figurehandle,fontsize,varargin)

% Get figure handles
object_handles = findobj(figurehandle);
% Get handles of text objects
text_handles = findall(object_handles,'Type','text');
% Get handles of colorbar objects
colorbar_handles = findall(object_handles,'Type','Colorbar');
% Get handles of axes
axes_handles = findall(object_handles,'Type','Axes');
% Get handles of figure's children
children_handles = get(figurehandle,'Children');
% Get handle of legend
legend_handles = findall(children_handles,'Type','legend');

% Extra info is specified, e.g. 'map' -> use functions to modify map plots
if nargin>2
    if ~isempty(axes_handles)
        for i=1:length(axes_handles)
            setm(axes_handles(i),'FontSize',fontsize)
        end
    end
end

% If colorbar exists
if ~isempty(colorbar_handles)
    % Loop all handles
    for i=1:length(colorbar_handles)
        % Set font size
        set(colorbar_handles(i),'FontSize',fontsize)
    end
end

% If axes handles were found
if ~isempty(axes_handles)
    % Loop all handles
    for i=1:length(axes_handles)
        
        if ~strcmp(axes_handles(i).Type, 'axestoolbar')
            % Set font size
            set(axes_handles(i),'FontSize',fontsize)
        end
    end
end

% if ~isempty(text_handles)
%     for i=1:length(text_handles)
%         set(text_handles(i),'FontSize',fontsize)
%     end
% end

% If legend exists
if ~isempty(legend_handles)
    % Loop all handles
    for i=1:length(legend_handles)
        % Set font size
        set(legend_handles(i),'FontSize',fontsize)
    end
end

%%%%%
% H. Konow; heike.konow@uni-hamburg.de, November 2016
%%%%%