function guiViewFEModelWindow(handles, Status)
Options = getappdata(0,'Options');

global tyLINK tyNODE

switch Status
    case 1 % create
        % Create st7 model window
        iErr = calllib('St7API', 'St7CreateModelWindow', Options.St7.uID);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7HideWindowTopPanel', Options.St7.uID);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7HideWindowToolbar', Options.St7.uID);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7ShowWindowStatusBar', Options.St7.uID);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7RotateModel', Options.St7.uID, 25, 50, 0);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7HideEntity', Options.St7.uID, tyLINK);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7HideEntity', Options.St7.uID, tyNODE);
        HandleError(iErr);
        
        % Get position of UI panel that will hold St7 window
        windowsize = get(handles.uipanelModelWindow, 'Position');
        
        position(1) = windowsize(1);
        position(2) = windowsize(2); % Height of matlab menu bar
        position(3) = windowsize(3);
        position(4) = windowsize(4);
              
        % get windows hWnd for main gui
        jf = handle(get(handle(handles.guiFEModelWindow_gui),'JavaFrame'));
        jframe = jf.getFigurePanelContainer.getParent.getTopLevelAncestor;
        hwnd = jframe.getHWnd;
        
        % Display model window in component
        iErr = calllib('St7API', 'St7SetModelWindowParent', Options.St7.uID, hwnd);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7PositionModelWindow', Options.St7.uID, position(1), position(2), position(3), position(4));
        HandleError(iErr);
        iErr = calllib('St7API', 'St7ShowModelWindow', Options.St7.uID);
        HandleError(iErr);
        
        % Adjust angle of view
        iErr = calllib('St7API', 'St7RotateModel', Options.St7.uID, -60, 0, 60);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7RedrawModel', Options.St7.uID,1);
        HandleError(iErr);
    case 0 % destroy model window
        iErr = calllib('St7API', 'St7DestroyModelWindow', Options.St7.uID);
        HandleError(iErr);
    case 2 % refresh
        iErr = calllib('St7API', 'St7RedrawModel', Options.St7.uID,1);
        HandleError(iErr);
end
