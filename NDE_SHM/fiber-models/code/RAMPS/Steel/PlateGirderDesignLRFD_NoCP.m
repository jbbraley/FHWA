%% DESIGNS SECTION WITHOUT A COVER PLATE

function [Parameters, exitflag] = PlateGirderDesignLRFD_NoCP(Parameters, CShapes, LShapes)
%% Parallel comp settings
options = optimset('Algorithm','interior-point','Display','off');
% ms = MultiStart('UseParallel','always');
%%
Parameters.Beam.Type = 'Plate';
Parameters.Design.Type = 'Plate';

% Longest girder controls on spand to depth ratio
Parameters.Beam.d = floor(max(Parameters.Length/Parameters.Design.MaxSpantoDepth));

designFalse = 1;
count = 0;
tic
while designFalse == 1 && count < 11
    count = count+1;
    % Varying parameters, upper bounds and lower bounds
    % x0 = [flange width  flange thickness  web thickness]
    ub = [Parameters.GirderSpacing/3 Parameters.GirderSpacing/20 Parameters.GirderSpacing/20];
    lb = [6 .5 1/4];
    x0(1) = (ub(1)+lb(1))/2 + (ub(1)-lb(1))/4*randn(1,1);
    x0(2) = (ub(2)+lb(2))/2 + (ub(2)-lb(2))/4*randn(1,1);
    x0(3) = (ub(3)+lb(3))/2 + (ub(3)-lb(3))/4*randn(1,1);

    while any(x0 < lb) || any(x0 > ub)      
        for ii = 1:length(x0)
            x0(ii) = (ub(ii)+lb(ii))/2 + (ub(ii)-lb(ii))/4*randn(1,1);
        end
    end

    Parameters.Beam.StartPoints = x0;
    
    % Find rolled Parameters.Beam or built up girder with I and A that satisfy all
    % constraints while minimizing A        
        area = @(x)BeamArea(x);
        con = @(x)DesignCheckCompact(x, CShapes, LShapes);
            [xC,fvalC,exitflagC,outputC] = fmincon(area,x0,[],[],[],[],lb,ub,con,options);

        area = @(x)BeamArea(x);
        con = @(x)DesignCheckNoncompact(x, CShapes, LShapes);
            [xNC,fvalNC,exitflagNC,outputNC] = fmincon(area,x0,[],[],[],[],lb,ub,con,options);

    % Beam compact requirements 1 = compact; 2 = noncompact
    if (BeamArea(xNC)<= BeamArea(xC)) && exitflagNC > 0
        x = xNC;
        exitflag = exitflagNC;
        Parameters.Beam.Comp = 2;
    elseif exitflagC > 0
        x = xC;
        exitflag = exitflagC;
        Parameters.Beam.Comp = 1;
    else
        designFalse = 1;
        continue
    end

    Parameters.Beam.x = x;

    x_temp(1) = floor(x(1)*2)/2;
    x_temp(2) = floor(x(2)*4)/4;
    x_temp(3) = floor(x(3)*8)/8;

    if Parameters.Beam.Comp == 1    
        [c, ceq] = DesignCheckCompact(x_temp, CShapes, LShapes);      
    else
        [c, ceq] = DesignCheckNoncompact(x_temp, CShapes, LShapes);
    end

    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    Parameters.Beam.Constraints = c;
    
    if all(c<=0)
        designFalse = 0;
        continue
    end    

    x_temp(1) = round(x(1)*2)/2;
    x_temp(2) = round(x(2)*4)/4;
    x_temp(3) = round(x(3)*8)/8;
    
    if Parameters.Beam.Comp == 1
        [c, ceq] = DesignCheckCompact(x_temp, CShapes, LShapes);
    else
        [c, ceq] = DesignCheckNoncompact(x_temp, CShapes, LShapes);
    end

    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    Parameters.Beam.Constraints = c;

    if all(c<=0)
        designFalse = 0;
        continue
    end    

    x_temp(1) = ceil(x(1)*2)/2;
    x_temp(2) = ceil(x(2)*4)/4;
    x_temp(3) = ceil(x(3)*8)/8;

    if Parameters.Beam.Comp == 1
        [c, ceq] = DesignCheckCompact(x_temp, CShapes, LShapes);
    else
        [c, ceq] = DesignCheckNoncompact(x_temp, CShapes, LShapes);
    end
    
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    Parameters.Beam.Constraints = c;

    if all(c<=0)
        designFalse = 0;
    else
        designFalse = 1;
    end    
end

Parameters.Beam.Iterations = count;
Parameters.Beam.DesignTime = toc;

% Returns exit flag of 0 if 10 iterations were completed and a
% solution was not found
if count > 10
    exitflag = 0;
end

%% Calls GetBeamParameters.Beam.m to return Parameters.Beam properties
function A = BeamArea(x)
A = 2*x(1)*x(2) + x(3)*(Parameters.Beam.d - 2*x(2));

% aData = getappdata(0, 'aData');
% aData(end+1, 1) = A;
% aData(end, 2:4) = x;
% setappdata(0, 'aData',aData);

end

%% DESIGN CHECKS FOR COMPACT SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Updated as of 08/06/2014 to match ASHTOO LRFD Design Version 2012

% Design checks and relavent AASHTO 2012 Sections
%   1) Depth Criteria (2.5.2.6.3) 
%   2)Flexural Capacity, Section Forces, Diaphragm Requirements (See GetSectionForces.m, GetLRFDResistance.m, GetDiaphragmRequirement.m)
%   3) Web Thickness Criteria (6.7.3)
%   4) Cross-Section Proportion Limits (6.10.2)
%   5) Constructibility Proportion Limits (6.10.3)
%   6a) Service Limit State Criteria - Positive Moment Region (6.10.4)
%   6b) Service Limit State Criteria - Negative Moment Region (6.10.8)
%   7a) Strength Limit State Criteria - Positive Moment Region (6.10.6)
%   7b) Strength Limit State Criteria - Negative Moment Region (6.10.8)

function [c, ceq] = DesignCheckCompact(x, CShapes, LShapes)
    
% Assign Parameters.Beam properties
    Parameters.Beam.bf = x(1);
    Parameters.Beam.tf = x(2);
    Parameters.Beam.tw = x(3);
    Parameters.Beam.Dt = Parameters.Beam.d+Parameters.Deck.t; %Caclulates total section depth for ductility requirement
    Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
    Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12 + Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.tf/2+Parameters.Beam.ind/2)^2)...
        + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
    Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind;

%%(1) Depth Criteria (2.5.2.6.3) 
    % OLD DEPTH CRITERIA
    %c(1) = max(Parameters.Length/30) - Parameters.Beam.d;
    %c(2) = max(Parameters.Length/25) - (Parameters.Beam.d + Parameters.Deck.t); % For composite section onlyif length(Parameters.Length) == 1
    if Parameters.Spans == 1
        c(1) = max(Parameters.Length*.040) - (Parameters.Beam.d + Parameters.Deck.t); %Overall depth of composite I-beam
        c(2) = max(Parameters.Length*.033) - Parameters.Beam.d; %Depth of I-Beam portion of composite I-Beam
    else %Spans are >1
        c(1) = max(Parameters.Length*.032) - (Parameters.Beam.d + Parameters.Deck.t); %Overall depth of composite I-beam
        c(2) = max(Parameters.Length*.027) - Parameters.Beam.d; %Depth of I-Beam portion of composite I-Beam
    end
   
%%(2) Diapragm, Section Forces, Flexural Resistance, Ductility
    Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
    Parameters = GetSectionForces(Parameters);
    %Get LRFD Beam capacity
    Parameters = GetLRFDResistance(Parameters);
    % 6.10.7.3 Ductility
    c(3) = Parameters.Beam.Dpst/Parameters.Beam.Dt - 0.42; 
    
%%(3) Web Thickness Criteria (6.7.3)
    c(4) = 0.3125 - Parameters.Beam.tw;
    
%%(4) Cross-Section Proportion Limits
    % Web Proportions 6.10.2.1
    c(5) = Parameters.Beam.ind/Parameters.Beam.tw - 150; % For webs without longitudinal stiffeners
    % Flange Proportions 6.10.2.2
    c(6) = Parameters.Beam.bf/(2*Parameters.Beam.tf) - 12;
    c(7) = Parameters.Beam.ind/6 - Parameters.Beam.bf;
    c(8) = 1.1*Parameters.Beam.tw - Parameters.Beam.tf;
    c(9) = 0.1 - Parameters.Beam.Iyc/Parameters.Beam.Iyt;  
    c(10) = Parameters.Beam.Iyc/Parameters.Beam.Iyt-10; 

%%(5) Constructibility Proportion Limits (6.10.3)

%%(6a) Service Limit State II for Positive Flexure (6.10.4)
    c(11) = Parameters.Beam.fbc_pos(2,:)-0.95*Parameters.Beam.Fy; % Top flange (in compression for positive flexure)
    c(12) = Parameters.Beam.fbt_pos(2,:)-0.95*Parameters.Beam.Fy; % Bottom Flange (in Tension for positive flexure)
    
%%(7a) Strength Limit State I for Positive Flexure (6.10.6)
    % Flexure Criteria
    c(13) = 2*Parameters.Beam.Dcp/Parameters.Beam.tw-3.76*sqrt(Parameters.Beam.E/Parameters.Beam.Fy); % 6.10.6.2.2
    c(14) = max(Parameters.LRFD.M_pos)-Parameters.Beam.Mn_pos; % 6.10.7.1 for compact sections
    %Shear Criteria
    c(15) = max(max(Parameters.LRFD.V))-Parameters.Beam.Vn;
    
%%Negative Moment Region
    if Parameters.Spans > 1        
    %%(6b) Service Limit State II for Negative Flexure (6.10.4) 
        % 6.10.4.2.2 for continuous span members in which non-composite
        % sections are utilized in negative flexure regions only (see
        % Commentary C10.6.4.2.2). Lateral bending (fl) is taken to be 0
        % therefore per commentary C6.10.6.4.2.2, service doesn not control
        % therefore contraints for top/bottom flange need not be considered
        %c(16) = Parameters.Beam.fbc_neg(2,:)-0.95*Parameters.Beam.Fy; %Bottom flange
        %c(17) = Parameters.Beam.fbt_neg(2,:)-0.95*Parameters.Beam.Fy; %Top flange 
        c(16) = Parameters.Beam.fbc_neg(2,:)-Parameters.Beam.Fcrw;

    %%(7b) Strength Limit State I for Negative Flexure (6.10.8)
        % 6.10.8.1.1 Discretely Braced Flanges in Compression (Bottom
        % flange is discretely braced in comp. at the neg. region)
        c(19) = Parameters.Beam.fbc_neg(1,:)-Parameters.Beam.Fn_neg; 
        % 6.10.8.1.3 Continuously braced flanges in Tension or Compression
        % (Top flange iin tension is continuously braced by deck at neg.
        % moment region
        c(20) = Parameters.Beam.fbt_neg(1,:)-Parameters.Beam.Fy;
    end
    
% cData = getappdata(0, 'cData');
% cData(end+1,:) = c;
% setappdata(0, 'cData',cData);

    
% DEFLECTION CRITERIA IS OPTIONAL (BUT NOT ENCOURAGED). REFERENCE AASHTO
% 2.5.2.6.3
%%Deflection criteria
% c(7) = Parameters.Beam.IstDelta - Parameters.Beam.Ist;
% 
% NEUTRAL AXIS CHECK MAY BE LEFT OVER FROM ASD CODE. WAS NOT FOUND IN LRFD
% CONSTRAINTS
% %% Neutral Axis Check
% % Neutral axis check - Use short term composite deck area
% c(8) = Parameters.Deck.Ast*Parameters.Deck.t/2 - Parameters.Beam.A*Parameters.Beam.d/2;
% 
    
ceq = []; 
end %DesignCheckComp()

%% DESIGN CHECKS FOR NON-COMPACT SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Updated as of 08/06/2014 to match ASHTOO LRFD Design Version 2012

% Design checks and relavent AASHTO 2012 Sections
%   1) Depth Criteria (2.5.2.6.3) 
%   2) Flexural Capacity, Section Forces, Diaphragm Requirements (See GetSectionForces.m, GetLRFDResistance.m, GetDiaphragmRequirement.m)
%   3) Web Thickness Criteria (6.7.3)
%   4) Cross-Section Proportion Limits (6.10.2)
%   5) Constructibility Proportion Limits (6.10.3)
%   6a) Service Limit State Criteria - Positive Moment Region (6.10.4)
%   6b) Service Limit State Criteria - Negative Moment Region (6.10.8)
%   7a) Strength Limit State Criteria - Positive Moment Region (6.10.6)
%   7b) Strength Limit State Criteria - Negative Moment Region (6.10.8)

function [c, ceq] = DesignCheckNoncompact(x, CShapes, LShapes)

% Assign Parameters.Beam properties
    Parameters.Beam.bf = x(1);
    Parameters.Beam.tf = x(2);
    Parameters.Beam.tw = x(3);
    Parameters.Beam.Dt = Parameters.Beam.d+Parameters.Deck.t; %Caclulates total section depth for ductility requirement
    Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
    Parameters.Beam.Ix = 2*(Parameters.Beam.bf*Parameters.Beam.tf^3/12 + Parameters.Beam.bf*Parameters.Beam.tf*(Parameters.Beam.tf/2+Parameters.Beam.ind/2)^2)...
        + Parameters.Beam.tw*Parameters.Beam.ind^3/12;
    Parameters.Beam.A = 2*Parameters.Beam.bf*Parameters.Beam.tf + Parameters.Beam.tw*Parameters.Beam.ind;

%%(1) Depth Criteria (2.5.2.6.3) 
    % OLD DEPTH CRITERIA
    %c(1) = max(Parameters.Length/30) - Parameters.Beam.d;
    %c(2) = max(Parameters.Length/25) - (Parameters.Beam.d + Parameters.Deck.t); % For composite section onlyif length(Parameters.Length) == 1
    if Parameters.Spans == 1
        c(1) = max(Parameters.Length*.040) - (Parameters.Beam.d + Parameters.Deck.t); %Overall depth of composite I-beam
        c(2) = max(Parameters.Length*.033) - Parameters.Beam.d; %Depth of I-Beam portion of composite I-Beam
    else %Spans are >1
        c(1) = max(Parameters.Length*.032) - (Parameters.Beam.d + Parameters.Deck.t); %Overall depth of composite I-beam
        c(2) = max(Parameters.Length*.027) - Parameters.Beam.d; %Depth of I-Beam portion of composite I-Beam
    end

%%(2) Diapragm, Section Forces, Flexural Resistance, Ductility
    Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
    Parameters = GetSectionForces(Parameters);
    %Get LRFD Beam capacity
    Parameters = GetLRFDResistance(Parameters);
    % 6.10.7.3 Ductility
    c(3) = Parameters.Beam.Dpst/Parameters.Beam.Dt - 0.42; 
    
%%(3) Web Thickness Criteria (6.7.3)
    c(4) = 0.3125 - Parameters.Beam.tw;
    
%%(4) Cross-Section Proportion Limits
    % Web Proportions 6.10.2.1
    c(5) = Parameters.Beam.ind/Parameters.Beam.tw - 150; % For webs without longitudinal stiffeners
    % Flange Proportions 6.10.2.2
    c(6) = Parameters.Beam.bf/(2*Parameters.Beam.tf) - 12;
    c(7) = Parameters.Beam.ind/6 - Parameters.Beam.bf;
    c(8) = 1.1*Parameters.Beam.tw - Parameters.Beam.tf;
    c(9) = 0.1 - Parameters.Beam.Iyc/Parameters.Beam.Iyt;  
    c(10) = Parameters.Beam.Iyc/Parameters.Beam.Iyt-10; 

%%(5) Constructibility Proportion Limits (6.10.3)

%%(6a) Service Limit State II for Positive Flexure (6.10.4)
    %Service limit state does not control and therefore does not need to be
    %checked for non-compact sections in positive flexure. (see Commentary
    %section C6.10.4.2.2)
    
%%(7a) Strength Limit State I for Positive Flexure (6.10.6)
    % Flexure Criteria
    c(11) = 3.76*sqrt(Parameters.Beam.E/Parameters.Beam.Fy)-2*Parameters.Beam.Dcp/Parameters.Beam.tw; % 6.10.6.2.2
    c(12) = Parameters.Beam.fbc_pos(1,:)-Parameters.Beam.Fn_pos; %Compression flange 6.10.7.2.1
    c(13) = Parameters.Beam.fbt_pos(1,:)-Parameters.Beam.Fn_pos; %Tension flange 
    %Shear Criteria
    c(14) = max(max(Parameters.LRFD.V))-Parameters.Beam.Vn;
    
%%Negative Moment Region
    if Parameters.Spans > 1
    %%(6b) Service Limit State II for Negative Flexure (6.10.4) 
         % 6.10.4.2.2 for continuous span members in which non-composite
        % sections are utilized in negative flexure regions only (see
        % Commentary C10.6.4.2.2). Lateral bending (fl) is taken to be 0
        % therefore per commentary C6.10.6.4.2.2, service doesn not control
        % therefore contraints for top/bottom flange need not be considered
        %c(16) = Parameters.Beam.fbc_neg(2,:)-0.95*Parameters.Beam.Fy; %Bottom flange
        %c(17) = Parameters.Beam.fbt_neg(2,:)-0.95*Parameters.Beam.Fy; %Top flange 
        c(15) = Parameters.Beam.fbc_neg(2,:)-Parameters.Beam.Fcrw; %Web Bend-buckling must be checked for service.

    %%(7b) Strength Limit State I for Negative Flexure (6.10.8)
        % 6.10.8.1.1 Discretely Braced Flanges in Compression (Bottom
        % flange is discretely braced in comp. at the neg. region)
        c(16) = Parameters.Beam.fbc_neg(1,:)-Parameters.Beam.Fn_neg; 
        % 6.10.8.1.3 Continuously braced flanges in Tension or Compression
        % (Top flange iin tension is continuously braced by deck at neg.
        % moment region
        c(17) = Parameters.Beam.fbt_neg(1,:)-Parameters.Beam.Fy;
    end 

% cData = getappdata(0, 'cData');
% cData(:,end+1) = c;
% setappdata(0, 'cData',cData);

% DEFLECTION CRITERIA IS OPTIONAL (BUT NOT ENCOURAGED). REFERENCE AASHTO
% 2.5.2.6.3
%%Deflection criteria
% c(7) = Parameters.Beam.IstDelta - Parameters.Beam.Ist;
% 
% NEUTRAL AXIS CHECK MAY BE LEFT OVER FROM ASD CODE. WAS NOT FOUND IN LRFD
% CONSTRAINTS
% %% Neutral Axis Check
% % Neutral axis check - Use short term composite deck area
% c(8) = Parameters.Deck.Ast*Parameters.Deck.t/2 - Parameters.Beam.A*Parameters.Beam.d/2;
%  

ceq = [];
end %DesignCheckNc()

end