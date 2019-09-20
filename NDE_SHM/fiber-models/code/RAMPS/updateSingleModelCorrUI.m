function updateSingleModelCorrUI(handles,Parameters)
% JBB 627/14
% handles - handles structure for figures in gui
% Parameters - structure containing the necessary data for plotting

%% Get slider values
% Slider for Axes1
slider1 = get(handles.sliderValue_1,'Value');
% Slider for Axes2
slider2 = get(handles.sliderValue_2,'Value');
% Slider for Axes3
slider3 = get(handles.sliderValue_3,'Value');

if isfield(Parameters,'CorrHistory')
    % Get iteration number
    index = size(Parameters.CorrHistory.FreqRes,2);
    % Get number of Parameters
    param = size(Parameters.CorrHistory.Alpha,1);

    %% Plot model properties data on semilog y-axis
    % Axes 1
    PlotEvent(handles.axesValue_1,Parameters.CorrHistory.Alpha(slider1,:),'semilogy');
    set(handles.axes1_title,'string', Parameters.CorrHistory.IndKey{slider1});
    set(handles.axesValue_1,'Ylim',[0.9*Parameters.CorrAlpha(slider1,2) 1.1*Parameters.CorrAlpha(slider1,3)]);

    % Axes 2
    if param>1
    PlotEvent(handles.axesValue_2,Parameters.CorrHistory.Alpha(slider2,:),'semilogy');
    set(handles.axes2_title,'string', Parameters.CorrHistory.IndKey{slider2});
    set(handles.axesValue_2,'Ylim',[0.9*Parameters.CorrAlpha(slider2,2) 1.1*Parameters.CorrAlpha(slider2,3)]);
    else
        set(handles.axes2_title,'enable','off');
        set(handles.axesValue_2,'visible','off');
        set(handles.sliderValue_2,'visible','off');
    end

    % Axes 3
    if param>2
    PlotEvent(handles.axesValue_3,Parameters.CorrHistory.Alpha(slider3,:),'semilogy');
    set(handles.axes3_title,'string', Parameters.CorrHistory.IndKey{slider3});
    set(handles.axesValue_3,'Ylim',[0.9*Parameters.CorrAlpha(slider3,2) 1.1*Parameters.CorrAlpha(slider3,3)]);
    else
        set(handles.axes3_title,'enable','off');
        set(handles.axesValue_3,'visible','off');
        set(handles.sliderValue_3,'visible','off');
    end
    
    %% Draw Mode Shape
    % Get current selection
    modeselect = getappdata(handles.guiSingleModelCorrelation,'modeselect');
    if isempty(modeselect)
        modeselect = [1 1];
    end
    ShapeNo = modeselect(1);
    ShapeSource = modeselect(2); % 1 = analytical, 2 = experimental
    
    % Get scale edit value
    scale = str2double(get(handles.editScale,'string'));
    % Get COMAC selection value
    cmValue = get(handles.checkCOMAC,'value');
    
    
    % Get shape data
    meshdata = getappdata(0,'meshData');
    testData = getappdata(0,'testData');

    % Plot shape
    xb = testData.xb;
    yb = testData.yb;
    zb = zeros(length(xb),1);
    
    if ShapeSource == 1
        if ShapeNo>size(meshdata.z,2)
            fprintf('Select a non-zero frequency')
            return
        end
        
        if cmValue
            CM = Parameters.CorrHistory.COMAC(:,end);
        else
            CM = [];
        end
        
        X = testData.coord(:,1);
        Y = testData.coord(:,2);
        Z = Parameters.CorrHistory.AnaDisp(:,ShapeNo,end);
        
        modeInterpGeneral(handles.axesShape,X,Y,Z,xb,yb,zb,scale,CM);
    else
        if ShapeNo>size(testData.U,2)
            fprintf('Select a non-zero frequency')
            return
        end
        
        validNode = ~isnan(testData.U(:,ShapeNo));
        
        if cmValue
            CM = Parameters.CorrHistory.COMAC(validNode,end);
        else
            CM = [];
        end
        
        X = testData.coord(validNode,1);
        Y = testData.coord(validNode,2);
        Z = testData.U(validNode,ShapeNo);
        
        modeInterpGeneral(handles.axesShape, X,Y,Z, xb,yb,zb, scale,CM)
        axes(handles.axesShape)
        axis equal
    end
    
else
    
    %% Draw Mode Shape
    % Get current selection
    modeselect = getappdata(handles.guiSingleModelCorrelation,'modeselect');
    if isempty(modeselect)
        modeselect = [1 1];
    end
    ShapeNo = modeselect(1);
    ShapeSource = modeselect(2); % 1 = analytical, 2 = experimental
    
    % Get scale edit value
    scale = str2double(get(handles.editScale,'string'));

    % Get shape data
    meshdata = getappdata(0,'meshData');
    testData = getappdata(0,'testData');
    
    if isfield(Parameters,'CorrHistory');
    meshdata.z = Parameters.CorrHistory.AnaDisp(:,:,end);
    end

    % Plot shape
    xb = testData.xb;
    yb = testData.yb;
    zb = zeros(length(xb),1);
    if ShapeSource == 1
        if ShapeNo>size(meshdata.z,2)
            fprintf('Select a non-zero frequency')
            return
        end
        X = meshdata.x;
        Y = meshdata.y;
        Z = meshdata.z(:,ShapeNo);
        
        modeModelGeneral(handles.axesShape,X,Y,Z,scale,[]);
    else
        if ShapeNo>size(testData.U,2)
            fprintf('Select a non-zero frequency')
            return
        end
        validNode = ~isnan(testData.U(:,ShapeNo));
        X = testData.coord(validNode,1);
        Y = testData.coord(validNode,2);
        Z = testData.U(validNode,ShapeNo);
        
        modeInterpGeneral(handles.axesShape, X,Y,Z, xb,yb,zb, scale,[])
        axes(handles.axesShape)
        axis equal
    end

    
end

% formatColorScheme(handles.guiSingleModelCorrelation);