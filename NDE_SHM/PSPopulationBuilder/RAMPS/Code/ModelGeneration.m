% (10/19/14) NPR: Changed line 22 to fix error with scalar values.

function [Node, Parameters] = ModelGeneration(uID, Options, Parameters)
%% Call Init.m
% Assigns properties to beams, barrier, and deck
try
    Parameters = InitializeSt7Properties(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Call GetBeamSection.m
try
    SetBeamSection(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Call GetBeamSection.m
try
    SetDeckProperties(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Set non-structural mass 
try
    Parameters = SetNonstructuralMassProperties(uID,Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end
        
%% Call GetDiaSection.m
try
    SetDiaSection(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Call SetCompositeAction.m
try
    SetCompositeAction(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Call BuildModel.m
try
    [Parameters, Node] = BuildModel(uID, Options, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Set wearing surface
if Parameters.Deck.WearingSurface > 0
    try
        AddOverlay(uID, Node, Parameters, Parameters.Deck.WearingSurface, 1);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
end

%% Call BoundaryConditions.m
try
    FCaseNum = 1;
    BoundaryConditions(uID, Node, Parameters, FCaseNum);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

end %ModelGeneration