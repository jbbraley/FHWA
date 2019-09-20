function setStrain(self,curvature,neutral_axis)
%% setStrain
% 
% 
% 
% author: John Braley
% create date: 10-Jul-2019 12:38:52
% compression is negative strain
strain_centroid = (neutral_axis(1)-self.centroid)*curvature;	

for ii=1:length(self.fibers)
    if isempty(self.shear_release) || self.fibers{ii}.y<self.shear_release
        self.fibers{ii}.strain = (self.centroid-self.fibers{ii}.y)*curvature+strain_centroid;
    else
        self.fibers{ii}.strain = (neutral_axis(2)-self.fibers{ii}.y)*curvature;
    end
end
	
	
	
end
