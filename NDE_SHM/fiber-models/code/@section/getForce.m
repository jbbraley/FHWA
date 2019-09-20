function force_total = getForce(self)
%% getForce
% 
% 
% 
% author: John Braley
% create date: 10-Jul-2019 12:28:41
	
for ii = 1:length(self.fibers)
     if isempty(self.shear_release) || self.fibers{ii}.y<self.shear_release
        stress(1,ii) = self.fibers{ii}.stress;
        force(1,ii) = stress(ii)*self.fibers{ii}.area;
     else
         stress(2,ii) = self.fibers{ii}.stress;
        force(2,ii) = stress(ii)*self.fibers{ii}.area;
     end
end

force_total = sum(force,2);
	
	
end
