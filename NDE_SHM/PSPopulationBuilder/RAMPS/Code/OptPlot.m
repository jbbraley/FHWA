function OptPlot(x,state,Parameters, handles)

%% Get slider values
% Slider for Axes1
slider1 = get(handles.sliderValue_1,'Value');
% Slider for Axes2
slider2 = get(handles.sliderValue_2,'Value');
% Slider for Axes3
slider3 = get(handles.sliderValue_3,'Value');

% Get iteration number
index = size(Parameters.CorrHistory.FreqRes,2);
% Get number of Parameters
param = size(Parameters.CorrHistory.Alpha,1);

Options = getappdata(0,'Options');

switch state
    case 'init'
        if param > 1
            set(handles.sliderValue_1,'enable','on')
            set(handles.sliderValue_1,'Value',1);
            set(handles.sliderValue_1,'min',1,'max',param);
            set(handles.sliderValue_1,'SliderStep',[1/(param-1) 1/(param-1)]);
        else
            set(handles.sliderValue_1,'enable','on')
            set(handles.sliderValue_1,'Value',1);
        end
        
        if param>1
            set(handles.sliderValue_2,'enable','on')
            set(handles.sliderValue_2,'Value',2);
            set(handles.sliderValue_2,'min',1,'max',param);
            set(handles.sliderValue_2,'SliderStep',[1/(param-1) 1/(param-1)]);
        else
            set(handles.sliderValue_2,'enable','off')
            set(handles.axes2_title,'enable','off');
            set(handles.axesValue_2,'visible','off');
            set(handles.sliderValue_2,'Value',1);
        end
        
        if param>2
            set(handles.sliderValue_3,'enable','on')
            set(handles.sliderValue_3,'Value',3);
            set(handles.sliderValue_3,'min',1,'max',param);
            set(handles.sliderValue_3,'SliderStep',[1/(param-1) 1/(param-1)]);
        else
            set(handles.sliderValue_3,'enable','off')
            set(handles.axes3_title,'enable','off');
            set(handles.axesValue_3,'visible','off');
            set(handles.sliderValue_3,'Value',1);
        end
        
    case 'iter'
        % Fill table with Frequency Data
        pad1 = length(Parameters.CorrHistory.AnaFreq(:,end))-length(Parameters.CorrHistory.ExpFreq(:,end));
        data{1} = Parameters.CorrHistory.AnaFreq(:,end);
        data{2} = Parameters.CorrHistory.ExpFreq(:,end);
        data{pad1/abs(pad1)/2+3/2} = [data{pad1/abs(pad1)/2+3/2}; zeros(abs(pad1),1)];
        set(handles.uitableFreq,'data',[data{1} data{2}]);
             
        %% Plot objective function data
        PlotEvent(handles.axesResidual_1,Parameters.CorrHistory.FreqRes,'norm')
        set(handles.axesResidual_1,'Ylim',[-0.1 1.1]);
        PlotEvent(handles.axesResidual_2,Parameters.CorrHistory.MACRes,'norm')
        set(handles.axesResidual_2,'Ylim',[-0.1 1.1]);
                
        %% Draw MAC plot
        axes(handles.axesMAC);
        imagesc(Parameters.CorrHistory.MAC(:,:,end));
        drawnow
        
        % Save MAC plot
        figurenum = int2str(index);
        FigureName = [Options.St7.PathName 'Figures\' Options.St7.FileName(1:end-4) 'MAC' figurenum '.jpg'];
        saveas(handles.axesMAC,FigureName);
        
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

        %% Plot alpha values on semilog y-axis
        % Axes 1
        PlotEvent(handles.axesValue_1,Parameters.CorrHistory.Alpha(slider1,:),'semilogy');
        set(handles.axes1_title,'string', Parameters.CorrHistory.IndKey{slider1});
        set(handles.axesValue_1,'Ylim',[0.9*Parameters.CorrAlpha(slider1,2) 1.1*Parameters.CorrAlpha(slider1,3)]);
        % Axes 2
        if param>1
            name = Parameters.CorrHistory.IndKey{slider2};
            if strcmp(name, 'Composite Ix') || strcmp(name(1:5), 'Fixed') || strcmp(name(1:5), 'Expan')
                plotType = 'norm';
            else
                plotType = 'semilogy';
            end
                PlotEvent(handles.axesValue_2,Parameters.CorrHistory.Alpha(slider2,:),plotType);
                set(handles.axes2_title,'string', Parameters.CorrHistory.IndKey{slider2});
                set(handles.axesValue_2,'Ylim',[0.9*Parameters.CorrAlpha(slider2,2) 1.1*Parameters.CorrAlpha(slider2,3)]);
        end
        % Axes 3
        if param>2
            name = Parameters.CorrHistory.IndKey{slider3};
            if strcmp(name, 'Composite Ix') || strcmp(name(1:5), 'Fixed') || strcmp(name(1:5), 'Expan')
                plotType = 'norm';
            else
                plotType = 'semilogy';
            end
            PlotEvent(handles.axesValue_3,Parameters.CorrHistory.Alpha(slider3,:),plotType);
            set(handles.axes3_title,'string', Parameters.CorrHistory.IndKey{slider3});
            set(handles.axesValue_3,'Ylim',[0.9*Parameters.CorrAlpha(slider2,2) 1.1*Parameters.CorrAlpha(slider2,3)]);
        end
              
    case 'done'   
%         FigureName = [Options.St7.PathName '\Figures\ObjectiveFunction.jpg'];
%         saveas(Obj_handle.parent,FigureName);
%         FigureName = [Options.St7.PathName '\Figures\Stiffness.jpg'];
%         saveas(I_handle.parent,FigureName);
        
    otherwise
end

% formatColorScheme(handles.guiSingleModelCorrelation);
end %OptPlot