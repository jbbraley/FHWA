function Parameters = AASHTOLoadRating(Parameters)
if strcmp(Parameters.Rating.Code, 'ASD')
    % Check for variable
    if ~isfield(Parameters.Design,'Im')
        Parameters.Design.Im = 50./(Parameters.Length/12+125);
        if Parameters.Design.Im > 0.3
            Parameters.Design.Im = 0.3;
        end
    end

elseif strcmp(Parameters.Rating.Code, 'LRFD')
    % Check for variable
    if ~isfield(Parameters.Design, 'IMF')
        Parameters.Rating.IMF = 1.33;
    else
        Parameters.Rating.IMF = Parameters.Design.IMF;
    end
    
    
    %Multipresence factors - To be used only with Lever Rule
    Parameters.Rating.MultiPres = 1; % 
        Parameters.Rating.MulPres(1) = 1.2;
        Parameters.Rating.MulPres(2) = 1;
        Parameters.Rating.MulPres(3) = 0.85;
        Parameters.Rating.MulPres(4) = 0.65;
    
    % Lanes LRFD 2011 6A.2.3.2 
    if Parameters.RoadWidth >= 18*12 && Parameters.RoadWidth <= 24*12
        Parameters.Rating.NumLane = 2;
        Parameters.Rating.LaneWidth = Parameters.RoadWidth/2;
    elseif Parameters.RoadWidth > 24*12
        Parameters.Rating.NumLane = floor(Parameters.RoadWidth/144);
        Parameters.Rating.LaneWidth = 12*12;
    else
        Parameters.Rating.NumLane = 1;
        Parameters.Rating.LaneWidth = min([12*12 Parameters.RoadWidth]);
    end
    
    % SHoulder
    Parameters.Rating.Shldr = (Parameters.RoadWidth - Parameters.Rating.NumLane*Parameters.Rating.LaneWidth)/2;
    
    % Offset to move truck to within 2' of lane edge
    Parameters.Rating.LaneOffset = (Parameters.Rating.LaneWidth-6*12)/2-24;
end
end