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
if ~isempty(Parameters.Barrier.St7PropNum)
    for i=1:length(Parameters.Barrier.St7PropNum)
        % Assign
        Doubles = [Parameters.Barrier.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Barrier.St7PropNum(i), Doubles);
        HandleError(iErr);
    end
end

if Parameters.Sidewalk.Right ~= 0 || Parameters.Sidewalk.Left ~= 0
    Doubles = [Parameters.Sidewalk.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 2, Doubles);
    HandleError(iErr);
end
end % SetNonstructuralMass()