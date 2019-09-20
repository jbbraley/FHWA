function [ Parameters ] = GetPSForce( Parameters )
%GETPSFORCE Calculates the actual effective prestress force after all losses
%   Based on the Girder section and the number of PS strands and their diameter
%% Stress in Prestressing Tendons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate eccentricity
if ~isfield(Parameters.Beam, 'PSEcc')
    e = Parameters.Beam.yb-Parameters.Beam.PSCenter;
    Parameters.Beam.PSEcc = e;
else
    e = Parameters.Beam.PSEcc;
end

if ~isfield(Parameters.Beam.PSSteel,'At')
    Parameters.Beam.PSSteel.At = Parameters.Beam.PSSteel.NumStrands*(Parameters.Beam.PSSteel.Aps);
end

% %% Get Section Forces and Moments
% % Get Single Line Girder Results
% Parameters.Design.Code = 'LRFD';
% Parameters.Design.DesignLoad = 'A';
% Parameters.Design = GetTruckLoads(Parameters.Design);
% Parameters = AASHTODesign(Parameters);
% % Calculate Section Forces
% Parameters = PSSectionForces(Parameters);

%% Stress Limits
% Immediately prior to transfer
Fpi = 0.75*Parameters.Beam.PSSteel.Fu; % T5.9.3-1 (psi)

% Elastic Shortening
% Midspan Moment due to member self-weight
Mg = Parameters.Design.Load.maxDLM_POI*Parameters.Beam.Weight/12;
%Prestress loss due to elastic shortening in pretensioned members - S5.9.5.2.3
Fpes = (Parameters.Beam.PSSteel.At*Fpi*(Parameters.Beam.Ix+(e)^2*Parameters.Beam.A)-e*Mg*Parameters.Beam.A)/...
    (Parameters.Beam.PSSteel.At*(Parameters.Beam.Ix+e^2*Parameters.Beam.A)+Parameters.Beam.A*Parameters.Beam.Ix*Parameters.Beam.Eci/Parameters.Beam.PSSteel.E); % psi

% Prestressing stress at transfer
Parameters.Beam.PSSteel.Fpt = Fpi-Fpes;
% Prestressing force at transfer
Pt = Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fpt; %lb

% Shrinkage losses
if ~isfield(Parameters,'RHumidity')
    RH = 70;
else
    RH = Parameters.RHumidity;
end
Fpsr = (17-.15*RH)*1000; %psi S5.9.5.4.2

% Creep Losses - S5.9.5.4.3
Fcgp = Fpes/(Parameters.Beam.PSSteel.E/Parameters.Beam.Eci);
Fcdp = (max(Parameters.Design.Load.DLdeck)+Parameters.Design.Load.DLhaunch+Parameters.Design.Load.DLdiaphragm)*Parameters.Design.Load.maxDLM_POI*e/Parameters.Beam.Ix+...
    (Parameters.Design.Load.MSDL_pos).*(Parameters.Beam.yBst-Parameters.Beam.PSCenter)./Parameters.Beam.Ist;
Fpcr = max(12*Fcgp-7*Fcdp,0);

%Relaxation - S5.9.5.4.4
Fpr2 = (20000-.4*Fpes-.2*(Fpsr+Fpcr))*.3;

%Total loss after transfer
DeltaFpt = max(Fpes+Fpsr+Fpcr+Fpr2);

% Final Effective prestress response
Parameters.Beam.PSSteel.Fpe = min(.80*Parameters.Beam.PSSteel.Fy, 0.75*Parameters.Beam.PSSteel.Fu-DeltaFpt);

% Total Prestress Force after losses
Parameters.Beam.PSForce = Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fpe;

end

