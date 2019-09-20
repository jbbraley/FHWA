function [Parameters,exitflag] = PlateSizing_LRFD(Parameters, CShapes, LShapes, Section)
% Iterate sizing process (once with constant I, once with varying I)
if strcmp(Section, 'All')
    beamSection ={'Int';'Ext'};
else
    beamSection = Section;
end

exitflag = zeros(2,2);

for i=1:length(Section) % Section can be 'Int', 'Ext' or 'All'

% Find initial solution for SLG Analysis with constant section
fCall = 1;
[Parameters,exitflag(i,1)] = AreaMinimization(Parameters, CShapes, LShapes, Section{i}, fCall);

    % Find secondary solution for varying cross-section if applicable
    if Parameters.Beam.(beamSection{i}).CoverPlate.Ratio > 0 && exitflag(i,1) > 0    

        % Save initial solution
        initialBeamSection = Parameters.Beam.(beamSection{i}).Section;
        initialCPSection = Parameters.Beam.(beamSection{i}).CoverPlate.Section;

        itDesign = 1;
        itCount = 1;
        while itDesign == 1 && itCount < 11
            % Determine new demands for SLG with varying cross-section
            I_diff = Parameters.Beam.(beamSection{i}).CoverPlate.I.Ix/Parameters.Beam.(beamSection{i}).I.Ix;
            [Parameters, Parameters.Design.SLG.(beamSection{i})(itCount+1)] = GetFEApproximation(Parameters, I_diff);

            % if new DL demands are 5% greater than old, re-run algorithm
            if 1.05*max(abs(Parameters.Design.SLG.(beamSection{i})(itCount).minDLM)) < max(abs(Parameters.Design.SLG.(beamSection{i})(itCount+1).minDLM))
                itDesign = 1;
            else
                itDesign = 0;
                exitflag(i,2) = exitflag(i,1);
                continue
            end   

            itCount = itCount + 1;
            fCall = itCount;
            [P_temp,exitflag(i,2)] = ...
                AreaMinimization(Parameters, CShapes, LShapes, Section{i}, fCall);
            if exitflag(i,2) > 0
                Parameters = P_temp;
            end
        end

        % If solution is found, initial solution and solution
        if exitflag(i,2) > 0                    
            Parameters.Beam.(beamSection{i}).initialSection = initialBeamSection;
            Parameters.Beam.(beamSection{i}).CoverPlate.initialSection = initialCPSection;

        end
    elseif exitflag(i,1) > 0
        exitflag(i,2) = exitflag(i,1);
    end
end
end

%% Objective Fucntions
function A = BeamAreaCP(x, Beam)
A = (1-Beam.CoverPlate.Ratio*2) * ... % positive moment region length
    (2*x(1)*x(2) + x(3)*(Beam.d - 2*x(2))) + ...  
     Beam.CoverPlate.Ratio*2 * ...
    (2*x(1)*(x(2)+x(4)) + x(3)*(Beam.d - 2*(x(2)+x(4))));
end

function A = BeamAreaNoCP(x, Beam)
A = 2*x(1)*x(2) + x(3)*(Beam.d - 2*x(2));
end

%% Algorithm Call
function [Parameters, exitflag] = AreaMinimization(Parameters, CShapes, LShapes, Section,fCall)
% set properties in Paramters.Beam structure field - either 'Int' or 'Ext'
switch Section
    case 'All' % designing everything at once
        Beam = Parameters.Beam.Int;
    otherwise % desiging int and ext seperately
        Beam = Parameters.Beam.(Section);
        Beam.Des = Section;
end

Beam.d = floor(max(Parameters.Length/Parameters.Design.MaxSpantoDepth));

% Set up workspace for either coverplate or no coverplate design
% Typical para values
TypicalX = [12 2 .5];

% Set bounds
ub = [Parameters.GirderSpacing/4 Parameters.GirderSpacing/20 Parameters.GirderSpacing/40];
lb = [6 .5 1/4];

if Beam.CoverPlate.Ratio > 0

    % Typical para values
    TypicalX(4) = 1;

    % Set bounds
    ub(4) = Parameters.GirderSpacing/10 ;
    lb(4) = 0;

    % set objective function
    area = @(x)BeamAreaCP(x, Beam);
else
    % set objective function
    area = @(x)BeamAreaNoCP(x, Beam);
end

% set options
options = optimset('Algorithm','interior-point','Display','iter','TypicalX',TypicalX);

% initialize
designFalse = 1; 
count = 0; 
tic
% loop for solution
while designFalse == 1 && count < 11
    rng shuffle
    count = count + 1;
    % starting points
    x0(1) = (ub(1)+lb(1))/2 + (ub(1)+lb(1))/8*randn(1,1);
    x0(2) = (ub(2)+lb(2))/2 + (ub(2)+lb(2))/8*randn(1,1);
    x0(3) = (ub(3)+lb(3))/2 + (ub(3)+lb(3))/8*randn(1,1);

    % check for bound exceedance
    if x0(3) > x0(2)
        x_t = x0(3);
        x0(3) = x0(2);
        x0(2) = x_t;
    end

    % add in coverplate only starting point
    if Beam.CoverPlate.Ratio > 0
        x0(4) = (x0(2)+lb(4))/2 + (x0(2)+lb(4))/8*randn(1,1);  
    end

    % Girder Optimization
    con = @(x)DesignCheck(x, CShapes, LShapes, Parameters, Beam, Section, fCall);
    [x, ~, exitflag, ~] = fmincon(area,x0,[],[],[],[],lb,ub,con,options);

    % Check design
    if exitflag > 0

        % get final constraint and Beam values
        x_rounded = ceil(x*10)/10;
        [Constraints, ~,Beam, Parameters] = DesignCheck(x_rounded, CShapes, LShapes, Parameters, Beam, Section,fCall);
        Beam.Constraints = Constraints;

        % assign final section
        if Beam.CoverPlate.Ratio > 0
            Beam.CoverPlate.Section = [Beam.CoverPlate.bf, Beam.CoverPlate.bf, Beam.CoverPlate.d,...
                Beam.CoverPlate.tf, Beam.CoverPlate.tf, Beam.CoverPlate.tw];
        end

        % assign final section
        Beam.Section = [Beam.bf, Beam.bf, Beam.d, Beam.tf, Beam.tf, Beam.tw];

        % record start points
        Beam.StartPoints = x0;
        Beam.x = x;

        % record algorithm details
        Beam.Exitflag = exitflag;
        Beam.Iterations = count;
        Beam.DesignTime = toc;
                
        % set properties in Paramters.Beam structure field - either 'Int' or 'Ext'
        switch Section
            case 'All' % designing everything at once
                Parameters.Beam.Int = Beam;
                Parameters.Beam.Ext = Beam;
            otherwise % desiging int and ext seperately
                Parameters.Beam.(Section) = Beam;
        end  
        
        designFalse = 0;
        continue
    end
    
     % see if over max iter
    if count > 10
        exitflag = 0;
    end
end
end


%% Design Check
function [c, ceq,Beam, Parameters] = DesignCheck(x, CShapes, LShapes, Parameters, Beam, Section, fCall)
% Determine design method
switch Section
    case 'All' % designing everything at once
        beamSection = {'Int'; 'Ext'};
    otherwise % desiging int and ext seperately
        beamSection = {Section};
end
for i = 1:length(beamSection) % loops for how many sections must be designed concurrently

    % Save type
    Beam.Type = 'Plate';
    
    % Apply parameters
    Beam.bf = x(1);
    Beam.tf = x(2);
    Beam.tw = x(3);
    if Beam.CoverPlate.Ratio > 0
        Beam.CoverPlate.tf = x(4) + Beam.tf;
        Beam.CoverPlate.bf = Beam.bf;
        Beam.CoverPlate.tw = Beam.tw;
        Beam.CoverPlate.t = Beam.CoverPlate.tf - Beam.tf;
    end
   
    % get section properties and resistance
    Beam = GetSectionProperties(Beam, Parameters, beamSection{i});
    if i == 1 % only run once
        Parameters = GetDiaSection(Parameters, CShapes, LShapes, Beam);
    end
    [Parameters.Design.DF.(['DF' (beamSection{i})]), Parameters.Design.DF.(['DFV' (beamSection{i})])] = LRFDDistFact(Parameters, Beam);
    Parameters.Demands.(beamSection{i}).SL = GetSectionForces(Beam, Parameters, Parameters.Design.Code, beamSection{i}, fCall);
    Beam = GetLRFDResistance(Beam, Parameters.Demands.(beamSection{i}).SL, Parameters, beamSection{i}, []);
    
    % If first pass for multi-girder design
    if i == 1
        % Proportioning Requirements
        % Positive moment region
        c(1) = Beam.Dpst/Beam.Dt - 0.42; % 6.10.7.3 Ductility
        c(2) = 0.3125 - Beam.tw; % Web Thickness Criteria (6.7.3)
        c(3) = Beam.ind/Beam.tw - 150; % Web Proportions 6.10.2.1 % For webs without longitudinal stiffeners
        c(4) = Beam.bf/(2*Beam.tf) - 12; % Flange Proportions 6.10.2.2
        c(5) = Beam.d/6 - Beam.bf; % Flange Proportions 6.10.2.2
        c(6) = 1.1*Beam.tw - Beam.tf; % Flange Proportions 6.10.2.2
    end
         
% ------- Positive Moment Region --------------------------------------
    % Service Limit State II for Positive Flexure (6.10.4)
    c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbc_pos(2,:)-0.95*Parameters.Beam.Fy; % Top flange (in compression for positive flexure)
    c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbt_pos(2,:)-0.95*Parameters.Beam.Fy; % Bottom Flange (in Tension for positive flexure)
    
    % Shear Limit State (6.10.9)
    c(end+1) = max(max(Parameters.Demands.(beamSection{i}).SL.LRFD.V))-Beam.Vn;
    
    % Force Compact in positive Moment Region
    c(end+1) = 2*Beam.Dcp/Beam.tw - 3.76*sqrt(Parameters.Beam.E/Parameters.Beam.Fy); 
    
    % Strength Limit State I for Positive Flexure (6.10.6)
    % Check for compact in positive moment region 6.10.6.2.2
    if 2*Beam.Dcp/Beam.tw <= 3.76*sqrt(Parameters.Beam.E/Parameters.Beam.Fy) && Beam.ind/Beam.tw <= 150
        Beam.SectionComp = 1; % Compact
        c(end+1) = max(Parameters.Demands.(beamSection{i}).SL.LRFD.M_pos)-Beam.Mn_pos; % 6.10.7.1 for compact sections
        c(end+1) = 0;
    else
        Beam.SectionComp = 0; % Non-Compact
        c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbc_pos(1,:)-Beam.Fn_pos; %Compression flange 6.10.7.2.1
        c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbt_pos(1,:)-Beam.Fn_pos; %Tension flange
    end
    
% ------- Negative Moment Region --------------------------------------
    if Parameters.Spans > 1
        if Beam.CoverPlate.Ratio > 0
            % Negative moment region proportions
            c(end+1) = Beam.CoverPlate.ind/Beam.tw - 150;
            c(end+1) = Beam.CoverPlate.bf/(2*Beam.CoverPlate.tf) - 12;
            c(end+1) = Beam.CoverPlate.t - 2*Beam.tf; % Coverplate size limit
        end

        % Service Limit State II for Negative Flexure (6.10.4)
        c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbc_neg(2,:)-Beam.Fcrw;
        
        % Strength Limit State I
        c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbc_neg(1,:)-Beam.Fn_neg;
        c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fbt_neg(1,:)-Parameters.Beam.Fy;
    end
    
% ------- Fatigue Limit State Check --------------------------------------
    % Check top and bottom flanges
    c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fT_ftg - Parameters.Design.FTH;
    c(end+1) = Parameters.Demands.(beamSection{i}).SL.LRFD.fB_ftg - Parameters.Design.FTH;
    
    ceq = [];
end
end %DesignCheck()





