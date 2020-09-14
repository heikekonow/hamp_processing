function removeScientificLabel(axesHandle,axesString)

if strcmp(axesString,'x')
    tickstring = 'XTick';
elseif strcmp(axesString,'y')
    tickstring = 'YTick';
end

for i=1:length(axesHandle)
    curtick = get(axesHandle(i),tickstring);
    if strcmp(axesString,'x')
        set(axesHandle(i), 'XTickLabel', cellstr(num2str(curtick(:))));
    elseif strcmp(axesString,'y')
        set(axesHandle(i), 'YTickLabel', cellstr(num2str(curtick(:))));
    end
end