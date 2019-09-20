function SetBeamSection(uID, Parameters)
global kISection
%% Check if beam is being updated
if Parameters.Beam.Updating.Ix.Update
    Ix = Parameters.Beam.Ix.*Parameters.Beam.Updating.Ix.Alpha(1);
else
    Ix = Parameters.Beam.Ix;
end

%% Section Property Assignment
% Assign section geometry
BeamPropNum = 5;
switch Parameters.structureType
    case 'Steel'
        % Assign section geometry
        iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, BeamPropNum,...
                       kISection, Parameters.Beam.Section);
        HandleError(iErr);

        Slices = 1;
        ipArea = Parameters.Beam.A;
        ipI22 = Ix;
        % Parameters.Beam.Iy
        ipI11 = Parameters.Beam.ind*Parameters.Beam.tw^3/12 + 2*Parameters.Beam.tf*Parameters.Beam.bf^3/12;
        % approximate torionsal constant
        ipJ = Parameters.Beam.tw^3*Parameters.Beam.ind/3 + 2*Parameters.Beam.bf*Parameters.Beam.tf^3/3;
        ipSL1 = 0;
        ipSL2 = 0;

        % shear area
        if isfield(Parameters.Beam, 'ShearDefoff')
            if Parameters.Beam.ShearDefoff
                ipSA2 = 1*10^9;
                ipSA1 = 1*10^9;
            else
                ipSA2 = 5/6*(2*Parameters.Beam.bf*Parameters.Beam.tf);
                ipSA1 = Parameters.Beam.d*Parameters.Beam.tw;
            end
        else
            ipSA2 = 5/6*(2*Parameters.Beam.bf*Parameters.Beam.tf);
            ipSA1 = Parameters.Beam.d*Parameters.Beam.tw;
        end

        ipXBAR = Parameters.Beam.bf/2;
        ipYBAR = Parameters.Beam.d/2;
        ipANGLE = pi/2;
        Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

        iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                        BeamPropNum, Slices, Doubles);
        HandleError(iErr);
    case 'Prestressed'
        oldcd = pwd;
        cd([pwd '\Prestressed\Sections']);
        iErr = calllib('St7API', 'St7AssignBXS', uID, BeamPropNum, Parameters.Beam.Name);
        HandleError(iErr);
        cd(oldcd);
        
        SectionData = zeros(11,1);
        Slices = 0;
        [iErr, Slices, SectionData]  = calllib('St7API', 'St7GetBeamSectionPropertyData', uID,...
                        BeamPropNum, Slices, SectionData);
        HandleError(iErr);
                    
        % shear area
        if isfield(Parameters.Beam, 'ShearDefoff') && Parameters.Beam.ShearDefoff
                SectionData(7) = 1*10^9;
                SectionData(8) = 1*10^9;
        else
            % Switch shear areas
            SectionData(7:8) = SectionData([8 7]);
        end
        
        %Switch I11 and I22
        SectionData(2:3) = SectionData([3 2]);    
        
        %axis 1 angle
        SectionData(11) = 3*pi/2;
        
        % Set Property Section Data
        iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                        BeamPropNum, Slices, SectionData);
        HandleError(iErr);
        
end     

end %SetBeamSection