function [Parameters, exitflag] = PlateGirderDesignASD(Parameters, CShapes, LShapes)
%% Parallel comp settings
options = optimset('Algorithm','active-set','Display','off','UseParallel','always');
% ms = MultiStart('UseParallel','always');
%%

Parameters.Beam.Type = 'Plate';

% Longest girder controls on spand to depth ratio
Parameters.Beam.d = floor(max(Parameters.Length/Parameters.Design.MaxSpantoDepth));

x0 = [Parameters.Beam.d/3 Parameters.Beam.d/30 Parameters.Beam.d/60];
ub = [Parameters.GirderSpacing/3 Parameters.GirderSpacing/10 Parameters.GirderSpacing/20];
lb = [6 1 1/4];

% Keep within bounds
x0(x0<lb) = lb(x0<lb);
x0(x0>ub) = ub(x0>ub);

% Find rolled Parameters.Beam or built up girder with I and A that satisfy all
% constraints while minimizing A
if Parameters.Deck.CompositeDesign == 1
    area = @(x)BeamArea(x);
    con = @(x)DesignCheckComp(x, CShapes, LShapes);
%     problem = createOptimProblem('fmincon','objective', area, 'x0',x0,'lb',lb,'ub',ub,'nonlcon',con,'options',options);
%     [x,fval,exitflag,output] = run(ms,problem,12);
        [x,fval,exitflag,output] = fmincon(area,x0,[],[],[],[],lb,ub,con,options);
else
     area = @(x)BeamArea(x);
    con = @(x)DesignCheckNc(x, CShapes, LShapes);
%     problem = createOptimProblem('fmincon','objective', area, 'x0',x0,'lb',lb,'ub',ub,'nonlcon',con,'options',options);
%     [x,fval,exitflag,output] = fmincon(problem);
        [x,fval,exitflag,output] = fmincon(area,x0,[],[],[],[],lb,ub,con,options);
end

Parameters.Beam.x = x;

% Beam compact requirements 1 = compact; 2 = noncompact
Parameters.Beam.Comp = 1;

if Parameters.Deck.CompositeDesign
    x_temp(1) = floor(x(1)*2)/2;
    x_temp(2) = floor(x(2)*4)/4;
    x_temp(3) = floor(x(3)*8)/8;
    
    [c, ceq] = DesignCheckComp(x_temp, CShapes, LShapes);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    
    if all(c<0)
        return
    end    
    
    x_temp(1) = round(x(1)*2)/2;
    x_temp(2) = round(x(2)*4)/4;
    x_temp(3) = round(x(3)*8)/8;
    
    [c, ceq] = DesignCheckComp(x_temp, CShapes, LShapes);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    
    if all(c<0)
        return
    end    
    
    x_temp(1) = ceil(x(1)*2)/2;
    x_temp(2) = ceil(x(2)*4)/4;
    x_temp(3) = ceil(x(3)*8)/8;
    
    [c, ceq] = DesignCheckComp(x_temp, CShapes, LShapes);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
else
    x_temp(1) = floor(x(1)*2)/2;
    x_temp(2) = floor(x(2)*4)/4;
    x_temp(3) = floor(x(3)*8)/8;
    
    [c, ceq] = DesignCheckNc(x_temp, CShapes, LShapes);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    
    if all(c<0)
        return
    end    
    
    x_temp(1) = round(x(1)*2)/2;
    x_temp(2) = round(x(2)*4)/4;
    x_temp(3) = round(x(3)*8)/8;
    
    [c, ceq] = DesignCheckNc(x_temp, CShapes, LShapes);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    
    if all(c<0)
        return
    end    
    
    x_temp(1) = ceil(x(1)*2)/2;
    x_temp(2) = ceil(x(2)*4)/4;
    x_temp(3) = ceil(x(3)*8)/8;
    
    [c, ceq] = DesignCheckNc(x_temp, CShapes, LShapes);
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
end

% % Compute Section Forces
% Parameters.Beam.bf = floor(x(1)*2)/2;
% Parameters.Beam.tf = floor(x(2)*4)/4;
% Parameters.Beam.tw = floor(x(3)*8)/8;
%     
% Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
% 
% Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12+Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.ind/2+Parameters.Beam.tf/2)^2)...
%     + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
% 
% Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind;
% 
% Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
% 
% Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
% Parameters = GetSectionForces(Parameters);
% 
% % If beam rates below 1 after rounding down dimensions, re-calc all with
% % rounding to nearest
% if Parameters.Spans == 1 || Parameters.Design.CoverPlateLength ~= 0
%     maxStress = max([Parameters.Beam.fb1, Parameters.Beam.fb2, Parameters.Beam.fb3, Parameters.Beam.fb4]);
% else
%     maxStress = max([Parameters.Beam.fb1, Parameters.Beam.fb2, Parameters.Beam.fb3, Parameters.Beam.fb4, Parameters.Beam.fb5, Parameters.Beam.fb6]);
% end
% 
% if maxStress > 0.55*Parameters.Beam.Fy
%     Parameters.Beam.bf = round(x(1)*2)/2;
%     Parameters.Beam.tf = round(x(2)*4)/4;
%     Parameters.Beam.tw = round(x(3)*8)/8;
% 
%     Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
%     
%     Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12+Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.ind/2+Parameters.Beam.tf/2)^2)...
%         + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
%     
%     Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind;
%     
%     Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
%     
%     Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
%     Parameters = GetSectionForces(Parameters);
% end
%     
% % If beam rates below 1 after rounding down dimensions, re-calc all with
% % rounding up dimensions
% if Parameters.Spans == 1 || Parameters.Design.CoverPlateLength ~= 0
%     maxStress = max([Parameters.Beam.fb1, Parameters.Beam.fb2, Parameters.Beam.fb3, Parameters.Beam.fb4]);
% else
%     maxStress = max([Parameters.Beam.fb1, Parameters.Beam.fb2, Parameters.Beam.fb3, Parameters.Beam.fb4, Parameters.Beam.fb5, Parameters.Beam.fb6]);
% end
% 
% if maxStress > 0.55*Parameters.Beam.Fy
%     Parameters.Beam.bf = ceil(x(1)*2)/2;
%     Parameters.Beam.tf = ceil(x(2)*4)/4;
%     Parameters.Beam.tw = ceil(x(3)*8)/8;
% 
%     Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
%     
%     Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12+Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.ind/2+Parameters.Beam.tf/2)^2)...
%         + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
%     
%     Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind;
%     
%     Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
%     
%     Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
%     Parameters = GetSectionForces(Parameters);
% end

%% Calls GetBeamParameters.Beam.m to return Parameters.Beam properties
function A = BeamArea(x)
Parameters.Beam.ind = Parameters.Beam.d-2*x(2);    
A = 2*x(1)*x(2) + x(3)*Parameters.Beam.ind;
end

function [c, ceq] = DesignCheckComp(x, CShapes, LShapes)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constraints Independant of Forces Below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assign Parameters.Beam properties
Parameters.Beam.bf = x(1);
Parameters.Beam.tf = x(2);
Parameters.Beam.tw = x(3);
Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12 + Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.tf/2+Parameters.Beam.ind/2)^2)...
    + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind; 


%% Depth Criteria
% Use Max span
c(1) = max(Parameters.Length/30) - Parameters.Beam.d;
c(2) = max(Parameters.Length/25) - (Parameters.Beam.d + Parameters.Deck.t); % For composite section only

%% Plate dimension check
c(3) = 0.2*Parameters.Beam.ind - Parameters.Beam.bf; % 0.2*ind <= bf
c(4) = 1.5*Parameters.Beam.tw - Parameters.Beam.tf; % 1.5tw <= tf

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constraints Dependant on Forces Below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
Parameters = GetSectionForces(Parameters);


%% Deflection criteria
c(5) = Parameters.Beam.IstDelta - Parameters.Beam.Ist;

%% Second Dimension Check
if 24 > 3860/sqrt(min(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.STNc))
    c(6) = Parameters.Beam.bf/Parameters.Beam.tf - 3860/sqrt(min(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.STNc)); % b/t <= 3860/sqrt(fb)
else
    c(6) = Parameters.Beam.bf/Parameters.Beam.tf - 24; % or b/t <=24
end

%% Longtitudinal Stiffener Check
if Parameters.Beam.Fy == 36000 && Parameters.Beam.fbcmax == 0.55*Parameters.Beam.Fy 
    D = 165;
else
    D = 170;
end

if 1/D < sqrt(Parameters.Beam.fbcmax)/23000 % fb in ksi
    c(7) = Parameters.Beam.ind/D - Parameters.Beam.tw; % tw >= D/170
else
    c(7) = Parameters.Beam.ind*sqrt(Parameters.Beam.fbcmax)/23000 - Parameters.Beam.tw; % or tw >= D*sqrt(fb)/23000
end

%% Moment Criteria
fI = 0.55*Parameters.Beam.Fy; % 0.55fy
c(8) = Parameters.Beam.fb1 - fI;
c(9) = Parameters.Beam.fb2 - fI;
c(10) = Parameters.Beam.fb3 - fI;
c(11) = Parameters.Beam.fb4 - fI;
if Parameters.Design.CoverPlateLength == 0 && Parameters.Spans > 1
    c(14) = Parameters.Beam.fb5-fI;
    c(15) = Parameters.Beam.fb6-fI;
end

%% Transverse stiffener requirement
c(12) = 7.33*10^7/(Parameters.Beam.ind/Parameters.Beam.tw)^2 - Parameters.Beam.Fy/3; % Fy/3 >= 7.33*10^7/(D/tw)^2 = Fv

%% Neutral Axis Check
% Neutral axis check - Use short term composite deck area
c(13) = Parameters.Deck.Ast*Parameters.Deck.t/2 - Parameters.Beam.A*Parameters.Beam.d/2;

ceq = [];
end %DesignCheckComp()

%% Constraints
function [c, ceq] = DesignCheckNc(x, CShapes, LShapes)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constraints Independant of Forces Below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assign Parameters.Beam properties
Parameters.Beam.bf = x(1);
Parameters.Beam.tf = x(2);
Parameters.Beam.tw = x(3);
Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12 + Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.tf/2+Parameters.Beam.ind/2)^2)...
    + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind;

%% Depth Criteria
% USe max span
c(1) = max(Parameters.Length/30) - Parameters.Beam.d;

%% Plate dimension check
c(2) = 0.2*Parameters.Beam.ind - Parameters.Beam.bf; %0.2*ind - bf
c(3) = 1.5*Parameters.Beam.tw - Parameters.Beam.tf; % 1.5tw <= tf

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constraints Dependant on Forces Below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
Parameters = GetSectionForces(Parameters);

%% Deflection criteria
c(4) = Parameters.Beam.IstDelta - Parameters.Beam.Ist;

%% Second Dimension Check
if Parameters.Beam.Fy == 36000
    fb = 23;
else
    fb = 24;
end

if fb > 3250/sqrt(Parameters.Beam.fbcmax)
    c(5) = Parameters.Beam.bf/Parameters.Beam.tf - 3250/sqrt(Parameters.Beam.fbcmax); % b/t <= 3250/sqrt(fb)
else
    c(5) = Parameters.Beam.bf/Parameters.Beam.tf - fb; % or b/t <= fb
end

%% Longtitudinal Stiffener Check
if Parameters.Beam.Fy == 36000 && Parameters.Beam.fbcmax == 0.55*Parameters.Beam.Fy
    D = 165;
else
    D = 170;
end

if 1/D < sqrt(Parameters.Beam.fbcmax)/23000 % fb in ksi
    c(6) = Parameters.Beam.ind/D - Parameters.Beam.tw; % tw >= D/170
else
    c(6) = Parameters.Beam.ind*sqrt(Parameters.Beam.fbcmax)/23000 - Parameters.Beam.tw; % or tw >= D*sqrt(fb)/23000
end

%% Moment Criteria
fI = 0.55*Parameters.Beam.Fy; % 0.55fy
c(7) = Parameters.Beam.fb1 - fI;
c(8) = Parameters.Beam.fb2 - fI;
c(9) = Parameters.Beam.fb3 - fI;
c(10) = Parameters.Beam.fb4 - fI;
if Parameters.Spans > 1
    c(12) = Parameters.Beam.fb5-fI;
    c(13) = Parameters.Beam.fb6-fI;
end

%% Transverse stiffener requirement
c(11) = 7.33*10^7/(Parameters.Beam.ind/Parameters.Beam.tw)^2 - Parameters.Beam.Fy/3; % Fy/3 >= 7.33*10^7/(D/tw)^2 = Fv

ceq = [];
end %DesignCheckNc()

end