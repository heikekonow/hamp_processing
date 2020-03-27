function plotLegendAsColoredText(axeshandle,legendstring,initialPosition,shiftPos)

colors = get(axeshandle,'ColorOrder');

if size(colors,1)<length(legendstring)
    mult = ceil(length(legendstring)/size(colors,1));
    
    colors = repmat(colors,mult,1);
end
    
th(1) = annotation('textbox','Position',[initialPosition(1),initialPosition(2),0.03,0.03],...
                   'String',legendstring{1},'Color',colors(1,:),'EdgeColor','none',...
                   'FontSize',14);

pos = [initialPosition(1)+shiftPos,initialPosition(2)];

for i=2:length(legendstring)
    th(i) = annotation('textbox','Position',[pos(1),pos(2),0.03,0.03],...
                   'String',legendstring{i},'Color',colors(i,:),'EdgeColor','none',...
                   'FontSize',14);
    
    pos = [pos(1)+shiftPos pos(2)];
end