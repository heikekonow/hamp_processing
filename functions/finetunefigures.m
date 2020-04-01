% Program to tune figures for slightly different look

function finetunefigures(varargin)

% Set Background Color to white
set(gcf, 'color','white');
% No Box, Ticks pointing out
set(gca, 'Box','off','TickDir','out');
% Grid
% grid on;
if nargin > 0
    set(gca, 'FontSize', 12,'FontWeight','bold')
    lh = get(gca,'Children');
    set(lh,'LineWidth',2)
end

setFontSize(gca,14)

end