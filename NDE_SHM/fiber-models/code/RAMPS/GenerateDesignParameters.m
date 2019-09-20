function [ Parameters ] = GenerateDesignParameters( Parameters )
% GENERATEDESIGNPARAMETERS will calculate all of the parameters that are not created if a model
% is manually specified.

% If no design code specified, choose 'LRFD'
if strcmp(Parameters.Design.Code,'None')
    Parameters.Design.Code = 'LRFD';
end
% If no designtruck is specified, choose HL-93 ('A')
if strcmp(Parameters.Design.DesignLoad,'None')
    Parameters.Design.DesignLoad = 'A';
end

switch Parameters.structureType
    case 'Steel'
            Parameters = AASHTODesign(Parameters);
            Parameters = GetSectionForces(Parameters);
            Parameters = GetLRFDResistance(Parameters);
        
    case 'Prestressed'
        if ~isfield(Parameters.Beam,'Mn_pos') || ~isfield(Parameters.Beam,'Fn_pos')
            Parameters.Design = GetTruckLoads(Parameters.Design);
            Parameters = AASHTODesign(Parameters);
            Parameters = PSSectionForces(Parameters);
            Parameters = PSGirderCapacity(Parameters);
        end
end

end

