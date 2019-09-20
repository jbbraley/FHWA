function SetBeamNegMomSection(uID, Parameters)
global kISection
%% Section Property Assignment
% Assign section geometry
BeamPropNum = 8;

iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, BeamPropNum,...
               kISection, Parameters.Beam.CoverPlate.Section);
HandleError(iErr);

Slices = 1;
ipArea = Parameters.Beam.CoverPlate.A;
ipI22 = Parameters.Beam.CoverPlate.Ix;
ipI11 = Parameters.Beam.ind*Parameters.Beam.tw^3/12 + 2*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t)*Parameters.Beam.bf^3/12;
% approximate torionsal constant
ipJ = Parameters.Beam.tw^3*Parameters.Beam.ind/3 + 2*Parameters.Beam.bf*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t)^3/3;
ipSL1 = 0;
ipSL2 = 0;
ipSA2 = 5/6*(2*Parameters.Beam.bf*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t));
ipSA1 = (Parameters.Beam.d+2*Parameters.Beam.CoverPlate.t)*Parameters.Beam.tw;
ipXBAR = Parameters.Beam.bf/2;
ipYBAR = (Parameters.Beam.d+2*Parameters.Beam.CoverPlate.t)/2;
ipANGLE = pi/2;
Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                BeamPropNum, Slices, Doubles);
HandleError(iErr);
end %SetBeamNegMomSection