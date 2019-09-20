% ASSIGNMENTS:
    % 1. Plastic Moment of Compsite Section (Mp)
    % 2. Distance to Plastic Neutral Axis (Dpst)
    % 3. Depth of Web in Compression at Plastic Moment (Dcp)
    % 4. Positive Moment Capacity for Compact Section (Mn_pos)
    % 5. Positive Moment Capacity for Non-compact Section (Fn_pos)
    % 6. Negative Moment Capacity (Fn_neg)

function ArgBm = GetLRFDResistance(ArgBm, ArgDem, Parameters, Section, Cb)
% Parameters.Beam.Int = GetLRFDResistance(Parameters.Beam.Int, Parameters.Demands.Int, Parameters, 'Interior', Cb);

% Define Variables
L = max(Parameters.Length); % [inches] span length
NumDia = max(Parameters.NumDia); % Number of Diaphrams
Fy = Parameters.Beam.Fy; % Yeild Strength of flanges and web [psi]
Fyr = 0.7*Fy; % compression-flange stress at the onset of nominal yielding within the cross-section, including residual stress effects, but not including compression-flange lateral bending
E = Parameters.Beam.E; % Young's Modulus [psi]   
tf = ArgBm.tf; % Thickness of both top and bottom flanges 
bf = ArgBm.bf; % Width of both top and bottom flanges
tw = ArgBm.tw; % Thickness of the web
Dw = ArgBm.ind; % Depth of Web
Dt = ArgBm.Dt; % [inches] Total depth of composite section   
DcNc = ArgBm.DcNc; %in Depth of web in compresstion in elastic range for non-composite section   
STNc = ArgBm.S.STnc; % [in^3] Non-composite elastic section modulus measured from top flange
SBNc = ArgBm.S.SBnc; % [in^3] Non-composite elastic section modulus measured from bottom flange 
STlt = ArgBm.S.STlt; % [in^3] Long term composite elastic section modulus measured from top flange
SBlt = ArgBm.S.SBlt; % [in^3] Non-composite elastic section modulus measured from bottom flange
STst = ArgBm.S.STst; % [in^3] Short term composite elastic section modulus measured from top flange
SBst = ArgBm.S.SBst; % [in^3] Short term composite elastic section modulus measured from bottom flange
Rh = 1.0; % Hybrid factor (AASHTO LRFD Section 6.10.1.10.1)
Rb = 1.0; % Web Load-Shedding Factor (6.10.1.10.2)


if isempty(Cb)
    Cb = 1.0; % Moment gradient modifier
end

MDL_pos = ArgDem.DeadLoad.MDL_pos; % Design non-composite dead load contribution (non-superimposed)
MSDL_pos = ArgDem.DeadLoad.MSDL_pos; % Design Composite dead laod contribution (superimposed)
MSDW_pos = ArgDem.DeadLoad.MSDW_pos; % Superimposed dead load fro wearing surface

%% %%%%%%%%%%%%%%%%%%%%% POSITIVE REGION %%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine plastic moment and location of plastic netral axis
ArgBm = GetSectionPlasticMoment(ArgBm,Parameters, Section);
Dcp = ArgBm.Dcp; % Depth of web in compression at plastic moment    
Dp = ArgBm.Dpst; % [inches] distance from the top of slab to PNA  

% Check if section is considered compact or non-compact. Compact sections shall satisfy the requirements of
% Article 6.10.7.1. Otherwise, the section shall be considered noncompact and shall satisfy the requirements
% of Article 6.10.7.2.
   
% Determine yield Moment of Composite Section in Positive Flexure for
% Strength Limit State (Appendix D6.2.2)
ArgBm.M_addc = min((Fy -(abs(1.25*MDL_pos)/STNc) - (abs(1.25*MSDL_pos)/STlt) - (abs(1.50*MSDW_pos)/STlt))*STst); % Additional moment needed for first yeild
ArgBm.M_addt = min((Fy -(abs(1.25*MDL_pos)/SBNc) - (abs(1.25*MSDL_pos)/SBlt) - (abs(1.50*MSDW_pos)/SBlt))*SBst); % Additional moment needed for first yeild
ArgBm.Myc = 1.25*(abs(MDL_pos)+abs(MSDL_pos)) + 1.50*(abs(MSDW_pos)) + ArgBm.M_addc; %lb-in, factored for strength
ArgBm.Myt = 1.25*(abs(MDL_pos)+abs(MSDL_pos)) + 1.50*(abs(MSDW_pos)) + ArgBm.M_addt; %lb-in, factored for strength
ArgBm.My = min(ArgBm.Myc, ArgBm.Myt); %lb-in
ArgBm.Myst = Fy*SBst;

% Define nominal flexural resistence variables for Non-Compact Case
ArgBm.Fnc_pos = Rb*Rh*Fy; % nominal flexural resistance of the compression flange determined as specified in Article 6.10.7.2.2 
ArgBm.Fnt_pos = Rh*Fy; % nominal flexural resistance of the tension flange determined as specified in Article 6.10.7.2.2

% Is section compact?
CompCheck1= Dw/tw;
CompCheck2 = 2*Dcp/tw;
CompCheck3 = 3.76*sqrt(E/Fy);

if CompCheck1 <= 150 && CompCheck2 <= CompCheck3 % Section is Compact (AASHTO LRFD 6.10.6.2.2)
    if Parameters.Spans == 1
        if Dp <= 0.1*Dt % AASHTO LRFD 6.10.7.1.2
           ArgBm.Mn_pos = ArgBm.Mp;               
        else
           ArgBm.Mn_pos = ArgBm.Mp*(1.07-(0.7*Dp/Dt)); 
        end
    else
        if Dp <= 0.1*Dt % AASHTO LRFD 6.10.7.1.2
           ArgBm.Mn_pos = min(ArgBm.Mp, min(1.3*Rh*ArgBm.My));               
        else
           ArgBm.Mn_pos = min(ArgBm.Mp*(1.07-0.7*Dp/Dt),min(1.3*Rh*ArgBm.My)); 
        end
    end
end

% Section is non-compact
ArgBm.Fn_pos = min(ArgBm.Fnc_pos, ArgBm.Fnt_pos);


%% %%%%%%%%%%%%%%%%%%%%% NEGATIVE REGION %%%%%%%%%%%%%%%%%%%%%%%%%%

if Parameters.Spans > 1 
    
    if ArgBm.CoverPlate.Length > 0  
        tf = ArgBm.CoverPlate.tf; % for section with coverplate
    end

    % Compression flange (bottom flange in neg. moment region) is discretely braced for all RAMPS Models

    % Web Bend-buckling Resistance (6.10.4.2.2 and 6.10.1.9.1)
    k = 9/((DcNc/Dw)^2);
    ArgBm.Fcrw = (0.9*E*k)/((Dw/tw)^2);

    % Check compression flange local buckling resistence, AASHTO 6.10.8.2.2 (LB =  Local Buckling)
    lf = bf/(2*tf); % slenderness ratio for the compression flange
    ArgBm.lf = lf;
    lpf = 0.38*sqrt(E/Fy); %limiting slenderness ratio for a compact flange
    ArgBm.lpf = lpf;
    lrf = 0.56*sqrt(E/Fyr); % limiting slenderness ratio for a noncompact flange
    ArgBm.lrf = lrf;

    if lf <= lpf % Flange is compact
        Fnc_neg_LB = Rb*Rh*Fy;
    else % Flange is non-compact
        Fnc_neg_LB = (1-(1-(Fyr/(Rh*Fy))*((lf-lpf)/(lrf-lpf))))*Rb*Rh*Fy;
    end

    % Check compression flange Lateral Torsional Buckling, AASHTO 6.10.8.2.3
    % (LT = Lateral Torsional Buckling)
    rt = bf/sqrt(12*(1+((DcNc*tw)/(3*bf*tf)))); % [inches] effective radius of gyration for lateral torsional buckling
    ArgBm.rt = rt;
    Lp = 1.0*rt*sqrt(E/Fy); % [inches] limiting unbraced length to achieve the nominal flexural resistance of RbRhFyc under uniform bending
    ArgBm.Lp = Lp;
    Lr = pi*rt*sqrt(E/Fyr); % [inches] limiting unbraced length to achieve the onset of nominal yielding in either flange under uniform bending with consideration of compressionflange residual stress effects
    ArgBm.Lr = Lr;

    % Unbraced Length
    if isfield (ArgBm, 'Stiffeners')
        Lb = ArgBm.Stiffeners.Spacing;
    else
        Lb = L/(NumDia+1); % Unbraced length [inches]
    end    
    ArgBm.Lb = Lb;

    if Lb <= Lp % Unbraced length is compact
        Fnc_neg_LT = Rb*Rh*Fy;
    elseif Lb > Lp && Lb <= Lr % Unbraced Length is Non-Compact
        Fnc_neg_LT = Cb*(1-((1-(Fyr/(Rh*Fy)))*((Lb-Lp)/(Lr-Lp))))*Rb*Rh*Fy;
    elseif Lb > Lr % Unbraced length is slender
        Fnc_neg_LT = (Cb*Rb*E*pi^2)/((Lb/rt)^2); % elastic lateral torsional buckling stress
    end

    % Save capacity without moment gradient modifier to beam
    % (conservative)
    ArgBm.Fn_neg = min(Fnc_neg_LB, Fnc_neg_LT);
end
    
%% %%%%%%%%%%%%%%%%%%%%%%%%% SHEAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

% For unstiffened webs
ks = 5; % Shear Buckling coefficient for unstiffened webs

if Dw/tw <= 1.12*sqrt(E*ks/Fy) %D/tw <= 1.12*sqrt(E*k/Fy) where k=5 AASHTO 6.10.9.2
    ArgBm.Vn = 0.58*Fy*Dw*tw; %lb
elseif Dw/tw <= 3.1305*sqrt(E/Fy)
    ArgBm.Vn = 1.4525*tw^2*sqrt(Fy*E);
else
    ArgBm.Vn = 4.55*tw^3*E/(Dw);
end       

end
                 



