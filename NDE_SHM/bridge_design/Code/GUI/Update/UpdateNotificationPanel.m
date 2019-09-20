function UpdateNotificationPanel(hObject, msg, type)
switch type
    case 'append'
        panel = get(hObject, 'string');
        panel{end} = [panel{end} msg];
    case 'new'
        panel = get(hObject, 'string');
        panel{end+1} = msg;
    case 'replace'
        panel = msg;
    case 'delete'
        panel = [];
end

set(hObject, 'string', panel);
end