function [mom_u, curv_u, na_u, moment, na] = sensitivity1(bridge,comp,parameter,lb,ub,step_size)
%% sensitivity1
% 
% 
% 
% author: jbb
% create date: 23-Aug-2019 12:09:32
top_fiber = max(bridge.girder.shape(:,2))+bridge.deck.t;

% stop_ind = regexp(parameter,'\.');
% layers = length(stop_ind)+1;

	
var = lb:step_size:ub;
for ii = 1:length(var)
    
    bridge.(comp).(parameter) = var(ii);
    sxn = section(bridge,0.5);
    % get moment/curvature at concrete crushing
    [mom_u(ii), curv_u(ii), na_u(ii)] = sxn.target_strain(-0.003, top_fiber);
    
    % get moment-curvature curve
    dc = 10^(round(log10(curv_u(ii)/50))); %step_size
    curvs(:,ii) = dc:dc:round(curv_u(ii)+dc,-log10(dc));
    for jj = 1:length(curvs)
        bridge_section.curvature = curvs(ii);
        [moment(jj,ii), na(jj,ii), exitflag(jj,ii), ~, ~, ~] = bridge_section.mom_curv();
    end
end
    
	
	
end
