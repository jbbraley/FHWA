function UpdateGeometryTables(Parameters, Options, State)
if isempty(Parameters)
    Parameters = getappdata(0, 'Parameters');
end
if isempty(Options)
    Options = getappdata(0, 'Options');
end

try
    handles = Options.handles.UserInputDeck_gui;
    
    switch State
        case 'Init'
            % spans
            spansString = arrayfun(@num2str,1:10,'UniformOutput',0);
            spansValue = 1;
            % type
            typeString = {'Steel','Prestressed'};
            typeValue = 1;
            % length
            lengthsData = {'Length', []};
            % geometry
            geometryData = cell(15,2);
            geometryData(:,1) = {'Road Width'; 'Near Skew'; 'Far Skew';...
                'Deck Thickness'; 'Sidewalk Height';...
                'Left Sidewalk Width'; 'Right Sidewalk Width';...
                'Barrier Height'; 'Barrier Width'; 'Wearing Surface'; 'Haunch Depth';...
                'Deck fc [psi]'; 'Steel Fy [psi]';...
                'Barrier fc [psi]'; 'Sidewalk fc [psi]'};
            % width
            widthData = {'Out to Out Width:', []};
            
            % Set Field Names to Uneditable - Set Fields to Editable
            editable = [false, true];
            set(handles.tableGeometry, 'ColumnEditable', editable);
            set(handles.tableLengths, 'ColumnEditable', editable);
            editable = [false, false];
            set(handles.tableOutToOutWidth, 'ColumnEditable', editable);
        case 'Update'
            % spans
            spansValue = Parameters.Spans;
            spansString = arrayfun(@num2str,1:10,'UniformOutput',0);
            % type
            typeString = get(handles.popupmenuType, 'String');
            typeValue = find(strcmp(Parameters.structureType, typeString));
            % length
            lengthsData = cell(Parameters.Spans, 2);
            lengthsData(:,1) = {'Length'};
            lengthsData(:,2) = num2cell(Parameters.Length);
            % geometry
            geometryData = get(handles.tableGeometry, 'Data');
            geometryData{1,2} = Parameters.RoadWidth;
            geometryData{2,2} = Parameters.SkewNear;
            geometryData{3,2} = Parameters.SkewFar;
            geometryData{4,2} = Parameters.Deck.t;
            geometryData{5,2} = Parameters.Sidewalk.Height;
            geometryData{6,2} = Parameters.Sidewalk.Left;
            geometryData{7,2} = Parameters.Sidewalk.Right;
            geometryData{8,2} = Parameters.Barrier.Height;
            geometryData{9,2} = Parameters.Barrier.Width;
            geometryData{10,2} = Parameters.Deck.WearingSurface; %Wearing Surface
            geometryData{11,2} = Parameters.Deck.Offset; %Haunch
            geometryData{12,2} = Parameters.Deck.fc;
            geometryData{13,2} = Parameters.Beam.Fy;
            geometryData{14,2} = Parameters.Barrier.fc;
            geometryData{15,2} = Parameters.Sidewalk.fc;
            % width
            widthData = {'Out to Out Width:', Parameters.Width};
    end
    
    % Set tables and popup menus
    % spans
    set(handles.popupSpans, 'String', spansString, 'Value', spansValue);
    % type
    set(handles.popupmenuType, 'String', typeString, 'Value', typeValue);
    % length
    set(handles.tableLengths, 'Data', lengthsData);
    % geometry
    set(handles.tableGeometry, 'Data', geometryData);
    % width
    set(handles.tableOutToOutWidth, 'Data', widthData);
catch
end
end