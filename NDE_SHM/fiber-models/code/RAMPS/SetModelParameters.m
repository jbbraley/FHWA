function Parameters = SetModelParameters(uID, Parameters, Node)
%% Call GetBeamSection.m
try
    SetBeamSection(uID, Parameters);
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
    
%% Call DeckStiffness.m
try
    Parameters = SetDeckProperties(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Call SetNonstructuralMassProperties.m
try
    Parameters = SetNonstructuralMassProperties(uID, Parameters);
catch
    CloseAndUnload(uID);
    rethrow(lasterror);
end

%% Call BoundaryConditions.m
try
    FCaseNum = 1;
    BoundaryConditions(uID, Node, Parameters, FCaseNum);
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

%% Call UpdateModelDimension.m
% if Parameters.Updating.ModelDimUpdate
%     try
%         UpdateModelDimension(uID,NodeID,Node);
%     catch
%         CloseAndUnload(uID);
%         rethrow(lasterror);
%     end
% end
end %UpdateModelParameters