% load parameters file
[fname, fpath] = uigetfile('*.mat');
% load parameters
load([fpath fname])

% populate bridge object with parameters file
brdg = param2fiber(Parameters);

brdg.deck.rbar.density = 0.0868;
brdg.deck.rbar.size = 6;
brdg.deck.rbar.spacing = 6; % inches
brdg.deck.rbar.elev = 3; % inches
brdg.deck.rbar.num_bars = brdg.be/brdg.deck.rbar.spacing;

% independent variable
brdg.deck.delam_width = brdg.be;
component = 'deck';
param = 'delam_depth';

%run study - working
lb = 0;
ub = 4;
step_size = 0.25;
[mom_u, curv_u, na_u, moment, na] = sensitivity1(brdg,component,param,lb,ub,step_size);

%base moment curve
sxn = section(brdg,0.5);
figure
plot(sxn.coords(:,1),sxn.coords(:,2),'.')
brdg.plot_sxn

dc = 1e-5; % curvature step size
curv = (0:50)*dc; 
top_fiber = max(brdg.girder.shape(:,2))+brdg.deck.t;
init_na = [];
clear moment na strain exitflag;
for jj = 1:length(curv)
    sxn.curvature = curv(jj);
    [moment(jj), na(jj), ~, ~, strain_y(jj), exitflag(jj)] = sxn.mom_curv(top_fiber,init_na);
    init_na = na(jj);
end

figure
plot(curv+sxn.init_curv,moment,'o-')
figure
plot(strain_y, moment,'o-')
plot(