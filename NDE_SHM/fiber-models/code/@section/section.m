classdef section < handle
%% classdef section
% 
% 
% 
% author: John Braley
% create date: 10-Jul-2019 12:44:29
% classy version: 0.1.2

%% object properties
	properties
        centroid = 0  % location of centroid relative to fiber coordinates
        fibers %array of fiber objects
        axial_force = 0; % applied axial force
        shear_release = []; % vertical coordinate of shear release (i.e. location of loss of comp. action)
        curvature % imposed curvature
        init_curv  % initial curvature under dead load
	end

%% dependent properties
	properties (Dependent)
        neutral_axis
        coords  % master list of coordinates for all fibers
        total_curvature
	end

%% private properties
	properties (Access = private)
	end

%% constructor
	methods
		function self = section(val,dL)
            if nargin<2
                dL = 1;
            end
            [self.fibers, self.init_curv] = val.mesh(dL,'dx',dL,'dy');
            self.centroid = val.girder.section_data.yb; %(val.girder.section_data.yb*val.girder.area+(val.deck.t/2+val.girder.section_data.d)*(val.deck.t*val.be))/(val.girder.area+val.deck.t*val.be);
		end
	end

%% ordinary methods
	methods 
        function pop_fibers(self,name,value,inds)
            if ischar(name)
                if nargin>4
                    for ii = inds
                        self.fibers{ii}.(name) = value(ii);
                    end
                else
                    if isempty(self.fibers) || length(values)==length(self.fibers)
                        for ii = 1:length(values)
                            self.fibers{ii}.(name) = value(ii);
                        end
                    else
                        error('size of input does not match number of fibers')
                    end
                end
            else
                error('Specify fiber property value to populate')
            end
        end
	end % /ordinary

%% dependent methods
	methods 
        function coords = get.coords(self)
            coords = zeros(length(self.fibers),2);
            for ii = 1:length(self.fibers)
                coords(ii,1) = self.fibers{ii}.x;
                coords(ii,2) = self.fibers{ii}.y;
            end
        end
        function set.coords(self,value)
            for ii = 1:length(value)
                self.fibers{ii}.x = value(ii,1);
                self.fibers{ii}.y = value(ii,2);
            end
        end
        function total_curvature = get.total_curvature(self)
            total_curvature = self.curvature+self.init_curv;
        end
	end % /dependent

%% static methods
	methods (Static)
	end % /static

%% protected methods
	methods (Access = protected)
	end % /protected

end
