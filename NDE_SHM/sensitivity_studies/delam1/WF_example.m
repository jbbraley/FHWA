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
SteelBridge.deck.material_model = @(eps) mat.conc1(eps,SteelBridge.deck.fc);
SteelBridge.deck.rbar.size = 6;
SteelBridge.deck.rbar.spacing = 6; % inches
SteelBridge.deck.rbar.elev = 3; % inches
SteelBridge.deck.rbar.num_bars = SteelBridge.be/SteelBridge.deck.rbar.spacing;

% populate girder properties
girder_name = 'W36X282';
SteelBridge.girder = girder(girder_name);

% material properties
SteelBridge.girder.density = .280; %lb/in^3

% build section object
bridge_section = section(SteelBridge,0.5);
figure
plot(bridge_section.coords(:,1),bridge_section.coords(:,2),'.')
SteelBridge.plot_sxn
ylim([0 45])
xlim([-50 50])

% construct moment-curvature curve
dc = 1e-5; % curvature step size
curv = (1:50)*dc; 
clear moment na exitflag max_eps min_eps
for jj = 1:length(curv)
    bridge_section.curvature = curv(jj);
    [moment(jj), na(jj), max_eps(jj), min_eps(jj), exitflag(jj)] = bridge_section.mom_curv();
end

%find first curvature value that corresponds to crushing of concrete
crush_ind = find(min_eps>=-.0038,1,'last');
figure
plot(curv+bridge_section.init_curv,moment,'o-')
plot(curv,na,'o-')
figure
plot(curv,min_eps,'-o')

% loop through sections with decreasing deck thickness (to account for
% full-width delamination
clear moment na exitflag max_eps min_eps
deck_t = 8:-0.5:5;
top_fiber=max(deck_t)+SteelBridge.girder.section_data.d;
dc = 1e-5; % curvature step size
curv = (1:50)*dc; 
    
for kk = 1:length(deck_t)
    SteelBridge.deck.t = deck_t(kk);
    bridge_section = section(SteelBridge,0.5);
    % construct moment-curvature curve
    for pp = 1:length(curv)
        bridge_section.curvature = curv(pp);
        [moment(pp,kk), na(pp,kk), max_eps(pp,kk), min_eps(pp,kk), top_eps(pp,kk), exitflag(pp,kk)] = bridge_section.mom_curv(top_fiber);
    end

    %find first curvature value that corresponds to crushing of concrete
    crush_ind(kk) = find(top_eps(:,kk)>=-.0038,1,'last');
    
end


% plot change in capacity (i.e. moment at crushing)

% plot every mom-curv curve
figure
plot(curv,moment)
hold all
% moment/curv @ crushing
for ii= 1:length(crush_ind)
   plot(curv(crush_ind(ii)),moment(crush_ind(ii),ii),'o','color','black');
end
legend([cellstr([num2str((max(deck_t)-deck_t)') padarray('" delamination',[length(deck_t)-1],'replicate','post')]); 'crushing'])
xlabel('curvature [in/in]')
ylabel('moment [lb-in]')

% plot as percent of initial capacity
figure
plot(curv,moment/moment(crush_ind(1),1)*100)
hold all
% moment/curv @ crushing
for ii= 1:length(crush_ind)
   plot(curv(crush_ind(ii)),moment(crush_ind(ii),ii)/moment(crush_ind(1),1)*100,'o','color','black');
end
ytickformat('percentage')
legend([cellstr([num2str((max(deck_t)-deck_t)') padarray('" delamination',[length(deck_t)-1],'replicate','post')]); 'crushing'])
xlabel('curvature [in/in]')
ylabel('Percent of initial moment capacity')