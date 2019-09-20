function Parameters = GetLRFDResistance( Parameters )
%% FLEXURAL RESISTENCE FOR COMPOSITE SECITONS IN POSITIVE FLEXURE %%
% Flexural resistence code follows procedure outlined in AASHTO LRFD
% Appendix C6

%% Determine the location of the plastic neutral axis and the plastic moment
% for the short term composite section via cases defined in
% AASHTO LRFD Manual Appendix D6

    % Define variables
    Fy = Parameters.Beam.Fy; % Yeild Strength of flanges and web
    tf = Parameters.Beam.tf; % Thickness of both top and bottom flanges 
    bf = Parameters.Beam.bf; % Width of both top and bottom flanges
    tw = Parameters.Beam.tw; % Thickness of the web
    Dw = Parameters.Beam.d-2*Parameters.Beam.tf; % Depth of Web
    fc = Parameters.Deck.fc; % Compressive strength of concrete deck
    ts = Parameters.Deck.t; % Thickness of concrete deck
    bs = Parameters.Deck.beInt; % Effective width of concrete deck

    % Calculate plastic forces
    Ps = .85*fc*bs*ts; % Plastic Force for slab [lbs]
    Pc = Fy*tf*bf; % Plastic Force for compression flange [lbs]
    Pw = Fy*tw*Dw; % Plastic Force for web [lbs]
    Pt = Fy*tf*bf; % Plastic Force for tension flange [lbs]

    % Calculate plastic moment and location of plastic neutral axis.
    % (Reference AASHTO Appendix D6)
    A = Pt + Pw;
    B = Pc + Pw + Pt;
    C = Pc + Ps;

    % Is plastic neutral axis located in the slab?
    if Ps > B % PNA located in slab and measured measured from top of slab
        PNAst = ts*((Pw+Pt+Pw)/Ps); % [inches] location of PNA from top of slab 
        dc = (tf/2)+(ts-PNAst); % [inches] distance from comp. flange NA to PNA
        dw = (Dw/2)+tf+(ts-PNAst); % [inches] distance from web NA to PNA
        dt = (tf/2)+Dw+tf+(ts-PNAst); % [inches] distance from tens. flange NA to PNA
        Mp = [((PNAst^2)*Ps)/(2*ts)]+[Pc*dc+Pt*dt+Pw*dw]; % [lb-in] Case 3-7 in AD6
        Parameters.Beam.Mp = Mp; %Plastic moment of the composite section
        Parameters.Beam.Dpst = PNAst; % [inches] distance from the top of slab to PNA 
        Parameters.Beam.Dcp = 0; % depth of the web in compression at the plastic moment
    % Is the plastic neutral axis in the top flange?
    elseif B > Ps % PNA located in top flange and measured from top of flange
        PNAst = (tf/2)*[((Pw+Pt-Ps)/Pc)+1]; % [inches] location of PNA from top of flange 
        ds = (ts/2)+PNAst; % [inches] distance from slab NA to PNA
        dw = (Dw/2)+(tf-PNAst); % [inches] distance from web NA to PNA
        dt = (tf/2)+Dw+(tf-PNAst); % [inches] distance from tens. flange NA to PNA
        Mp = [Pc/(2*tf)]*[PNAst^2+(tf-PNAst)^2]+[Ps*ds+Pw*dw+Pt*dt]; % [lb-in] Case 2 in AD6
        Parameters.Beam.Mp = Mp; %Plastic moment of the composite section
        Parameters.Beam.Dpst = PNAst+ts; % [inches] distance from the top of slab to PNA 
        Parameters.Beam.Dcp = 0; % depth of the web in compression at the plastic moment
    % Is the plastic neutral axis in the web?
    else % A>C and PNA in web measured from bottom of top flange
        PNAst = (Dw/2)*[((Pt-Pc-Ps)/Pw)+1]; % [inches] location of PNA from bottom of top flange 
        ds = (ts/2)+tf+PNAst; % [inches] distance from slab NA to PNA
        dc = (tf/2)+PNAst; % [inches] distance from comp. flange NA to PNA
        dt = (tf/2)+Dw-PNAst; % [inches] distance from tens. flange NA to PNA
        Mp = [Pw/(2*Dw)]*[PNAst^2+((Dw-PNAst)^2)]+[Ps*ds+Pc*dc+Pt*dt]; % [lb-in] Case 1 in AD6
        Parameters.Beam.Mp = Mp; %Plastic moment of the composite section
        Parameters.Beam.Dpst = PNAst+ts+tf; % [inches] distance from the top of slab to PNA 
        Parameters.Beam.Dcp = PNAst; % Depth of web in compression at plastic moment
    end
    
%% FOR POSITIVE FLEXURE: 
% DETERMINE NOMINAL MOMENT RESISTENCE FOR COMPACT/NON-COMPACT SECTION 

% Next step in LRFD is to check ductility, Section 6.10.7.3. This was already done in the
% design code (See PlateGirderDesignLRFD.m). Otherwise if creating a model of an exisiting strucutre we
% are not concerned if the structure meets ductility requirement.

% Check if section is considered compact or non-compact. Compact sections shall satisfy the requirements of
% Article 6.10.7.1. Otherwise, the section shall be considered noncompact and shall satisfy the requirements
% of Article 6.10.7.2.
        
    % Define variables
    Dw = Parameters.Beam.ind; % Depth of Web
    tw = Parameters.Beam.tw; % Thickness of the web
    bf = Parameters.Beam.bf; % Width of both top and bottom flanges
    tf = Parameters.Beam.tf; % Thickness of both flanges
    Dcp = Parameters.Beam.Dcp; % Depth of web in compression at plastic moment
    Fy = Parameters.Beam.Fy; % Yeild Strength of flanges and web [psi]
    E = Parameters.Beam.E; % Young's Modulus [psi]
    Dp = Parameters.Beam.Dpst; % [inches] distance from the top of slab to PNA
    Dt = Parameters.Beam.d + Parameters.Deck.t; % [inches] Total depth of composite section
    MDL_pos = Parameters.Design.Load.MDL_pos; % Design non-composite dead load contribution (non-superimposed)
    MSDL_pos = Parameters.Design.Load.MSDL_pos; % Design Composite dead laod contribution (superimposed)
    MSDW_pos = Parameters.Design.Load.MSDW_pos; % Superimposed dead load fro wearing surface
    STNc = Parameters.Beam.STNc; % [in^3] Non-composite elastic section modulus measured from top flange
    SBNc = Parameters.Beam.SBNc; % [in^3] Non-composite elastic section modulus measured from bottom flange
    STlt = Parameters.Beam.STlt; % [in^3] Long term composite elastic section modulus measured from top flange
    SBlt = Parameters.Beam.SBlt; % [in^3] Non-composite elastic section modulus measured from bottom flange
    STst = Parameters.Beam.STst; % [in^3] Short term composite elastic section modulus measured from top flange
    SBst = Parameters.Beam.SBst; % [in^3] Short term composite elastic section modulus measured from bottom flange
    Rh = 1.0; % Hybrid factor (AASHTO LRFD Section 6.10.1.10.1)
    Rb = 1.0; % Web Load-Shedding Factor (6.10.1.10.2) 
    
    %Moment of Inertia 
    Parameters.Beam.Iyc = Parameters.Beam.tf*Parameters.Beam.bf^3/12; %Moment of Inertia of the compression flange
    Parameters.Beam.Iyt = Parameters.Beam.Iyc; %Moment of Inertia of the Tension Flange (same as compression flange b/c symetrical cross section)
    Parameters.Beam.Iy = 2*Parameters.Beam.tf*Parameters.Beam.bf^3/12+(Parameters.Beam.d-2*Parameters.Beam.tf)*Parameters.Beam.tw^3/12; %Moment of inertia of the entire steel section

    % Determine yield Moment of Composite Section in Positive Flexure for
    % Strength Limit State (Appendix D6.2.2)
    Mad_c = min((Fy -(abs(1.25*MDL_pos)/STNc) - (abs(1.25*MSDL_pos)/STlt) - (abs(1.50*MSDW_pos)/STlt))*STst); 
    Mad_t = min((Fy -(abs(1.25*MDL_pos)/SBNc) - (abs(1.25*MSDL_pos)/SBlt) - (abs(1.50*MSDW_pos)/SBlt))*SBst); 
    Myc = 1.25*(abs(MDL_pos)+abs(MSDL_pos)) + 1.50*(abs(MSDW_pos)) + Mad_c; %lb-in, factored for strength
    Myt = 1.25*(abs(MDL_pos)+abs(MSDL_pos)) + 1.50*(abs(MSDW_pos)) + Mad_t; %lb-in, factored for strength
    My = min(Myc, Myt); %lb-in
    Myst = Fy*SBst;
    
    % Define nominal flexural resistence variables for Non-Compact Case
    Fnc_pos = Rb*Rh*Fy; % nominal flexural resistance of the compression flange determined as specified in Article 6.10.7.2.2 
    Fnt_pos = Rh*Fy; % nominal flexural resistance of the tension flange determined as specified in Article 6.10.7.2.2
    fbc_pos = max(Parameters.Beam.fbc_pos); % Comp. Flange stress calculated without consideration of flange lateral bending determined as specified in Article 6.10.1.6
    fbt_pos = max(Parameters.Beam.fbt_pos); % Tens. Flange stress calculated without consideration of flange lateral bending determined as specified in Article 6.10.1.6
    
    % Is section compact?
    CompCheck1= Dw/tw;
    CompCheck2 = 2*Dcp/tw;
    CompCheck3 = 3.76*sqrt(E/Fy);
  
    if CompCheck1 <= 150 && CompCheck2 <= CompCheck3 % Section is Compact (AASHTO LRFD 6.10.6.2.2)
        Parameters.Beam.Comp = 1; % 1 = Compact
        if Dp <= 0.1*Dt % AASHTO LRFD 6.10.7.1.2
           Parameters.Beam.Mn_pos = Mp;
           M = [1.3*Rh*My; Mp];
        else
           Parameters.Beam.Mn_pos = Mp*[1.07-(0.7*Dp/Dt)];
           M = [1.3*Rh*My; Mp*[1.07-(0.7*Dp/Dt)]];
        end
        
        if Parameters.Spans > 1
           Parameters.Beam.Mn_pos = min(M); %See commentary C6.10.7.1.2
        end
             
    else
        Parameters.Beam.Comp = 2;
    end
    
    Parameters.Beam.Fn_pos = Fnc_pos;
        
%% FOR NEGATIVE FLEXURE: (Spans > 1)
% DETERMINE NOMINAL MOMENT RESISTENCE FOR COMPACT/NON-COMPACT SECTION 

% Compression flange (bottom flange in neg. moment region) is discretely
% braced for all RAMPS Models

% Determine depth of web in compression in elastic range for non-composite
% section
    Parameters.Beam.DcNc = Parameters.Beam.d/2-Parameters.Beam.tf; %in 

% Define variables
    L = max(Parameters.Length); % [inches] span length
    NumDia = max(Parameters.NumDia); % Number of Diaphrams
    bf = Parameters.Beam.bf; % Width of both top and bottom flanges
    tf = Parameters.Beam.tf; % Thickness of both flanges
    tw = Parameters.Beam.tw; % Thickness of the web
    Fy = Parameters.Beam.Fy; % Yeild Strength of flanges and web [psi]
    Fyr = 0.7*Fy; % compression-flange stress at the onset of nominal yielding within the cross-section, including residual stress effects, but not including compression-flange lateral bending
    E = Parameters.Beam.E; % Young's Modulus [psi]
    DcNc = Parameters.Beam.DcNc; %in Depth of web in compresstion in elastic range for non-composite section
    Rh = 1.0; % Hybrid Factor
    Rb = 1.0; % Web Load-Shedding Factor
    Cb = 1.0; % moment gradient modifier.
    
if Parameters.Spans > 1    
    % Redefine variables if cover plate is used
    if Parameters.Beam.CoverPlate.Length > 0
        tf = Parameters.Beam.CoverPlate.tf; % Thickness of both flanges
        DcNc = Parameters.Beam.CoverPlate.d/2-Parameters.Beam.CoverPlate.tf; %in
    end

% Web Bend-buckling Resistance (6.10.4.2.2 and 6.10.1.9.1)
    k = 9/((DcNc/Dw)^2);
    Parameters.Beam.Fcrw = (0.9*E*k)/((Dw/tw)^2);
    
% Check compression flange local buckling resistence, AASHTO 6.10.8.2.2 (LB =  Local Buckling)
    lf = bf/(2*tf); % slenderness ratio for the compression flange
    lpf = 0.38*sqrt(E/Fy); %limiting slenderness ratio for a compact flange
    lrf = 0.56*sqrt(E/Fyr); % limiting slenderness ratio for a noncompact flange

    if lf <= lpf % Flange is compact
        Fnc_neg_LB = Rb*Rh*Fy;
    else % Flange is non-compact
        Fnc_neg_LB = [1-(1-(Fyr/(Rh*Fy))*((lf-lpf)/(lrf-lpf)))]*Rb*Rh*Fy;
    end

% Check compression flange Lateral Torsional Buckling, AASHTO 6.10.8.2.3
% (LT = Lateral Torsional Buckling)
    rt = bf/sqrt(12*(1+((DcNc*tw)/(3*bf*tf)))); % [inches] effective radius of gyration for lateral torsional buckling
    Lb = L/(NumDia+1); % Unbraced length [inches]
    Lp = 1.0*rt*sqrt(E/Fy); % [inches] limiting unbraced length to achieve the nominal flexural resistance of RbRhFyc under uniform bending
    Lr = pi*rt*sqrt(E/Fyr); % [inches] limiting unbraced length to achieve the onset of nominal yielding in either flange under uniform bending with consideration of compressionflange residual stress effects
            
    if Lb <= Lp % Unbraced length is compact
        Fnc_neg_LT = Rb*Rh*Fy;
    elseif Lb > Lp && Lb <= Lr % Unbraced Length is Non-Compact
        Fnc_neg_LT = Cb*[1-(1-(Fyr/(Rh*Fy))*((Lb-Lp)/(Lr-Lp)))]*Rb*Rh*Fy;
    elseif Lb > Lr % Unbraced length is slender
        Fnc_neg_LT = (Cb*Rb*E*pi^2)/((Lb/rt)^2); % elastic lateral torsional buckling stress
    end

    Parameters.Beam.Fn_neg = min(Fnc_neg_LB, Fnc_neg_LT);
end
    
%% SHEAR RESISTENCE: 
% For unstiffened webs
    if (Parameters.Beam.d-2*Parameters.Beam.tf)/Parameters.Beam.tw <= 2.46*sqrt(Parameters.Beam.E/Parameters.Beam.Fy)
        Parameters.Beam.Vn = 0.58*Parameters.Beam.Fy*(Parameters.Beam.d-2*Parameters.Beam.tf)*Parameters.Beam.tw; %lb
    elseif (Parameters.Beam.d-2*Parameters.Beam.tf)/Parameters.Beam.tw <= 3.07*sqrt(Parameters.Beam.E/Parameters.Beam.Fy)
        Parameters.Beam.Vn = 1.48*Parameters.Beam.tw^2*sqrt(Parameters.Beam.Fy*Parameters.Beam.E);
    else
        Parameters.Beam.Vn = 4.55*Parameters.Beam.tw^3*Parameters.Beam.E/(Parameters.Beam.d-2*Parameters.Beam.tf);
    end    
    
    
    
end
    
        
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                


