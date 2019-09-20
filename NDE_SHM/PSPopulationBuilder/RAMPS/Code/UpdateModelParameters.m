function Parameters = UpdateModelParameters(uID, Parameters, Node)
%% Call GetBeamSection.m
if Parameters.Beam.Updating.Ix.Update 
    try
        SetBeamSection(uID, Parameters);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
end

%% Call GetDiaSection.m
if Parameters.Dia.Updating.E.Update 
    try
        SetDiaSection(uID, Parameters);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
end

%% Call DeckStiffness.m
if Parameters.Deck.Updating.fc.Update 
    try
        Parameters = SetDeckProperties(uID, Parameters);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
end

%% Call SetNonstructuralMassProperties.m
if Parameters.Barrier.Updating.fc.Update || Parameters.Sidewalk.Updating.fc.Update
    try
        Parameters = SetNonstructuralMassProperties(uID, Parameters);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
end

%% Call BoundaryConditions.m
if any(Parameters.Bearing.Fixed.Update) || any(Parameters.Bearing.Expansion.Update)
    try
        FCaseNum = 1;
        BoundaryConditions(uID, Node, Parameters, FCaseNum);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
end

%% Call SetCompositeAction.m
if Parameters.compAction.Updating.Ix.Update
    try
        SetCompositeAction(uID, Parameters);
    catch
        CloseAndUnload(uID);
        rethrow(lasterror);
    end
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