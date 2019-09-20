function [moment_y_total, moment_x_total] = getMoment(self)
%% getMoment
% 
% 
% 
% author: John Braley
% create date: 10-Jul-2019 12:28:58	
	
for ii = 1:length(self.fibers)
    stress(ii) = self.fibers{ii}.stress;
    force(ii) = stress(ii)*self.fibers{ii}.area;
    moment_y(ii) = force(ii)*(self.centroid-self.fibers{ii}.y);
    moment_x(ii) = force(ii)*self.fibers{ii}.x;
end

moment_x_total = sum(moment_x);	
moment_y_total = sum(moment_y);		
	
end
