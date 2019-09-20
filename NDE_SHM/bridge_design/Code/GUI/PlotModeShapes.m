function PlotModeShapes(plotType)
try
% get data from root
Options = getappdata(0,'Options');
meshData = getappdata(0,'meshData');
testData = getappdata(0,'testData');

handles = Options.handles.guiModelExperimentComparison_gui;

% Get mode shape plot scale
anaScale = Options.GUI.anaScale;
expScale = Options.GUI.expScale;
anaModeNum = Options.GUI.anaModeNum;
expModeNum = Options.GUI.expModeNum;

% Repopulate experimental mode shape plot
switch plotType
    case 'Ana'
        if ~isempty(meshData.U)
            ah = handles.axesAnaModeShape;
            
            % if an coordinate system mesh is available, use that
            x = meshData.x;
            y = meshData.y;
            z = meshData.U(:,anaModeNum)*anaScale;
            
            tri = delaunay(x,y);
           
            if ~isempty(testData) % if test if available, plot over it                
                % color ana mode shape with error percentage
                axes(ah);
                trimesh(tri,x,y,z);
            else
                % print displaced shape without error color
                axes(ah);
                trimesh(tri,x,y,z);
            end
            
            view(ah,-30,25)          % set axes proportional
            axis(ah,'equal')
            
            if ~isempty(testData)
                % Plot exp overlay on analytical mode shape
                ah = handles.axesAnaModeShape;
                % get test data mesh
                validNode = ~isnan(testData.U(:,expModeNum));
                x = testData.x(validNode);
                y = testData.y(validNode);
                z = testData.U(validNode,expModeNum)*anaScale;
                
                %overlay DOF in red
                hold(ah,'on');
                plot3(ah,x,y,z,'marker','o',...
                    'markerfacecolor','r',...
                    'linestyle','none');
                hold(ah,'off');
            end
        end
    case 'Exp'
        ah = handles.axesExpModeShape;  
        
        validNode = ~isnan(testData.U(:,expModeNum));
        x = testData.x(validNode);
        y = testData.y(validNode);
        z = testData.U(validNode,expModeNum)*expScale;
        xb = testData.xB;
        yb = testData.yB;
        
        %concat geometry
        zb = zeros(length(xb),1);
        xTot = [x;xb];
        yTot = [y;yb];
        zTot = [z;zb];
        
        %define resolution
        xres = 35;
        yres = 35;
        
        %interp
        xv = linspace(min(xTot), max(xTot),xres);
        yv = linspace(min(yTot), max(yTot),yres);
        [xInterp,yInterp] = meshgrid(xv,yv);
        zInterp = griddata(xTot,yTot,zTot,xInterp,yInterp,'v4');
        
        %plot initial mesh
        hold(ah,'off');
        mesh(ah,xInterp,yInterp,zInterp);       %draw mesh
        hold(ah,'on');
        
        %overlay DOF in red
        plot3(ah,x,y,z,'marker','o',...
            'markerfacecolor','r',...
            'linestyle','none')
        
        %overlay boundaries in black
        plot3(ah,xb,yb,zb, 'marker','.',...
            'color','k',...
            'linestyle','none');
        
        axis(ah,'equal');
        view(ah,-35,25) 
end
catch
end
end