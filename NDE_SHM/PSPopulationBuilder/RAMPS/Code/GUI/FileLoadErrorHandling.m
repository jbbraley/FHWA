function [Parameters, Options] = FileLoadErrorHandling(Parameters, Options, handles)
% Get app data if needed
if isempty(Parameters)
    Parameters = getappdata(0, 'Parameters');
end
if isempty(Options)
    Options = getappdata(0, 'Options');
end

% Set status
Options.FileOpen.St7Model = 0;
Options.FileOpen.Node = 0;

% update listbox string
set(handles.listboxModelFile, 'string', '');

% Close St7 and Unload API
CloseAndUnload(Options.St7.uID);

% Restart St7
St7Start = 1;
[Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

% Set data to root
setappdata(0, 'Parameters', Parameters);
setappdata(0, 'Options', Options);

% Display metadata loading messages
hObject = handles.listboxNotificationPanel;
msg = 'FAILED';
type = 'append';
UpdateNotificationPanel(hObject, msg, type);
end