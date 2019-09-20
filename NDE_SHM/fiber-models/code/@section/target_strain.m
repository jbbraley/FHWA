function [mom, curv, na] = target_strain(self,eps,y)
%% target_strain
% 
% 
% 
% author: jbb
% create date: 22-Aug-2019 18:26:03
	
% starting values
init_value = 2;
% bounds
lb = 0;
ub = 1e-3*1e4;

% objective function 
obj = @(curv) strain_curve(self,eps,curv,y);

algOpt = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective',...
                'TolFun',1e-6,...
                'TolX',1e-6,...
                'Display','off');
            
[beta,resnorm,R,Error,output] = lsqnonlin(obj,init_value,lb,ub,algOpt);   

curv = beta*1e-4;

self.curvature = curv;
[mom, na, ~, ~, s_y, exitflag] = self.mom_curv(y);

end

function strain_diff = strain_curve(sxn, eps, curv, y)
    sxn.curvature = curv*1e-4;
    [~, ~, ~, ~, strain, exitflag] = sxn.mom_curv(y);
    strain_diff = eps*1e3 - strain*1e3;
end
