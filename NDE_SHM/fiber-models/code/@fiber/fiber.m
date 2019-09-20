classdef fiber < handle
%% classdef fiber
% 
% 
% 
% author: John Braley
% create date: 10-Jul-2019 12:43:07
% classy version: 0.1.2

%% object properties
	properties
        x   % horizontal location of fiber centroid (distance from section centroid)
        y   % vertical location of fiber centroid (distance from section centroid)
        area % effective area of fiber
        strain % strain at centroid of fiber
        init_strain % initial strain (under dead load)
        material_model % function that computes stress given strain
        active = 1; % 1 - fiber is contributing, 0 - fiber contributes no force
        state  % state of material (i.e. yield, rupture, cracked)

	end

%% dependent properties
	properties (Dependent)
        stress
        init_stress
	end

%% private properties
	properties (Access = private)
	end

%% constructor
	methods
		function self = fiber()
		end
	end

%% ordinary methods
	methods 
	end % /ordinary

%% dependent methods
	methods 
        function init_stress = get.init_stress(self)
            init_stress = self.material_model(self.init_strain);
        end
        function stress = get.stress(self)
            if self.active
                [stress, self.state] = self.material_model(self.strain+self.init_strain);
            else
                stress = 0;
            end
        end
        
	end % /dependent

%% static methods
	methods (Static)
	end % /static

%% protected methods
	methods (Access = protected)
	end % /protected

end
