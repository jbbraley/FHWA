function Bridge = param2fiber(Parameters)
%% param2fiber
% 
% mines all the necessary values from parameters file and creates fiber
% model
% 
% author: jbb
% create date: 19-Aug-2019 17:41:08
	
% initiate bridge object
Bridge = bridge();
Bridge.length = Parameters.Length; % span length in inches
Bridge.girder_spacing = Parameters.GirderSpacing; % girder spacing in inches

% populate deck properties
Bridge.deck.t = Parameters.Deck.t; % deck thickness in inches
Bridge.deck.fc = Parameters.Deck.fc; % psi
Bridge.deck.density = Parameters.Deck.density; %pci
Bridge.deck.material_model = @(x) mat.conc1(x,Bridge.deck.fc);
% Bridge.deck.rbar.size = 6;
% Bridge.deck.rbar.spacing = 6; % inches
% Bridge.deck.rbar.elev = 3; % inches
% Bridge.deck.rbar.num_bars = Bridge.be/Bridge.deck.rbar.spacing;

% populate girder properties
switch Parameters.structureType
    case {'Steel', 'steel'}
        if strcmp(Parameters.Beam.Type,'Rolled')  %strcmp(Parameters.Beam.Int.Type,'Plate')
            girder_name = Parameters.Beam.Int.SectionName;
            Bridge.girder = girder(girder_name);
        else
            girder_name = Parameters.Beam.Int.Type;
            Bridge.girder = girder(girder_name);
            [Bridge.girder.section_data, Bridge.girder.shape] = Plates(Parameters);
        end
        

        % material properties
        Bridge.girder.fy = Parameters.Beam.Fy;
        Bridge.girder.material_model = @(x) mat.structural_steel(x,Bridge.girder.fy);
        Bridge.girder.density = Parameters.Beam.density; %lb/in^3
    case 'Prestressed'
        girder_name = Parameters.Beam.Name;
        Bridge.girder = PSgirder(girder_name);
        Bridge.girder.numStrands = Parameters.Beam.PSSteel.NumStrands;
        Bridge.girder.diaStrand = Parameters.Beam.PSSteel.d; %in
        % top reinforcing steel
        Bridge.girder.rbar.num_bars = Parameters.Beam.RFSteel.NumBars;
        Bridge.girder.rbar.size = Parameters.Beam.RFSteel.BarNo;
%         Bridge.girder.rfcenter = Parameters.Beam.RFCenter;

        % material properties
        Bridge.girder.PSFu = Parameters.Beam.PSSteel.Fu; %psi
        Bridge.girder.PSE = Parameters.Beam.PSSteel.E; %psi
        Bridge.girder.fc = Parameters.Beam.fc; %psi
        Bridge.girder.material_model = @(x) mat.conc1(x,Bridge.girder.fc);
        Bridge.girder.PSmat = @(x) mat.PS_PCI(x,Bridge.girder.PSFu);
        Bridge.girder.density = Parameters.Beam.density; %lb/in^3
end

% % build section object
% bridge_section = section(Bridge,0.5);	
% 	n=1;
% for eps = 0:0.0005:.041
%     sig(n) = Bridge.girder.PSmat(eps);
%     n=n+1;
% end
% 	
	
end
