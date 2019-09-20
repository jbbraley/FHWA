function [moment, beta, max_strain, min_strain, strain_y, Error] = mom_curv(sxn,y,init_na)
%% mom-curv
% This function computes the moment for a given curvature that results in
% equilibrium
% 
% 
%
% author: John Braley
% create date: 10-Jul-2019 14:44:41
	
%% find appropriate strain profile for the given curvature that results in force equilibrium
% optimization algorithm

% starting values
if nargin>2 && ~isempty(init_na)
    init_values = init_na;
else
    init_values = sxn.centroid;
end
% bounds
for ii = 1:length(sxn.fibers)
    yy(ii) = sxn.fibers{ii}.y;
end
lb = min(yy)*2;
ub = max(yy)*.96;

% account for shear release
if ~isempty(sxn.shear_release) 
    init_values(2) = (sxn.shear_release+max(yy))/2;  %ones(1,length(sxn.shear_release)+1);
    lb = lb*ones(1,length(sxn.shear_release)+1);
    ub = ub*ones(1,length(sxn.shear_release)+1);
end

% objective function 
obj = @(NA) equil(sxn,NA);

algOpt = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective',...
                'TolFun',1e-6,...
                'TolX',1e-4,...
                'Display','off');
            
[beta,resnorm,R,Error,output] = lsqnonlin(obj,init_values,lb,ub,algOpt);   

% solution has converged

% compute and assign final strain profile
sxn.setStrain(sxn.curvature,beta);
% compute moment
[moment, ~] = sxn.getMoment;
% get extreme fiber strain
for ii = 1:length(sxn.fibers)
    strain(ii) = sxn.fibers{ii}.strain;
end
max_strain = max(strain);
min_strain = min(strain);
if nargin>1
    strain_y = sxn.total_curvature*(beta-y);
else
    strain_y = [];
end
end
    
function f_del = equil(section,NA)

% compute strain for each fiber
section.setStrain(section.curvature,NA);

% Calculate force
force = section.getForce();

% difference between applied and internal force
if section.axial_force~=0
    f_del = section.axial_force-sum(force);	
else
    f_del = force;
end
end
