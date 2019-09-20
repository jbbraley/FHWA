function Parameters = UpdateParameterTable(Parameters, Options, Node, State)
if isempty(Parameters)
    Parameters = getappdata(0,'Parameters');
end
if isempty(Options)
    Options = getappdata(0,'Options');
end
if isempty(Node)
    Node = getappdata(0,'Node');
end

switch State
    case 'Init'
        handles = Options.handles.EditParameters_gui;
        
        % parameters
        editable = [false, true,  true,  true,  true, false, false];
        set(handles.tableParameterValues, 'ColumnEditable', editable);
        
        % mass
        massData = {{1:Options.MassCorr.numDiv}, {Options.MassCorr.massMulti}};
        
        % Set Field Names to Uneditable - Set Fields to Editable
        editable = [false, true];
        set(handles.tableMass, 'ColumnEditable', editable);
    case 'Update'
        
end

% Set tables
% parameters
set(handles.tableParamterValues, 'Data', paraData);
% mass
set(handles.tableMass, 'Data', massData);

Parameters.St7Prop(1).propName = 'Deck';
Parameters.St7Prop(1).propType = 'Shell';
Parameters.St7Prop(1).elmtNums = [];
Parameters.St7Prop(1).St7PropNum = 1;
Parameters.St7Prop(1).MatData = [Parameters.Deck.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
Parameters.St7Prop(1).MatName = 'Deck Concrete';

end %UpdateParameterTable()