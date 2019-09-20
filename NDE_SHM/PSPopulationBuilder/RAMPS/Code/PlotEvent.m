%% JBB 6/25/14
function PlotEvent(ah, data,yopt)

% ah - axes handle
% data - matrix of event data to be plotted (data series x number of events)
% yopt - string: 'norm' or 'semilogy'

% Make figure axes current
axes(ah)

% Create event indices
x = 0:size(data,2)-1;
X = padarray(x,[size(data,1)-1 0],'replicate','post')';

% Plot daters
switch yopt
    case 'norm'
        p = plot(X,data','-o');
    case 'semilogy'
        p = semilogy(data','-o');
end

% Set x-lims
xlim([0 size(data,2)+1]);
% 
formatColorScheme(ah);


