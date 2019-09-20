function SetCompositeAction(uID, Parameters)
% Uses exponential alpha values - i.e. InitParameter*10^Alpha

% Set's section properties of beam that enforces composite action
global kCircularSolid ptBEAMPROP
%% Check if beam is being updated
if Parameters.compAction.Updating.Ix.Update
    Ix = Parameters.compAction.Ix*10^Parameters.compAction.Updating.Ix.Alpha(1);
else
    Ix = Parameters.compAction.Ix;
end

%% Section Property Assignment
% Find property index
ind = find(strcmp({Parameters.St7Prop(:).propName}, 'Comp Action'));

% Material Data
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.St7Prop(ind).St7PropNum, Parameters.St7Prop(ind).MatData);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.St7Prop(ind).St7PropNum, Parameters.St7Prop(ind).MatName);
HandleError(iErr);

% Assign section geometry
% Section is a 1x1 in cyclinder
Section = [1 0 0 0 0 0];
Slices = 5;
% bending moment resistance for global bending of structure
ipI22 = Ix;
% arbitrarily high values for other section values
ipArea = 10000000;
ipI11 = 10000000;
ipJ = 10000000;
ipSL1 = 0;
ipSL2 = 0;
ipSA1 = 10000000;
ipSA2 = 10000000;

ipXBAR = 0.5; %radius is 1/2 in
ipYBAR = 0.5;
ipANGLE = 0;
Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID,...
                Parameters.St7Prop(ind).St7PropNum,kCircularSolid, Section);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                 Parameters.St7Prop(ind).St7PropNum, Slices, Doubles);
HandleError(iErr);
end %GetBeamSection