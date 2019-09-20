function Parameters = GetAASHTOLLDeflectionRequirement(Parameters)

% Apply Dyanmic Load Allowance to static wheel load (for LRFD only)
if strcmp(Parameters.Design.Code, 'LRFD')
   Impact = Parameters.Design.IMF;
else
   Impact = 1+Parameters.Design.Im; 
end

% Maximum deflection
maxDelta = Parameters.Design.maxDelta;

% Delta is in in^5
I = Parameters.Design.Load.DeltaPrime*maxDelta./Parameters.Length.*Impact*...
    Parameters.NumLane*Parameters.Design.MultiPres/Parameters.NumGirder;

Parameters.Beam.IstDelta = max(I); % in in^4

end % GetAASHTODeflectionRequirement()