%% Calculates Moment Gradient Modifier (Cb) for use in resiatance calculations for lateral torsional buckling
% In current condition, only calculates Cb for two-span continuous where
% each span is identical in configuration (NumDia, SpanLength, etc.)

function ArgOut = GetMomentGradient(ArgIn1, ArgIn2, Parameters)

% Lengths
    SpanLength = round(Parameters.Length/12)'; %in ft

% Set Fixed DOFS to 0 in stiffness matrix
    Fixed = zeros(Parameters.Spans, 1);
    for i = 1:Parameters.Spans
        Fixed(i) = sum(SpanLength(1:i));
    end
    Fixed = [1; 2*Fixed + 1];


%% Find compressive (or tensile) moments at POIs for LL and DL

    range = (Fixed(1)+1)/2:(Fixed(1+1)+1)/2;
%     range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    
    % POI at pier
    Loc = 1.0;
    POI = round(Loc*(range(end)-range(1)))+range(1);
    
    % Largest Compressive Moment over pier
    % Used for indexing only, largest compressive stress over pier is already
    % calculated in GetSectionForces
    [MLL_pier, index] = min(Parameters.Design.Load.M_Min(1:end-1, POI)); % LL and index
    MDL_pier = min(Parameters.Design.Load.M_Min(end, POI)); %DL
            
    % POI at diaphragm
    Loc = min(Parameters.NumDia)/(1+min(Parameters.NumDia));
    POI = round(Loc*(range(end)-range(1)))+range(1);
   
    % Compressive Moment at diaphragm due to load case that causes largest
    % compressive moment over pier
    maxMLL_dia = Parameters.Design.Load.M_Max(index, POI);
    minMLL_dia = Parameters.Design.Load.M_Min(index, POI);
    
    maxMDL_dia = Parameters.Design.Load.M_Max(end, POI);
    minMDL_dia = Parameters.Design.Load.M_Min(end, POI);
    
    % LIVE LOAD
    if maxMLL_dia > 0 && minMLL_dia > 0
        MLL_dia = min(maxMLL_dia, minMLL_dia); %Smallest Tensile
    else
        MLL_dia = minMLL_dia; %Largest Compressive
    end
    
    % DEAD LOAD
    if maxMDL_dia > 0 && minMDL_dia > 0
        MDL_dia = min(maxMDL_dia, minMDL_dia); %Smallest Tensile
    else
        MDL_dia = minMDL_dia; %Largest Compressive
    end
       
    % POI midway between diaphragm and pier
    UnbracedLength = min(Parameters.Length)/min(Parameters.NumDia+1);
    Loc = Loc + ((UnbracedLength/min(Parameters.Length))/2);
    POI = round(Loc*(range(end)-range(1)))+range(1);
    
    % Compressive Moment at midpoint due to load case that causes largest
    % compressive moment over pier
    maxMLL_mid = Parameters.Design.Load.M_Max(index, POI);
    minMLL_mid = Parameters.Design.Load.M_Min(index, POI);
    
    maxMDL_mid = Parameters.Design.Load.M_Max(end, POI);
    minMDL_mid = Parameters.Design.Load.M_Min(end, POI);
    
    % LIVE LOAD
    if maxMLL_mid > 0 && minMLL_mid > 0
        MLL_mid = min(maxMLL_mid, minMLL_mid); %Smallest Tensile
    else
        MLL_mid = minMLL_mid; %Largest Compressive
    end

    % DEAD LOAD
    if maxMDL_mid > 0 && minMDL_mid > 0
        MDL_mid = min(maxMDL_mid, minMDL_mid); %Smallest Tensile
    else
        MDL_mid = minMDL_mid; %Largest Compressive
    end
    
%% Compute DL moments for non-superimposed and superimposed dead load
    
    MSDW_pier = MDL_pier*ArgIn2.DeadLoad.wSDW; %Dead load due to wearing surface
    MSDL_pier = MDL_pier*ArgIn2.DeadLoad.wSDL; %Superimposed DL (DL2)
    MDL_pier = MDL_pier*ArgIn2.DeadLoad.wDL;  %Non-Superimposed DL (DL1)

    MSDW_dia = MDL_dia*ArgIn2.DeadLoad.wSDW; %Dead load due to wearing surface
    MSDL_dia = MDL_dia*ArgIn2.DeadLoad.wSDL; %Superimposed DL (DL2)
    MDL_dia = MDL_dia*ArgIn2.DeadLoad.wDL;  %Non-Superimposed DL (DL1)
    
    MSDW_mid = MDL_mid*ArgIn2.DeadLoad.wSDW; %Dead load due to wearing surface
    MSDL_mid = MDL_mid*ArgIn2.DeadLoad.wSDL; %Superimposed DL (DL2)
    MDL_mid = MDL_mid*ArgIn2.DeadLoad.wDL;  %Non-Superimposed DL (DL1)
    
%% Compute Stresses at POIs
    
    % -1 in front of stress calculations to flip sign for tens/comp in
    % accordance with AASHTO LRFD 6.10.8.2.3 (compression is +, tension -)

    % No Coverplate
    f2 = -1*(1.25*(MDL_pier/ArgIn1.S.SBnc)+1.25*(MSDL_pier/ArgIn1.S.SBnc)+1.5*(MSDW_pier/ArgIn1.S.SBnc)...
        +1.75*(MLL_pier/ArgIn1.S.SBnc)); % Largest Compressive stress (over pier)
  
    % Cover Plate
    if ArgIn1.CoverPlate.t > 0
        f2 = -1*(1.25*(MDL_pier/ArgIn1.CoverPlate.S.SBnc)+1.25*(MSDL_pier/ArgIn1.CoverPlate.S.SBnc)+1.5*(MSDW_pier/ArgIn1.CoverPlate.S.SBnc)...
            +1.75*(MLL_pier/ArgIn1.CoverPlate.S.SBnc));
    end 

    f1 = -1*(1.25*(MDL_dia/ArgIn1.S.SBnc)+1.25*(MSDL_dia/ArgIn1.S.SBlt)+1.5*(MSDW_dia/ArgIn1.S.SBlt)...
        +1.75*(MLL_dia/ArgIn1.S.SBst)); % Largest compressive (or  smallest tesnsile) at diaphragm
    
    fmid = -1*(1.25*(MDL_mid/ArgIn1.S.SBnc)+1.25*(MSDL_mid/ArgIn1.S.SBlt)+1.5*(MSDW_mid/ArgIn1.S.SBlt)...
        +1.75*(MLL_mid/ArgIn1.S.SBst)); % Largest compressive (or  smallest tesnsile) at midpoint

%% Compute Cb Value

    if fmid/f2 > 1 || f2 == 0
        ArgOut = 1.0;
    else
        ArgOut = 1.75-1.05*(f1/f2)+0.3*(f1/f2)^2;
    end
end