%% Specify Deformation
% Assume strain profile by setting centroidal strain and curvature
strain_centroid = 0;
curvature = 1/100;
%% Build cross section

% initiate section object
xs = section();
xs.curvature = curvature;
% initiate base fiber object/s
fb = fiber();
fb.area=1;
fb.x = 0;
fb.material_model = @(es) mat.ACIGrade100(es);

% arbitrary elevation coordinates
numFibers = 10;
elev = (1:numFibers/2)/numFibers;
elev = [-elev(end:-1:1) elev];

% assign fiber locations
for ii = 1:numFibers
    xs.fibers{ii} = clone(fb);
    xs.fibers{ii}.y=elev(ii);
end

%% Compute moment by using optimization to find centroid strain that results in equilibrium
[moment, na, exitflag] = xs.mom_curv;
