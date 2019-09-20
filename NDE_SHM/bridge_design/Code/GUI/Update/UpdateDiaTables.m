function UpdateDiaTables(Parameters, Options)
if isempty(Parameters)
    Parameters = getappdata(0, 'Parameters');
end
if isempty(Options)
    Options = getappdata(0, 'Options');
end

try
    handles = Options.handles.SteelDiaSection_gui;
    
    enableString = {'inactive','on','off'};
    
    % Type
    if strcmp(Parameters.Dia.Type, 'Beam')
        typeValue = [1, 0, 0];
        sectionType = 'C';
    elseif strcmp(Parameters.Dia.Type, 'Cross')
        typeValue = [0, 1, 0];
        sectionType = 'L';
    elseif strcmp(Parameters.Dia.Type, 'Chevron')
        typeValue = [0, 0, 1];
        sectionType = 'L';
    else
        typeValue = [0, 0, 0];
        sectionType = '';
    end
    typeEnable = ~typeValue;
    
    % Auto Assign
    if strcmp(Parameters.Dia.Assign, 'Auto')
        autoValue = 1;
        sectionType = '';
    else
        autoValue = 0;
    end
    
    % Config
    if strcmp(Parameters.Dia.Config, 'Normal')
        configValue = [1, 0, 0];
    elseif strcmp(Parameters.Dia.Config, 'Parallel')
        configValue = [0, 1, 0];
    elseif strcmp(Parameters.Dia.Config, 'Stagger')
        configValue = [0, 0, 1];
    else
        configValue = [0, 0, 0];
    end
    configEnable = ~configValue;
    
    % Set radio buttons
    set(handles.radiobtnBeam,'value',typeValue(1),'enable',enableString{typeEnable(1)+1});
    set(handles.radiobtnCross,'value',typeValue(2),'enable',enableString{typeEnable(2)+1});
    set(handles.radiobtnChevron,'value',typeValue(3),'enable',enableString{typeEnable(3)+1});
    
    set(handles.radiobtnNormal,'value',configValue(1),'enable',enableString{configEnable(1)+1});
    set(handles.radiobtnParallel,'value',configValue(2),'enable',enableString{configEnable(2)+1});
    set(handles.radiobtnStaggered,'value',configValue(3),'enable',enableString{configEnable(3)+1});
    
    % Set check boxes
    set(handles.checkboxAutoAssign, 'value', autoValue);
    
    % Set list box
    if strcmp(sectionType, 'L')
        listString = getappdata(0,'listLShapes');
    elseif strcmp(sectionType, 'C')
        listString = getappdata(0,'listCShapes');
    else
        listString = 'Auto Assign Dia Section';
    end
    
    set(handles.listboxSection,'String',listString);
    
    % Find chosen section
    if ~isempty(Parameters.Dia.SectionName)
        indSection = find(not(cellfun('isempty', strfind(listString, Parameters.Dia.SectionName))));
        set(handles.listboxSection,'value',indSection);
    end
    
    % Set number of rows:
    if ~isempty(Parameters.NumDia)
        data = cell(Parameters.Spans, 2);
        for i=1:Parameters.Spans
            data{i,1} = ['Span ' num2str(i) ':'];
            data{i,2} = num2str(Parameters.NumDia(i));
        end
    else
        data = cell(Parameters.Spans, 2);
        for i=1:Parameters.Spans
            data{i,1} = ['Span ' num2str(i) ':'];
            data{i,2} = num2str(0);
        end
    end
    set(handles.tableDiaRows, 'Data', data);
catch
end
end
