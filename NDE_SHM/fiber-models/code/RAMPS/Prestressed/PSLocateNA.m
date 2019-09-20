function [ a, c, exitflag] = PSLocateNA( Parameters )
%PSLocateNA Find the distance from the compression face (deck top surface) to the neutral axis
%   vargin = Parameters - structure containing structure info
%   vargout = c - distance in inches to neutral axis
if Parameters.Deck.fc <= 4000
    beta = .85;
else
    beta = max(0.85-(Parameters.Deck.fc-4000)/1000*.05, 0.65);
end
% S5.7.3.1.1-2
k = 2*(1.04-Parameters.Beam.PSSteel.Fy/Parameters.Beam.PSSteel.Fu);
% NA is in deck - S5.7.3.1.1-4
c = Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fu/...
    (0.85*Parameters.Deck.fc*beta*Parameters.Deck.beff(1)+k*Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fu/...
    (Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter));

if beta*c>Parameters.Deck.t
    % NA is in member top flange
    exitflag = 2;
    c = (Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fu-0.85*Parameters.Deck.fc.*...
        (Parameters.Deck.beff(1)-Parameters.Beam.bft*Parameters.Beam.E/Parameters.Deck.E).*Parameters.Deck.t)...
        ./(0.85*Parameters.Deck.fc*beta*Parameters.Beam.bft*Parameters.Beam.E/Parameters.Deck.E+k*Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fu/...
        (Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter));

    if beta*c>(Parameters.Deck.t+Parameters.Beam.tft(1)+Parameters.Beam.tft(2)/2)
        % NA is in web
        exitflag = 3;
        c = (Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fu-0.85*Parameters.Deck.fc.*...
        (Parameters.Deck.t*(Parameters.Deck.beff(1)-Parameters.Beam.tw*Parameters.Beam.E/Parameters.Deck.E)+(Parameters.Beam.tft(1)+Parameters.Beam.tft(2)/2)*Parameters.Beam.E/Parameters.Deck.E*(Parameters.Beam.bft-Parameters.Beam.tw)))...
        /(0.85*Parameters.Deck.fc*beta*Parameters.Beam.tw*Parameters.Beam.E/Parameters.Deck.E+k*Parameters.Beam.PSSteel.At*Parameters.Beam.PSSteel.Fu/...
        (Parameters.Beam.d+Parameters.Deck.t-Parameters.Beam.PSCenter));
        
    end
else
    exitflag = 1;
end

a = beta*c;
    
end

