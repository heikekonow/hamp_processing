


function tooltipstr(str)
    set(datacursormode(gcf),'UpdateFcn',{@myupdatefcn, str});


function txt = myupdatefcn(~,event_obj,str)
    pos = get(event_obj,'Position');
    px = sprintf(str,pos(1));
    py = sprintf(str,pos(2));
    txt = {['X: ' , px],['Y: ' , py]};
end

end