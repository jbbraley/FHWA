function ArgBm = CompactCheckLRFD(ArgBm,Parameters)

% Determine compactness in positive and negative regions

if (2*ArgBm.Dcp)/ArgBm.tw  <= 3.76*sqrt(Parameters.Beam.E/Parameters.Beam.Fy)...
        && ArgBm.ind/ArgBm.tw <= 150
    ArgBm.SectionComp = 1; % Section compact in positive moment region
else
    ArgBm.SectionComp = 0; % Section non-compact in positive moment region
end
    
if Parameters.Spans > 1
    if ArgBm.lf < ArgBm.lpf
        ArgBm.FlangeComp = 0; % Flange compact in negative moment region
    elseif ArgBm.CoverPlate.lf >= ArgBm.lpf && ArgBm.lf <= ArgBm.lrf
        ArgBm.FlangeComp = 1; % Flange non-compact in negative moment region
    elseif ArgBm.lf > ArgBm.lrf
        ArgBm.FlangeComp = -1; % Flange slender in negative moment region
    end
    if ArgBm.Lb < ArgBm.Lp
        ArgBm.WebComp = 0; % Web compact in negative moment region
    elseif ArgBm.Lb >= ArgBm.Lp && ArgBm.Lb <= ArgBm.Lr
        ArgBm.WebComp = 1; % Web non-compact in negative moment region
    elseif ArgBm.Lb > ArgBm.Lr
        ArgBm.WebComp = -1; % Web slender in negative moment region
    end
end
end


            
