function Parameters = SetNonstructuralMassProperties(uID, Parameters)
%% Check if barrier is being updated
if Parameters.Barrier.Updating.fc.Update
    fc = Parameters.Barrier.fc*10^Parameters.Barrier.Updating.fc.Alpha(1);
else
    fc = Parameters.Barrier.fc;
end

% convert fc to E
Parameters.Barrier.E = 57000*sqrt(fc);

%% Check if sidewalk is being updated
if Parameters.Sidewalk.Updating.fc.Update
    fc = Parameters.Sidewalk.fc*10^Parameters.Sidewalk.Updating.fc.Alpha(1);
else
    fc = Parameters.Sidewalk.fc;
end

% convert fc to E
Parameters.Sidewalk.E = 57000*sqrt(fc);

%% Barrier Section Property Assignment

global kSquareSolid ptPLATEPROP
side = {'Right';'Left'}; % Always right first, left second

for ii = 1:length(side)
    % BarrierSection Property Assignment
    if Parameters.Sidewalk.(side{ii}) > 0
        BarrierDim = [Parameters.Barrier.Width, Parameters.Barrier.Height, 0, 0, 0];
    else
        BarrierDim = [Parameters.Barrier.Width, Parameters.Barrier.Height+Parameters.Sidewalk.Height, 0, 0, 0];
    end
    
    % Find Property index
    ind = find(strcmp({Parameters.St7Prop(:).propName},[side{ii} ' Barrier']));
    Parameters.St7Prop(ind).MatData(1) = Parameters.Barrier.E;  
 
    % Assign
    iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, Parameters.St7Prop(ind).St7PropNum,kSquareSolid, BarrierDim);
    HandleError(iErr);
    Doubles = [Parameters.Barrier.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881]; %Repeated for updating
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.St7Prop(ind).St7PropNum, Doubles);
    HandleError(iErr);
%     iErr  = calllib('St7API', 'St7CalculateBeamSectionProperties', uID, Parameters.St7Prop(ind).St7PropNum, 1, 1);
%     HandleError(iErr);

    Slices = 1;
    ipArea = BarrierDim(2)*Parameters.Barrier.Width;
    ipI11 = BarrierDim(2)^3*Parameters.Barrier.Width/12;
    ipI22 = BarrierDim(2)*Parameters.Barrier.Width^3/12;
    % approximate torionsal constant
    ipJ = BarrierDim(2)*Parameters.Barrier.Width^3*(1/3 - 0.21*Parameters.Barrier.Width/BarrierDim(2)*(1-Parameters.Barrier.Width^4/(12*BarrierDim(2)^4)));
    ipSL1 = 0;
    ipSL2 = 0;
    ipSA1 = 5/6*(BarrierDim(2)*Parameters.Barrier.Width);
    ipSA2 = 5/6*(BarrierDim(2)*Parameters.Barrier.Width);
    switch side{ii}
        case 'Right'
            xBARmulti = 1;
        case 'Left'
            xBARmulti = 0;
    end
    ipXBAR = Parameters.Barrier.Width*xBARmulti;
    ipYBAR =  BarrierDim(2)/2; 
    ipANGLE = pi/2;
    Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE];
    Doubles(isnan(Doubles)) = 0;

    iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,Parameters.St7Prop(ind).St7PropNum, Slices, Doubles);
    HandleError(iErr);

end

%% Sidewalk Section Property Assignment

if Parameters.Sidewalk.Right ~= 0 || Parameters.Sidewalk.Left ~= 0
    for ii = 1:length(side)
        % Find Property index
        ind = find(strcmp({Parameters.St7Prop(:).propName},'Sidewalk'));
        Parameters.St7Prop(ind).MatData(1) = Parameters.Sidewalk.E;
        Doubles = [Parameters.Sidewalk.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
        iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, Parameters.St7Prop(ind).St7PropNum, Doubles);
        HandleError(iErr);
        iErr = calllib('St7API','St7SetPlateThickness',uID, Parameters.St7Prop(ind).St7PropNum, [Parameters.Sidewalk.Height, Parameters.Sidewalk.Height]);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptPLATEPROP, Parameters.St7Prop(ind).St7PropNum, Parameters.St7Prop(ind).MatName);
        HandleError(iErr);
    end
end
end % SetNonstructuralMass()