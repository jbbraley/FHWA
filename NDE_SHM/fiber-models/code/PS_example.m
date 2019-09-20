%% example for Prestressed Girder
% 
% 
% 
% author: John Braley
% create date: 19-Jul-2019 12:20:58
	
% initiate bridge object
PSB = bridge();
PSB.length = 50*12; % span length in inches
PSB.girder_spacing = 8*12; % girder spacing in inches

% populate deck properties
PSB.deck.t = 8; % deck thickness in inches
PSB.deck.fc = 4000; % psi
PSB.deck.density = 150/(12^3); %pci
PSB.deck.material_model
PSB.deck.rbar.size = 6;
PSB.deck.rbar.spacing = 6; % inches
PSB.deck.rbar.elev = 3; % inches
PSB.deck.rbar.num_bars = PSB.be/PSB.deck.rbar.spacing;

% populate girder properties
girder_name = 'AASHTO-IV';
PSB.girder = PSgirder(girder_name);
PSB.girder.type = 'PS';
PSB.girder.numStrands = 54;
PSB.girder.diaStrand = 0.6; %in

% material properties
PSB.girder.PSFu = 270000; %psi
PSB.girder.PSE = 28500000; %psi
PSB.girder.fc = 6000; %psi
PSB.girder.material_model
PSB.girder.PSmat
PSB.girder.density = 150/(12^3); %lb/in^3

% build section object
PSsection = section(PSB,0.5);

% construct moment-curvature curve
dc = 1/1000; % curvature step size
curv = (0:100)*dc; 
for jj = 1:length(curv)
    PSsection.curvature = curv(jj);
    [moment(jj), na(jj), exitflag(jj)] = PSsection.mom_curv();
end

figure
plot(curv+PSsection.init_curv,moment,'o-')
    







	
	
	
end
