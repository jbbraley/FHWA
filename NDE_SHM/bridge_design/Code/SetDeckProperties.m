function Parameters = SetDeckProperties(uID, Parameters)
global ptPLATEPROP

%% Check if deck is being updated
if Parameters.Deck.Updating.fc.Update
    fc = Parameters.Deck.fc.*Parameters.Deck.Updating.fc.Alpha(1);
else
    fc = Parameters.Deck.fc;
end

% convert fc to E
Parameters.Deck.E = 57000*sqrt(fc);

% Find property index and assign PropNum
PropNum = Parameters.St7Prop(strcmp({Parameters.St7Prop.propName}, 'Deck')).St7PropNum;
Parameters.St7Prop(PropNum).MatData(1) = Parameters.Deck.E; 

%% Set Deck Properties
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, PropNum, Parameters.St7Prop(PropNum).MatData);
HandleError(iErr);
iErr = calllib('St7API','St7SetPlateThickness',uID, PropNum, [Parameters.Deck.t, Parameters.Deck.t]);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetMaterialName', uID, ptPLATEPROP, PropNum, Parameters.St7Prop(PropNum).MatName);
HandleError(iErr);

end