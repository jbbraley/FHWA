function Parameters = InitializeSt7Properties(uID, Parameters)
global kBeamTypeBeam ptBEAMPROP
global kPlateTypePlateShell kMaterialTypeIsotropic

%% Create Properties and set material data
for ii = 1:length(Parameters.St7Prop)
    
    % Find Property index for shell elements (Deck & Sidewalk)    
    indD = find(strcmp({Parameters.St7Prop(:).propName},'Deck'));
    indSW = find(strcmp({Parameters.St7Prop(:).propName},'Sidewalk'));
    
    % Shell Elements (Deck & Sidewalk)
    if ii == indD || ii == indSW
        iErr = calllib('St7API', 'St7NewPlateProperty', uID, Parameters.St7Prop(ii).St7PropNum,kPlateTypePlateShell, kMaterialTypeIsotropic, Parameters.St7Prop(ii).propName);
        HandleError(iErr);
    % Beam Elements
    else
        iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.St7Prop(ii).St7PropNum, kBeamTypeBeam,Parameters.St7Prop(ii).propName);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.St7Prop(ii).St7PropNum, Parameters.St7Prop(ii).MatData);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.St7Prop(ii).St7PropNum, Parameters.St7Prop(ii).MatName);
        HandleError(iErr);
    end

end

end %InitProperties