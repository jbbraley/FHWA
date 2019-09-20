function Parameters = GetStructureConfig(NBI, Parameters, Version, Options, j)
if ~isempty(Version)
     Parameters.Length = Version.LengthOp(j,:)';    
    
%     Parameters.Skewness = Version.SkewnessOp(j);    
    Parameters.SkewNear = Version.SkewOp(j);
    Parameters.SkewFar = Version.SkewOp(j);
    
    Parameters.Design.CoverPlateLength = Version.CoverPlateLengthOp(j);    
    
    Parameters.Deck.t = Version.DeckThickOp(j);
    Parameters.Deck.CompositeDesign = Version.DeckCompositeOp(j);
    Parameters.Deck.fc = Version.ConcreteStrengthOp(j);
    
    Parameters.Barrier.Width = Version.BarrierWidthOp(j);
    Parameters.Barrier.Height = Version.BarrierHeightOp(j);
    Parameters.Barrier.CompositeDesign = Version.BarrierCompositeOp(j);
    
    Parameters.Sidewalk.Height = Version.SidewalkHeightOp(j);
    Parameters.Sidewalk.Right = Version.RightSidewalkWidthOp(j);
    Parameters.Sidewalk.Left = Version.LeftSidewalkWidthOp(j);
    Parameters.Sidewalk.CompositeDesign = Version.SidewalkCompositeOp(j);
    
    Dia.Config = Version.DiaphragmConfigOp(j);
    
    Parameters.GirderSpacing = Version.GirderSpacingOp(j);
    Parameters.Width = Version.TotalWidthOp(j);
%     Parameters.NumGirder = Version.NumGirdersOp(j);
    
    Parameters.Design.DesignLoad = char(Version.DesignLoadOp(j));
    Parameters.Design.MaxSpantoDepth = Version.BeamDepthOp(j);   
    
    %% Calculate or set other Parameters
    Parameters.Spans = length(Parameters.Length);

    % Diaphragm Configuration
    if max(Parameters.SkewFar, Parameters.SkewNear)>=20
        switch Dia.Config
            case 1
                Parameters.Dia.Config = 'Normal';
            otherwise
                Parameters.Dia.Config = 'Staggered';
        end
    else
        Parameters.Dia.Config = 'Parallel';
    end
    % Calculate Out to Out Width
%     Parameters.Width = Parameters.NumGirder*Parameters.GirderSpacing;
    Parameters.RoadWidth = Parameters.Width - (Parameters.Sidewalk.Left + Parameters.Sidewalk.Right+2*Parameters.Barrier.Width);
    Parameters.NumGirder = floor(Parameters.Width/Parameters.GirderSpacing);
    % Skew (must be equal squew)
%     Skew = atan(Parameters.Skewness*Parameters.Length/Parameters.Width)*180/pi;
%     Parameters.SkewNear = Parameters.Skew;
%     Parameters.SkewFar = Parameters.Skew;
    
    % Number of diaphragms
    Parameters.NumDia = ceil(Parameters.Length/300)-1;

    Parameters.Dia.Spacing = Parameters.Length/(Parameters.NumDia+1);
    Parameters.Dia.Assign = 'Auto';
    
    % Set Design Code
    if any(strcmp(Parameters.Design.DesignLoad, [{'A'} {'B'} {'C'}]))
        Parameters.Design.Code = 'LRFD';
    else
        Parameters.Design.Code = 'ASD';
    end
    
elseif ~isfield(Parameters, 'Design')
    Parameters.Design.CoverPlate.Length = Options.Default.CoverPlateLength;
    Parameters.Design.GirderSpacing = Options.Default.GirderSpacing;
    Parameters.Design.Composite = Options.Default.Composite;
    Parameters.Design.Spans = Options.Default.Spans;
end    

%% Transfer Data from NBI
if strcmp(Parameters.Geo, 'NBI')   
    % Put NBI Data in Parameters
    Parameters.NBI = NBI;
    
    % Place NBI fields for geometry in Parameters
    if rem(NBI.TotalLength, NBI.MaxSpanLength) == 0 % all spans are equal length
        Parameters.Length = ones(NBI.NumSpans,1)*round(NBI.MaxSpanLength);
    else
        midspan = round(NBI.NumSpans/2);
        Parameters.Length(midspan) = round(NBI.MaxSpanLength);
        I = 1:NBI.NumSpans;
        Parameters.Length(I(I~=midspan)) = round((NBI.TotalLength - NBI.MaxSpanLength)/NBI.NumSpans);
    end
    
    Parameters.Spans = NBI.NumSpans;
    
    Parameters.Sidewalk.Left = NBI.Sidewalk.Left;
    Parameters.Sidewalk.Right = NBI.Sidewalk.Right;
    Parameters.RoadWidth = NBI.RoadWidth;
    Parameters.Width = NBI.Width;
    
    % Skew
    Parameters.SkewNear = NBI.Skew;
    Parameters.SkewFar = NBI.Skew;

    % Check for total width agreement
    if Parameters.Width < (Parameters.RoadWidth + Parameters.Sidewalk.Left + Parameters.Sidewalk.Right)
        Parameters.Width = (Parameters.RoadWidth + Parameters.Sidewalk.Left + Parameters.Sidewalk.Right);
        Parameters.NBI.WidthAgreement = 0;
    end
    
    % Number of Girders
    Parameters.NumGirder = round(Parameters.Width/Parameters.Design.GirderSpacing);
    
    % Widths of bridge
    Parameters.GirderSpacing = round(Parameters.Width/Parameters.NumGirder);
    Parameters.TotalWidth = Parameters.GirderSpacing*(Parameters.NumGirder-1);
    Parameters.Overhang = Parameters.GirderSpacing/2;
    
    % Overhang, barriers, curb
    Parameters.Barrier.Width = Options.Geo.Barrier.Width ; % barrier width and height to get 2.6 ft^2 of area or 400 pound sper linear foot
    Parameters.Barrier.Height = Options.Geo.Barrier.Height;
    Parameters.Sidewalk.Height = Options.Geo.Sidewalk.Height;
    
    % Add to road width to make all widths add up
    Parameters.RoadWidth = Parameters.Width - (Parameters.Sidewalk.Left + Parameters.Sidewalk.Right + Parameters.Barrier.Width*2);
    Parameters.LengthOption = 'Girder';
    
    Parameters.Beam.CoverPlate.Length = 0;
    
    % Number of diaphragms
    Parameters.NumDia = ceil(Parameters.Length/300)-1;
    
    if Parameters.SkewNear < 20
        Parameters.Dia.Config = 'Parallel';
    else
        Parameters.Dia.Config = 'Normal';
    end
    Parameters.Dia.Spacing = Parameters.Length/(Parameters.NumDia+1);
    Parameters.Dia.Assign = 'Auto';
    
     % Composite Design?
     Parameters.Deck.CompositeDesign = Parameters.Design.Composite;
    
    % Deck
    if ~isempty(Version)
        Parameters.Deck.t = Version.DeckThick;
    else
        Parameters.Deck.t = Options.Geo.DeckThick;
    end

     % Materials
    Parameters.Beam.E = 29000000;
    
    Parameters.Dia.E = 29000000;    
    
    Parameters.Sidewalk.density = 150/(12^3); %pci
    Parameters.Deck.density = 150/(12^3); %pci
    Parameters.Barrier.density = 150/(12^3); %pci
    
    % Materials Yield Strength
    % Steel
    if Parameters.NBI.YearBuilt < 1905
        Parameters.Beam.Fy = 26000;
    elseif Parameters.NBI.YearBuilt >= 1905 && Parameters.NBI.YearBuilt <= 1936
        Parameters.Beam.Fy = 30000;
    elseif Parameters.NBI.YearBuilt > 1936 && Parameters.NBI.YearBuilt < 1963
        Parameters.Beam.Fy = 33000;
    else
        Parameters.Beam.Fy = 36000;
    end
    
     % Concrete
    if Parameters.NBI.YearBuilt < 1959
        Parameters.Deck.fc = 2500;
    elseif Parameters.NBI.YearBuilt >= 1959
        Parameters.Deck.fc = 3000;
    end
    
    Parameters.Deck.E = 57000*sqrt(Parameters.Deck.fc);
    Parameters.Sidewalk.E = 57000*sqrt(Parameters.Sidewalk.fc);
    Parameters.Barrier.E = 57000*sqrt(Parameters.Barrier.fc);
    
    Parameters.Design.Code = Parameters.NBI.DesignCode;
    Parameters.Design.DesignLoad = Parameters.NBI.DesignLoad;
else     
    if isfield(Parameters, 'GirderSpacing')
        Parameters.TotalWidth = Parameters.GirderSpacing*(Parameters.NumGirder-1);
        Parameters.Width = Parameters.RoadWidth + Parameters.Sidewalk.Left + Parameters.Sidewalk.Right + 2*Parameters.Barrier.Width;
        Parameters.Overhang = (Parameters.Width - Parameters.TotalWidth)/2;
        Parameters.LengthOption = 'Girder';
    end
    
    % Dia spacing
    if isempty(Parameters.NumDia)
        Parameters.NumDia = ones(Parameters.Spans, 1);
    end
    Parameters.Dia.Spacing = Parameters.Length./(max(Parameters.NumDia)+1);
    
    % Materials
    if strcmp(Parameters.structureType,'Steel')
        
        Parameters.Beam.E = 29000000;
        Parameters.Dia.E = 29000000;
    elseif strcmp(Parameters.structureType,'Prestressed')
        Parameters.Beam.E = 57000*sqrt(Parameters.Beam.fc);
        Parameters.Beam.fci = 0.8*Parameters.Beam.fc;
        Parameters.Beam.Eci = 57000*sqrt(Parameters.Beam.fci);
        Parameters.Beam.density = 150/(12^3); %pci
        Parameters.Dia.E = 57000*sqrt(Parameters.Dia.fc);
        
        Parameters.Beam.PSSteel.Fy = 0.9*Parameters.Beam.PSSteel.Fu;
        Parameters.Beam.PSSteel.E = 28500000;
        
        Parameters.Beam.RFSteel.Fy = 60000;
    end
    
    Parameters.Sidewalk.density = 150/(12^3); %pci
    Parameters.Deck.density = 150/(12^3); %pci
    Parameters.Barrier.density = 150/(12^3); %pci
    if strcmp(Parameters.Dia.Type,'Concrete')
        Parameters.Dia.density = 150/(12^3);
    else
        Parameters.Dia.density = 0.284321769236;
    end
    
    Parameters.Deck.E = 57000*sqrt(Parameters.Deck.fc);
    Parameters.Sidewalk.E = 57000*sqrt(Parameters.Sidewalk.fc);
    Parameters.Barrier.E = 57000*sqrt(Parameters.Barrier.fc);
end
end % GetDesign()