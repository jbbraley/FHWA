%% example for Wide Flanged Steel Girder
% 
% 
% 
% author: John Braley
% create date: 19-Jul-2019 12:20:58
	
% initiate bridge object
SteelBridge = bridge();
SteelBridge.length = 50*12; % span length in inches
SteelBridge.girder_spacing = 8*12; % girder spacing in inches

% populate deck properties
SteelBridge.deck.t = 8; % deck thickness in inches
SteelBridge.deck.fc = 4000; % psi
SteelBridge.deck.density = 150/(12^3); %pci
SteelBridge.deck.material_model
SteelBridge.deck.rbar.size = 6;
SteelBridge.deck.rbar.spacing = 6; % inches
SteelBridge.deck.rbar.elev = 3; % inches
SteelBridge.deck.rbar.num_bars = SteelBridge.be/SteelBridge.deck.rbar.spacing;

% populate girder properties
girder_name = 'W36X282';
SteelBridge.girder = girder(girder_name);

% material properties
SteelBridge.girder.material_model
SteelBridge.girder.density = .280; %lb/in^3

% build section object
bridge_section = section(SteelBridge,0.5);
figure
plot(bridge_section.coords(:,1),bridge_section.coords(:,2),'.')

% construct moment-curvature curve
dc = 1e-7; % curvature step size
curv = (0:100)*dc; 
for jj = 1:length(curv)
    bridge_section.curvature = curv(jj);
    [moment(jj), na(jj), exitflag(jj)] = bridge_section.mom_curv();
end

figure
plot(curv+bridge_section.init_curv,moment,'o-')
    