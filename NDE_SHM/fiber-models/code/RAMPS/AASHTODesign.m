% (10/20/2014) NPR: Updated to reflect manual or RAMPS design

function Parameters = AASHTODesign(Parameters)
%% Get Initial Design Configuration
if strcmp(Parameters.Design.Code, 'ASD')   
    % Lanes
    if Parameters.RoadWidth >= 20*12 && Parameters.RoadWidth <= 24*12
        Parameters.NumLane = 2;
    elseif Parameters.RoadWidth > 24*12
        Parameters.NumLane = floor(Parameters.RoadWidth/144);
    else
        Parameters.NumLane = 1;
    end
    
    % Live Load Deflection
    Parameters.Design.maxDelta = 800;
    
    % Impact
    Parameters.Design.Im = 50./(Parameters.Length/12+125);
    if Parameters.Design.Im > 0.3
        Parameters.Design.Im = 0.3;
    end
        
    % Determine minimum stiffness for gamma and span length
    % LL Reduction Factor
    if Parameters.NumLane <= 2
        Parameters.Design.MultiPres = 1;
    elseif Parameters.NumLane == 3
        Parameters.Design.MultiPres = 0.9;
    else
        Parameters.Design.MultiPres = 0.75;
    end
    
    if Parameters.Deck.fc>=2400 && Parameters.Deck.fc<2900
        Parameters.Deck.N = 10;
    elseif Parameters.Deck.fc>=2900 && Parameters.Deck.fc<3600
        Parameters.Deck.N = 9;
    elseif Parameters.Deck.fc>=3600 && Parameters.Deck.fc<4600
        Parameters.Deck.N = 8;
    elseif Parameters.Deck.fc>=4600 && Parameters.Deck.fc<6000
        Parameters.Deck.N = 7;
    else
        Parameters.Deck.N = 6;
    end
    
    % Distribution Factors - Axle Distribution is 1/2 of wheel load
    % distribution
    Parameters.Design.DF = Parameters.GirderSpacing/5.5/12/2;   
elseif strcmp(Parameters.Design.Code, 'LFD')
    Parameters.Design.Code = 'LFD';
elseif strcmp(Parameters.Design.Code, 'LRFD')
    % Lanes 
    if Parameters.RoadWidth >= 20*12 && Parameters.RoadWidth <= 24*12
        Parameters.NumLane = 2;
    elseif Parameters.RoadWidth > 24*12
        Parameters.NumLane = floor(Parameters.RoadWidth/144);
    else
        Parameters.NumLane = 1;
    end
    % Live Load Deflection
    Parameters.Design.maxDelta = 800;
    
    % Impact -- Replaced by dynamic load below
    Parameters.Design.Im = 0;
    
    %Dynamic Load Allowance
    Parameters.Design.IMF = 1.33;  %To be applied to static wheel load, not pedestrian or lane load
    
    %Pedestrian Load in psf to be applied to the sidewalk
    Parameters.Design.Load.Pedestrian = zeros(1,2);
    if Parameters.Sidewalk.Right>24
        Parameters.Design.Load.Pedestrian(1) = 75;
    end
    if Parameters.Sidewalk.Right>24
        Parameters.Design.Load.Pedestrian(2) = 75;
    end
    
    %Multipresence factors - To be used only with Lever Rule
    Parameters.Design.MultiPres = 1; % 
%     if Parameters.NumLane == 1
        Parameters.Design.MulPres(1) = 1.2;
%     elseif Parameters.NumLane == 2
        Parameters.Design.MulPres(2) = 1;
%     elseif Parameters.NumLane == 3
        Parameters.Design.MulPres(3) = 0.85;
%     else
        Parameters.Design.MulPres(4) = 0.65;
%     end
    
    if Parameters.Deck.fc>=2400 && Parameters.Deck.fc<2900
        Parameters.Deck.N = 10;
    elseif Parameters.Deck.fc>=2900 && Parameters.Deck.fc<3600
        Parameters.Deck.N = 9;
    elseif Parameters.Deck.fc>=3600 && Parameters.Deck.fc<4600
        Parameters.Deck.N = 8;
    elseif Parameters.Deck.fc>=4600 && Parameters.Deck.fc<6000
        Parameters.Deck.N = 7;
    else
        Parameters.Deck.N = 6;
    end
else
    Parameters.Design.Code = 'NA';
end

%% Get Member Actions With Unit Loading
Parameters = GetMemberActions(Parameters);

%% Get Truck Loads
Parameters.Design = GetTruckLoads(Parameters.Design);

%% Get Deflection Requirement
Parameters = GetAASHTOLLDeflectionRequirement(Parameters);
end % CoverPlateDesign()