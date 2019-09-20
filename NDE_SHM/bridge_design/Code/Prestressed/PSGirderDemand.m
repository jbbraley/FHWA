function [ Parameters ] = PSGirderDemand( Parameters )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if ~isfield(Parameters.Beam, 'PSEcc')
    e = Parameters.Beam.yb-Parameters.Beam.PSCenter;
    Parameters.Beam.PSEcc = e;
end
e = Parameters.Beam.PSEcc;


% Prestressing stress at transfer
Fpt = Parameters.Beam.PSSteel.Fpt;
% Final Effective prestress response
Fpe = Parameters.Beam.PSSteel.Fpe;

%% Development Length
% Transfer Length
Lt = 60*Parameters.Beam.PSSteel.d;

% Development Length
% Fully bonded strands
Ld_f = 1.6*(Parameters.Beam.PSSteel.Fs-2/3*Fpe)/1000*Parameters.Beam.PSSteel.d;
% Partially debonded strands
Ld_p = 5/4*Ld_f;

%% Flexural stresses
% Stress in prestressing strands at transfer, strength, and service conditions
% Girder Self weight moment
for i=1:Parameters.Spans
    %% Stress in prestressing strands at transfer, strength, and service conditions
    PSF(i).Strength = zeros(ceil(Parameters.Length(i)/2),2);
    PSF(i).Service = zeros(ceil(Parameters.Length(i)/2),2);
    PSF(i).Transfer = zeros(ceil(Parameters.Length(i)/2),2);
    PSF(i).Strength(:,1) = [1:ceil(Parameters.Length(i)/2)];
    PSF(i).Service(:,1) = [1:ceil(Parameters.Length(i)/2)];
    PSF(i).Transfer(:,1) = [1:ceil(Parameters.Length(i)/2)];
    
    % Stresses at Transfer   
    PSF(i).Strength(1:ceil(Lt),2) = max(Fpe)/Lt*(PSF(i).Strength(1:ceil(Lt),1));

    PSF(i).Service(1:ceil(Lt),2) = max(Fpe)/Lt*(PSF(i).Service(1:ceil(Lt),1));

    PSF(i).Transfer(1:ceil(Lt),2) = max(Fpt)/Lt*(PSF(i).Transfer(1:ceil(Lt),1));
    
    % Stresses over Development Length
    PSF(i).Strength(ceil(Lt)+1:ceil(max(Ld_f)+Lt),2) = (max(Parameters.Beam.PSSteel.Fs)-max(Fpe))/max(Ld_f)*(PSF(i).Strength(ceil(Lt)+1:ceil(max(Ld_f)+Lt),1)-(Lt))+max(Fpe);
    
    % Stresses in central region
    PSF(i).Strength(ceil(max(Ld_f)+Lt):end,2) = max(Parameters.Beam.PSSteel.Fs);

    PSF(i).Service(ceil(Lt)+1:end,2) = min(Fpe);

    PSF(i).Transfer(ceil(Lt)+1:end,2) = max(Fpt);
    
    % Transform stress into force
    PSF(i).Strength(:,2) = PSF(i).Strength(:,2)*Parameters.Beam.PSSteel.At;

    PSF(i).Service(:,2) = PSF(i).Service(:,2)*Parameters.Beam.PSSteel.At;
    
    PSF(i).Transfer(:,2) = PSF(i).Transfer(:,2)*Parameters.Beam.PSSteel.At;
   
    %% Stress in Beam
    Moment(i).Uniform(:,1) = [1:ceil(Parameters.Length(i)/2)];
    Moment(i).Uniform = -(Moment(i).Uniform.^2/2-Moment(i).Uniform*Parameters.Length(i)/2);
    % Beam Stresses after transfer
    Stress(i).Transfer(:,1) = [1:ceil(Parameters.Length(i)/2)];
    Stress(i).Transfer(:,2) = -PSF(i).Transfer(:,end)/Parameters.Beam.A+PSF(i).Transfer(:,end)*e/Parameters.Beam.St-Moment(i).Uniform(:)*Parameters.Design.Load.DLstringer/Parameters.Beam.St; %girder top stress in psi
    Stress(i).Transfer(:,3) = -PSF(i).Transfer(:,end)/Parameters.Beam.A-PSF(i).Transfer(:,end)*e/Parameters.Beam.Sb+Moment(i).Uniform*Parameters.Design.Load.DLstringer/Parameters.Beam.Sb; %girder bottom stress in psi

    % Girder top stress under prestressing and dead load after losses
    Stress(i).Service(:,1) = -PSF(i).Service(12:12:end,end)/Parameters.Beam.A+PSF(i).Service(12:12:end,end)*e/Parameters.Beam.St-... 
        (Parameters.Design.Load.DLstringer+Parameters.Design.Load.DLdeck(1)+Parameters.Design.Load.DLhaunch+Parameters.Design.Load.DLdiaphragm(1))*Moment(i).Uniform(12:12:end)/Parameters.Beam.St...
        -(Parameters.Design.Load.DLcurb+Parameters.Design.Load.DLparapet)*Moment(i).Uniform(12:12:end)/Parameters.Beam.STlt(1);

    % Girder top stress after losses under sum of all loads (Service I)
    Stress(i).Service(:,2) = Stress(i).Service(:,1)-...
        (max(Parameters.Design.DF(2)*Parameters.Design.IMF*Parameters.Design.Load.M_Max(:,(i-1)*Parameters.Length(i)/12+2:(i)*floor(Parameters.Length(i)/12/2)+1))).'/Parameters.Beam.STst(1);

    % Girder top stress under LL + ½(PS + DL) after losses
    Stress(i).Service(:,3) = Stress(i).Service(:,1)/2-...
        (max(Parameters.Design.DF(2)*Parameters.Design.IMF*Parameters.Design.Load.M_Max(:,(i-1)*Parameters.Length(i)/12+2:(i)*floor(Parameters.Length(i)/12/2)+1))).'/Parameters.Beam.STst(1);

    % Girder bottom stress after losses under prestress and dead load
    Stress(i).Service(:,4) = -PSF(i).Service(12:12:end,end)/Parameters.Beam.A-PSF(i).Service(12:12:end,end)*e/Parameters.Beam.Sb+... 
        (Parameters.Design.Load.DLstringer+Parameters.Design.Load.DLdeck(1)+Parameters.Design.Load.DLhaunch+Parameters.Design.Load.DLdiaphragm(1))*Moment(i).Uniform(12:12:end)/Parameters.Beam.Sb...
        +(Parameters.Design.Load.DLcurb+Parameters.Design.Load.DLparapet)*Moment(i).Uniform(12:12:end)/Parameters.Beam.SBst(1);

    % Girder bottom stress under all loads (Service III)
    Stress(i).Service(:,5) = Stress(i).Service(:,4)+...
        0.8*(max(Parameters.Design.DF(2)*Parameters.Design.IMF*Parameters.Design.Load.M_Max(:,(i-1)*Parameters.Length(i)/12+2:(i)*floor(Parameters.Length(i)/12/2)+1))).'/Parameters.Beam.SBst(1);

    % Deck slab top stress under full load
    Stress(i).Service(:,6) = (-(Parameters.Design.Load.DLcurb+Parameters.Design.Load.DLparapet)*Moment(i).Uniform(12:12:end)-...
        (max(Parameters.Design.DF(2)*Parameters.Design.IMF*Parameters.Design.Load.M_Max(:,(i-1)*Parameters.Length(i)/12+2:(i)*floor(Parameters.Length(i)/12/2)+1))).')/Parameters.Beam.SDst(1)/(Parameters.Beam.E/Parameters.Deck.E);
    
    
     %% Longitudinal Steel at top of girder
    [T, I] = max(Stress(i).Transfer(:,2));
    C = Stress(i).Transfer(I,3);
    NA = T/((T-C)/Parameters.Beam.d);
    PA = @(d) (Parameters.Beam.bft+(d-Parameters.Beam.tft(1)).*(Parameters.Beam.tw-Parameters.Beam.bft)/sum(Parameters.Beam.tft(2:end))).*(T-(T-C)/Parameters.Beam.d.*d);
    if NA<Parameters.Beam.tft(1)
        F(1) = Parameters.Beam.bft*NA*((T-(T-C)/Parameters.Beam.d.*NA)+T)/2;
    elseif NA<sum(Parameters.Beam.tft)
        F(1) = Parameters.Beam.bft*Parameters.Beam.tft(1)*((T-(T-C)/Parameters.Beam.d.*Parameters.Beam.tft(1))+T)/2;
        F(2) = integral(PA,Parameters.Beam.tft(1),NA);
    else        
        F(1) = Parameters.Beam.bft*Parameters.Beam.tft(1)*((T-(T-C)/Parameters.Beam.d.*Parameters.Beam.tft(1))+T)/2;
        F(2) = integral(PA,Parameters.Beam.tft(1),sum(Parameters.Beam.tft));
        F(3) = Parameters.Beam.tw*(NA-sum(Parameters.Beam.tft))*(T-((T-C)/Parameters.Beam.d.*(sum(Parameters.Beam.tft)+NA))/2);
    end

    % Required area of reinforcing steel
    Parameters.Beam.RFSteel.A(i) = 1.2*sum(F)/min(0.5*Parameters.Beam.RFSteel.Fy, 30000);              
end

for i=1:length(Parameters.Length)
%% Cracking Moment
Parameters.Beam.Mcr(i) = -Parameters.Beam.SBst(1).*(-max(PSF(i).Service(:,end))/Parameters.Beam.A-max(PSF(1).Service(:,end))*e/Parameters.Beam.Sb+...
    max(Moment(i).Uniform)*((Parameters.Design.Load.wDL)/Parameters.Beam.Sb+...
    (Parameters.Design.Load.wSDL)./Parameters.Beam.SBst(1))-240*sqrt(Parameters.Beam.fc/1000))+...
    max(Moment(i).Uniform)*(Parameters.Design.Load.wDL+Parameters.Design.Load.wSDL);

%% Maximum Girder Stress at Transfer
% Parameters.Design.Transfer.StressT_max(i) = max(Stress(i).Transfer(:,2));
Parameters.Design.Transfer.StressT_min(i) = min(Stress(i).Transfer(end,2)); %X
Parameters.Design.Transfer.StressB_min(i) = min(Stress(i).Transfer(end,3)); %X
% Parameters.Design.Transfer.StressB_max(i) = max(Stress(i).Transfer(:,3));

%% Maximum Girder Stress under Service Loads
Parameters.Design.Service.StressT_max(i) = max(Stress(i).Service(:,2));
Parameters.Design.Service.StressT_min(i) = min(Stress(i).Service(:,2)); %X
Parameters.Design.Service.StressB_min(i) = min(Stress(i).Service(ceil(size(Stress(i).Service(:,5),1)/2):end,5)); %X
Parameters.Design.Service.StressB_max(i) = max(Stress(i).Service(ceil(size(Stress(i).Service(:,5),1)/2):end,5)); %X
%% Maximum Girder Stress under prestressing after losses
Parameters.Design.PS1.StressT_max(i) = max(Stress(i).Service(:,1));
Parameters.Design.PS1.StressT_min(i) = min(Stress(i).Service(:,1)); %X
Parameters.Design.PS1.StressB_max(i) = max(Stress(i).Service(ceil(size(Stress(i).Service(:,4),1)/2):end,4));
Parameters.Design.PS1.StressB_min(i) = min(Stress(i).Service(ceil(size(Stress(i).Service(:,4),1)/2):end,4)); %X
%% Max. Girder stress under LL + ½(PS + DL) after losses
Parameters.Design.PS2.StressT_max(i) = max(Stress(i).Service(:,3));
Parameters.Design.PS2.StressT_min(i) = min(Stress(i).Service(:,3)); %X
%% Max. Deck stress under full load
Parameters.Design.Deck.Stress_max(i) = max(Stress(i).Service(:,6));
Parameters.Design.Deck.Stress_min(i) = min(Stress(i).Service(:,6)); %X

end

% Ultimate moment under strength conditions
Parameters.Design.Strength.M_pos = Parameters.LRFD.M_pos;

%% Over reinforced parameter
Parameters.Beam.cde = max(Parameters.Beam.NA)/(Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter);

%% Temp Storage
Temp = getappdata(0,'Temp');
if isfield(Temp,'NA')
Temp.NA(end+1) = Parameters.Beam.NA;
Temp.Fpt(end+1) = Parameters.Beam.PSSteel.Fpt;
else
    Temp.NA = Parameters.Beam.NA;
    Temp.Fpt = Parameters.Beam.PSSteel.Fpt;
end
setappdata(0,'Temp',Temp)

end

