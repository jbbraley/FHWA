function Parameters = SetDeckProperties(uID, Parameters)
%% Check if deck is being updated
if Parameters.Deck.Updating.fc.Update
    fc = Parameters.Deck.fc.*Parameters.Deck.Updating.fc.Alpha(1);
else
    fc = Parameters.Deck.fc;
end

% convert fc to E
Parameters.Deck.E = 57000*sqrt(fc);

%% Set Deck Properties
Doubles = [Parameters.Deck.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 1, Doubles);
HandleError(iErr);

end