function SetDiaSection(uID, Parameters)
%% Check if beam is being updated
if Parameters.Dia.Updating.E.Update
    E = Parameters.Dia.E.*Parameters.Dia.Updating.E.Alpha(1);
else
    E = Parameters.Dia.E;
end

if strcmp(Parameters.Dia.Type,'Concrete')
    Doubles = [E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
else
    Doubles = [E 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111];
end

%% Diaphragm Section Property Assignment
global kLSection kLipChannel kSquareSolid ptBEAMPROP
loc = {'Int';'End'};

for ii = 1:length(loc)
    % Find property index for diaphragms
     ind = find(strcmp({Parameters.St7Prop(:).propName},[loc{ii} ' Diaphragm']));
    
    % Set Material Data
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.St7Prop(ind).St7PropNum, Parameters.St7Prop(ind).MatData);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.St7Prop(ind).St7PropNum, Parameters.St7Prop(ind).MatName);
    HandleError(iErr);

    switch Parameters.Dia.Type
        case 'Beam'
            % Assign Section Geometry
            iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, Parameters.St7Prop(ind).St7PropNum,...
                kLipChannel, Parameters.Dia.Section);
            HandleError(iErr);
            iErr  = calllib('St7API', 'St7CalculateBeamSectionProperties', uID, Parameters.St7Prop(ind).St7PropNum,1,1);
            HandleError(iErr);

            % rotate 90 degrees
            integers = 0;
            doubles = zeros(1,11);
            [iErr, integers, doubles]  = calllib('St7API', 'St7GetBeamSectionPropertyData', uID, Parameters.St7Prop(ind).St7PropNum,integers,doubles);
            HandleError(iErr);
            doubles(11) = 90*pi/180;
            iErr  = calllib('St7API', 'St7SetBeamSectionPropertyData', uID, Parameters.St7Prop(ind).St7PropNum,integers,doubles);
            HandleError(iErr);

            iErr  = calllib('St7API', 'St7SetBeamSectionName', uID, Parameters.St7Prop(ind).St7PropNum, Parameters.Dia.SectionName);
            HandleError(iErr)     

        case 'Cross'        
            % Diaphragm Section
            % Assign Section Geometry
            iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, Parameters.St7Prop(ind).St7PropNum,...
                kLSection, Parameters.Dia.Section);
            HandleError(iErr);
            iErr  = calllib('St7API', 'St7CalculateBeamSectionProperties', uID, Parameters.St7Prop(ind).St7PropNum,1,1);
            HandleError(iErr);
            iErr  = calllib('St7API', 'St7SetBeamSectionName', uID, Parameters.St7Prop(ind).St7PropNum, Parameters.Dia.SectionName);
            HandleError(iErr);  
        case 'Chevron'        
            % Diaphragm Section
            % Assign Section Geometry
            iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, Parameters.St7Prop(ind).St7PropNum,...
                kLSection, Parameters.Dia.Section);
            HandleError(iErr);
            iErr  = calllib('St7API', 'St7CalculateBeamSectionProperties', uID, Parameters.St7Prop(ind).St7PropNum,1,1);
            HandleError(iErr);
            iErr  = calllib('St7API', 'St7SetBeamSectionName', uID, Parameters.St7Prop(ind).St7PropNum, Parameters.Dia.SectionName);
            HandleError(iErr);
        case 'Concrete'
            % Assign Section Geometry
            iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, 6,...
                kSquareSolid, Parameters.Dia.Section);
            HandleError(iErr);
            iErr  = calllib('St7API', 'St7CalculateBeamSectionProperties', uID, 6,1,1);
            HandleError(iErr);

            iErr  = calllib('St7API', 'St7SetBeamSectionName', uID, 6, Parameters.Dia.SectionName);
            HandleError(iErr)

    end
end
end %GetDiaSection