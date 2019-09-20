function [ Parameters ] = PSGirderCapacity( Parameters )
%% Stress is Prestressing strands at nominal flexural resistance at midspan
% Calculate eccentricity
if ~isfield(Parameters.Beam, 'PSEcc')
    e = Parameters.Beam.yb-Parameters.Beam.PSCenter;
    Parameters.Beam.PSEcc = e;
end
if ~isfield(Parameters.Beam, 'PSCenter')
    Parameters.Beam.PSCenter = Parameters.Beam.yb - Parameters.Beam.PSEcc;
end

% Compressive stress due to effective prestress
Parameters = GetPSForce(Parameters);

[a, c, NAexitflag] = PSLocateNA(Parameters);
Parameters.Beam.NA = c;
% S5.7.3.1.1-2
k = 2*(1.04-Parameters.Beam.PSSteel.Fy/Parameters.Beam.PSSteel.Fu);

Parameters.Beam.PSSteel.Fs = Parameters.Beam.PSSteel.Fu*(1-k*c/(Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter));

%% Flexural Resistance
% Moment Capacity (lb-in)
if NAexitflag==1
    Parameters.Beam.Mn_pos = min(Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fs.*(Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter-Parameters.Beam.NA./2)); % lb-in
elseif NAexitflag==2
    Parameters.Beam.Mn_pos = min(Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fs.*(Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter-Parameters.Deck.t/2)-...
        0.85*Parameters.Beam.fc*Parameters.Beam.bft*a*(a-Parameters.Deck.t)*(1/2)); % lb-in

else
    Parameters.Beam.Mn_pos = min(Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fs.*(Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter-Parameters.Deck.t/2)...
        -0.85*Parameters.Beam.fc*Parameters.Beam.bft*(Parameters.Beam.tft(1)+Parameters.Beam.tft(2)/2)*(Parameters.Deck.t+(Parameters.Beam.tft(1)+Parameters.Beam.tft(2)/2))/2 ...
        -0.85*Parameters.Beam.fc*Parameters.Beam.tw*(a-Parameters.Deck.t-sum(Parameters.Beam.tft))*(a+sum(Parameters.Beam.tft))/2);% lb-in
end
    

Fpb = Parameters.Beam.PSForce/Parameters.Beam.A+Parameters.Beam.PSForce*Parameters.Beam.PSEcc*Parameters.Beam.yb/Parameters.Beam.Ix;
% Allowable Tensile Stress
Fat = 6*sqrt(Parameters.Beam.fc);
% Stress Capacity (psi)
Parameters.Beam.Fn_pos = Fpb+Fat;


end

