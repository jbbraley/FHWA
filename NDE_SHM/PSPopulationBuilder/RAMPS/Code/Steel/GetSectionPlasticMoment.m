function ArgBm = GetSectionPlasticMoment(ArgBm, Parameters, Section)
% Determine Plastic Moment: AASHTO LRFD Manual Appendix D6

% Define Variables
 
Fy = Parameters.Beam.Fy; % Yeild Strength of flanges and web [psi]
fc = Parameters.Deck.fc; % Compressive strength of concrete deck
ts = Parameters.Deck.t; % Thickness of concrete deck
tf = ArgBm.tf; % Thickness of both top and bottom flanges 
bf = ArgBm.bf; % Width of both top and bottom flanges
tw = ArgBm.tw; % Thickness of the web
Dw = ArgBm.ind; % Depth of Web
Dt = ArgBm.Dt; % [inches] Total depth of composite section   
bs = Parameters.Deck.be.(['be' (Section)]); % Effective width of concrete deck

% Calculate plastic forces
ArgBm.Ps = .85*fc*bs*ts; % Plastic Force for slab [lbs]
ArgBm.Pc = Fy*tf*bf; % Plastic Force for compression flange [lbs]
ArgBm.Pw = Fy*tw*Dw; % Plastic Force for web [lbs]
ArgBm.Pt = Fy*tf*bf; % Plastic Force for tension flange [lbs]

% Calculate plastic moment and location of plastic neutral axis.
% (Reference AASHTO Appendix D6)
A = ArgBm.Pt + ArgBm.Pw;
B = ArgBm.Pc + ArgBm.Pw + ArgBm.Pt;
C = ArgBm.Pc + ArgBm.Ps;

if Parameters.Deck.Offset<0
    % Is plastic neutral axis located in the slab?
    if ArgBm.Ps/ts*(ts+Parameters.Deck.Offset) > B % PNA located in slab and measured measured from top of slab
        PNAst = ts*((ArgBm.Pc+ArgBm.Pt+ArgBm.Pw)/ArgBm.Ps); % [inches] location of PNA from top of slab 
        ArgBm.dc = (tf/2)+Parameters.Deck.Offset+(ts-PNAst); % [inches] distance from comp. flange NA to PNA
        ArgBm.dw = (Dw/2)+tf+Parameters.Deck.Offset+(ts-PNAst); % [inches] distance from web NA to PNA
        ArgBm.dt = (tf/2)+Dw+tf+Parameters.Deck.Offset+(ts-PNAst); % [inches] distance from tens. flange NA to PNA
        Mp = (((PNAst^2)*ArgBm.Ps)/(2*ts))+(ArgBm.Pc*ArgBm.dc+ArgBm.Pt*ArgBm.dt+ArgBm.Pw*ArgBm.dw); % [lb-in] Case 3-7 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = 0; % depth of the web in compression at the plastic moment
    elseif ArgBm.Ps/ts*(ts+Parameters.Deck.Offset+tf)+ArgBm.Pc > A
        PNAst = (ArgBm.Pw+ArgBm.Pt+ArgBm.Pc-ArgBm.Ps*(1+Parameters.Deck.Offset/ts))/(ArgBm.Ps/ts+2*ArgBm.Pc/tf); % [inches] location of PNA from top of flange 
        ds = (ts+Parameters.Deck.Offset+PNAst)/2; % [inches] distance from slab NA to PNA
        ArgBm.dw = (Dw/2)+(tf-PNAst); % [inches] distance from web NA to PNA
        ArgBm.dt = (tf/2)+Dw+(tf-PNAst); % [inches] distance from tens. flange NA to PNA
        Mp = (ArgBm.Pc/(2*tf))*(PNAst^2+(tf-PNAst)^2)+(ArgBm.Ps/ts*(ts+Parameters.Deck.Offset+PNAst)*ds+ArgBm.Pw*ArgBm.dw+ArgBm.Pt*ArgBm.dt); % [lb-in] Case 2 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst+ts+Parameters.Deck.Offset; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = 0; % depth of the web in compression at the plastic moment
    elseif ArgBm.Ps+ArgBm.Pc-ArgBm.Pw/Dw*(Parameters.Deck.Offset+tf)>ArgBm.Pt+ArgBm.Pw/Dw*(Dw+Parameters.Deck.Offset+tf)
        PNAst = (ArgBm.Pw+ArgBm.Pt-ArgBm.Pc-ArgBm.Ps*(1+Parameters.Deck.Offset/ts+tf/ts))/(ArgBm.Ps/ts+2*ArgBm.Pw/Dw); % [inches] location of PNA from bottom of top flange 
        ds = (ts+Parameters.Deck.Offset+tf+PNAst)/2; % [inches] distance from slab NA to PNA
        ArgBm.dc = (tf/2)+PNAst; % [inches] distance from comp. flange NA to PNA
        ArgBm.dt = (tf/2)+Dw-PNAst; % [inches] distance from tens. flange NA to PNA
        Mp = (ArgBm.Pw/(2*Dw))*(PNAst^2+((Dw-PNAst)^2))+(ArgBm.Ps/ts*(ts+Parameters.Deck.Offset+tf+PNAst)*ds+ArgBm.Pc*ArgBm.dc+ArgBm.Pt*ArgBm.dt); % [lb-in] Case 1 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst+ts+Parameters.Deck.Offset+tf; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = PNAst; % Depth of web in compression at plastic moment
    else
        PNAst = (Dw/2)*(((ArgBm.Pt-ArgBm.Pc-ArgBm.Ps)/ArgBm.Pw)+1); % [inches] location of PNA from bottom of top flange 
        ds = (ts/2)+Parameters.Deck.Offset+tf+PNAst; % [inches] distance from slab NA to PNA
        ArgBm.dc = (tf/2)+PNAst; % [inches] distance from comp. flange NA to PNA
        ArgBm.dt = (tf/2)+Dw-PNAst; % [inches] distance from tens. flange NA to PNA
        Mp = (ArgBm.Pw/(2*Dw))*(PNAst^2+((Dw-PNAst)^2))+(ArgBm.Ps*ds+ArgBm.Pc*ArgBm.dc+ArgBm.Pt*ArgBm.dt); % [lb-in] Case 1 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst+ts+Parameters.Deck.Offset+tf; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = PNAst; % Depth of web in compression at plastic moment
    end
else
    if ArgBm.Ps > B % PNA located in slab and measured measured from top of slab
        PNAst = ts*((ArgBm.Pc+ArgBm.Pt+ArgBm.Pw)/ArgBm.Ps); % [inches] location of PNA from top of slab 
        ArgBm.dc = (tf/2)+Parameters.Deck.Offset+(ts-PNAst); % [inches] distance from comp. flange NA to PNA
        ArgBm.dw = (Dw/2)+tf+Parameters.Deck.Offset+(ts-PNAst); % [inches] distance from web NA to PNA
        ArgBm.dt = (tf/2)+Dw+tf+Parameters.Deck.Offset+(ts-PNAst); % [inches] distance from tens. flange NA to PNA
        Mp = (((PNAst^2)*ArgBm.Ps)/(2*ts))+(ArgBm.Pc*ArgBm.dc+ArgBm.Pt*ArgBm.dt+ArgBm.Pw*ArgBm.dw); % [lb-in] Case 3-7 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = 0; % depth of the web in compression at the plastic moment
    % Is the plastic neutral axis in the top flange?
    elseif C > A % PNA located in top flange and measured from top of flange
        PNAst = (tf/2)*(((ArgBm.Pw+ArgBm.Pt-ArgBm.Ps)/ArgBm.Pc)+1); % [inches] location of PNA from top of flange 
        ds = (ts/2)+Parameters.Deck.Offset+PNAst; % [inches] distance from slab NA to PNA
        ArgBm.dw = (Dw/2)+(tf-PNAst); % [inches] distance from web NA to PNA
        ArgBm.dt = (tf/2)+Dw+(tf-PNAst); % [inches] distance from tens. flange NA to PNA
        Mp = (ArgBm.Pc/(2*tf))*(PNAst^2+(tf-PNAst)^2)+(ArgBm.Ps*ds+ArgBm.Pw*ArgBm.dw+ArgBm.Pt*ArgBm.dt); % [lb-in] Case 2 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst+ts+Parameters.Deck.Offset; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = 0; % depth of the web in compression at the plastic moment
    % Is the plastic neutral axis in the web?
    else % A>C and PNA in web measured from bottom of top flange
        PNAst = (Dw/2)*(((ArgBm.Pt-ArgBm.Pc-ArgBm.Ps)/ArgBm.Pw)+1); % [inches] location of PNA from bottom of top flange 
        ds = (ts/2)+Parameters.Deck.Offset+tf+PNAst; % [inches] distance from slab NA to PNA
        ArgBm.dc = (tf/2)+PNAst; % [inches] distance from comp. flange NA to PNA
        ArgBm.dt = (tf/2)+Dw-PNAst; % [inches] distance from tens. flange NA to PNA
        Mp = (ArgBm.Pw/(2*Dw))*(PNAst^2+((Dw-PNAst)^2))+(ArgBm.Ps*ds+ArgBm.Pc*ArgBm.dc+ArgBm.Pt*ArgBm.dt); % [lb-in] Case 1 in AD6
        ArgBm.Mp = Mp; %Plastic moment of the composite section
        ArgBm.Dpst = PNAst+ts+Parameters.Deck.Offset+tf; % [inches] distance from the top of slab to PNA 
        ArgBm.Dcp = PNAst; % Depth of web in compression at plastic moment
    end
end

% Check Ductility
if ArgBm.Dpst <= 0.42*Dt
    ArgBm.Ductility = 'Ok';
else
    ArgBm.Ductility = 'No Good';
end

end

