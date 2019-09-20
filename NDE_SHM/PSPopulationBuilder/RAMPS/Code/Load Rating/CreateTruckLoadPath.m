function LoadCase = CreateTruckLoadPath(uID, Parameters, Options, Node, ArgIn, LoadCase)
%% Get Deck Boundary Dimensions
% Find ID #s of corners of deck for each span
for ii=1:Parameters.Spans
    y = find(~any(Node(ii).ID(:,:,6),1),1,'first')-1;
    if y == 0 
        y = 1;
    end

    x = find(Node(ii).ID(:,y,1),1,'first');
    Corner(1,1) = Node(ii).ID (x,y,1);
    x = find(Node(ii).ID(:,y,1),1,'last');
    Corner(2,1) = Node(ii).ID (x,y,1);
    
    y = find(~any(Node(ii).ID (:,:,6),1),1,'last')+1;
    if y > size(Node(ii).ID, 2) 
        y = y - 1;
    end

    x = find(Node(ii).ID (:,y,1),1,'first');
    Corner(1,2) = Node(ii).ID (x,y,1);
    x = find(Node(ii).ID (:,y,1),1,'last');
    Corner(2,2) = Node(ii).ID (x,y,1);
    
    if ii==1
        NodeCoord(2*ii-1,:) = [Node(ii).x(Corner(1,1)), Node(ii).y(Corner(1,1))];
        NodeCoord(2*ii,:) = [Node(ii).x(Corner(1,2)), Node(ii).y(Corner(1,2))];
    end
    NodeCoord(2*ii+1,:) = [Node(ii).x(Node(ii).Num==Corner(2,1)), Node(ii).y(Node(ii).Num==Corner(2,1))];
    NodeCoord(2*(ii+1),:) = [Node(ii).x(Node(ii).Num==Corner(2,2)), Node(ii).y(Node(ii).Num==Corner(2,2))];
    
end

%% Get CenterLine Y-coord of Deck
Centerline = (NodeCoord(2,2) - NodeCoord(1,2))/2 + NodeCoord(1,2);

%% Get Lane parameters
NumLane = ArgIn.NumLane;
LaneWidth = ArgIn.LaneWidth;
Shldr = ArgIn.Shldr;
NumCrawlSteps = Options.LoadPath.CrawlSteps;
NumLaneOffsets = Options.LoadPath.Divisions;

% Offset to move truck to within 2' of lane edge
laneoffset = ArgIn.LaneOffset;

%% Find Lane Boundaries and establish wheel lines
if NumLaneOffsets == 1
    for ii=1:NumLane
        % Centerline y-coord of lane
        Lane(ii,1) = Centerline - ((NumLane - 1)/2 * (LaneWidth)) + (ii-1)*(LaneWidth);
        
        % Wheel lines of lane
        Lane(ii,2) = Lane(ii,1) + (3*12);
        Lane(ii,3) = Lane(ii,1) - (3*12);
    end
elseif NumLaneOffsets == 3
    % Three global lane positions
    for jj=1:NumLaneOffsets
        for ii=1:NumLane
            %1: shifted to far shoulder
            if jj == 1
                offset = Shldr+laneoffset;
                %2: shifted to near shoulder
            elseif jj == 2
                offset = -Shldr-laneoffset;
                %3: Shifted toward center
            else
                if ii<(NumLane+1)/2
                    offset = laneoffset;
                elseif ii == (NumLane+1)/2
                    offset = 0;
                else
                    offset = -laneoffset;
                end
            end
            
            % Centerline y-coord of lane
            Lane(ii,1,jj) = Centerline + offset - ((NumLane - 1)/2 * (LaneWidth)) + (ii-1)*(LaneWidth);
            
            % Wheel lines of lane
            Lane(ii,2,jj) = Lane(ii,1,jj) + (3*12);
            Lane(ii,3,jj) = Lane(ii,1,jj) - (3*12);
        end
    end
end  
%% Get Left Midspan Coords of Deck
HalfSpans = zeros(2*Parameters.Spans+1,1);
HalfSpans(2:2:end-1) = (NodeCoord(3:2:end-1,1)-NodeCoord(1:2:end-2,1))/2+NodeCoord(1:2:end-3,1);
HalfSpans(1:2:end) = NodeCoord(1:2:end,1);

%% Establish truck centroids and placement 
% Distance from central axle with + being towards front axle
% Centroid(1) for 1 truck with S(1) axle spacing. 
% Centroid(2) for 1 truck with S(3) axle spacing.
% Centroid(3) for tandem
% Centroid(4) for offset of 1st truck in dual truck config
% Centroid(5) for offset of 2st truck in dual truck config

% 1 truck with closest (S(1)) axle spacing
Centroid(1) = (ArgIn.Load.FS*ArgIn.Load.A(1) - ArgIn.Load.S(1)*ArgIn.Load.A(3))/(ArgIn.Load.A(2)+ArgIn.Load.A(3)+ArgIn.Load.A(1));
% 1 truck with greatest (S(3)) axle spacing
Centroid(2) = (ArgIn.Load.FS*ArgIn.Load.A(1) - ArgIn.Load.S(3)*ArgIn.Load.A(3))/(ArgIn.Load.A(2)+ArgIn.Load.A(3)+ArgIn.Load.A(1));
% 1 Tandem Truck
Centroid(3) = -ArgIn.Load.TS/2;
% Distance between Dual Trucks for Negative moment (min 50' apart)
TruckDist = max(0.8*mean(Parameters.Length)-sum(ArgIn.Load.S(1),ArgIn.Load.FS), 50*12); % Ideally set at .4 away from support
% Offset of 1st truck in dual truck config
Centroid(4) = ((sum(ArgIn.Load.S(1),ArgIn.Load.FS)+TruckDist+Centroid(1))*sum(ArgIn.Load.A)+Centroid(1)*sum(ArgIn.Load.A))/(2*sum(ArgIn.Load.A));
% offset of 2nd truck in dual truck config
Centroid(5) = Centroid(4)-(sum(ArgIn.Load.S(1),ArgIn.Load.FS)+TruckDist);

Truck.Spacing(1,:) = [ArgIn.Load.S(1) ArgIn.Load.FS];
Truck.Spacing(2,:) = [ArgIn.Load.S(3) ArgIn.Load.FS];
Truck.Spacing(3,:) = [ArgIn.Load.TS 0];
Truck.Spacing(4,:) = Truck.Spacing(1,:);
Truck.Spacing(5,:) = Truck.Spacing(4,:);

% Specify which trucks will be placed (Span, Abutment, Pier)
Span.Trucks = 1;
if NumCrawlSteps == 1
    Span.Step = Centroid(1)/2;
else
    Span.Step = Centroid(1)/(NumCrawlSteps-1);
end

Abut.Trucks = 1;
Pier.Trucks = [1 2];
if isfield(ArgIn.Load,'TS') && ArgIn.Load.TS ~=0
    Span.Trucks = [Span.Trucks 3];
    Span.Step = [Span.Step Centroid(3)];
    Abut.Trucks = [Abut.Trucks 3];
    Pier.Trucks = [Pier.Trucks 3];
end
if strcmp(Parameters.Rating.Code, 'LRFD')
    Pier.Trucks = [Pier.Trucks 4 5];
end

%% Find Wheel Load Positions
% Design Load
for kk = 1:NumLaneOffsets % Lane positions
    for ii = 1:NumLane
        truckMidAxle(:,ii) = HalfSpans + tan(Parameters.SkewNear*pi/180)*(Lane(ii,1,kk) - NodeCoord(1,2));

        for jj= 1:Parameters.Spans
            n=1;
            for pp = 1:length(Span.Trucks) % Place both Design truck & Tandem if applicable
                for ss = 1:NumCrawlSteps
                    % Compute distance of current location from center span
                    if NumCrawlSteps == 1
                        offset = Span.Step(pp);
                    else
                        offset = (ss-1)*Span.Step(pp);
                    end    
                    if length(Node)~=1 
                    % Offset trucks to 0.4 or 0.6 of span length as appropriate
                        if jj == 1
                            offset = -0.1*Parameters.Length(jj)+offset;
                        elseif jj==Parameters.Spans
                            offset = 0.1*Parameters.Length(jj)+offset;
                        end
                    end

                    % Wheel load positions at midspans
                    WheelLine(jj,ii,kk).L(3,:,n) = [truckMidAxle(2*jj,ii) + offset - Centroid(Span.Trucks(pp)) - Truck.Spacing(Span.Trucks(pp),1), Lane(ii,3,kk)];
                    WheelLine(jj,ii,kk).L(2,:,n) = [truckMidAxle(2*jj,ii) + offset - Centroid(Span.Trucks(pp)), Lane(ii,3,kk)];

                    WheelLine(jj,ii,kk).R(3,:,n) = [truckMidAxle(2*jj,ii) + offset - Centroid(Span.Trucks(pp)) - Truck.Spacing(Span.Trucks(pp),1), Lane(ii,2,kk)];
                    WheelLine(jj,ii,kk).R(2,:,n) = [truckMidAxle(2*jj,ii) + offset - Centroid(Span.Trucks(pp)), Lane(ii,2,kk)];

                    if Truck.Spacing(Span.Trucks(pp),2)~=0
                        WheelLine(jj,ii,kk).L(1,:,n) = [truckMidAxle(2*jj,ii) + offset - Centroid(Span.Trucks(pp)) + Truck.Spacing(Span.Trucks(pp),2), Lane(ii,3,kk)];
                        WheelLine(jj,ii,kk).R(1,:,n) = [truckMidAxle(2*jj,ii) + offset - Centroid(Span.Trucks(pp)) + Truck.Spacing(Span.Trucks(pp),2), Lane(ii,2,kk)];
                    else
                        WheelLine(jj,ii,kk).L(1,:,n) = -99;
                        WheelLine(jj,ii,kk).R(1,:,n) = -99;
                    end
                    n=n+1;
                end
            end

            if jj~=Parameters.Spans
            % Wheel load positions over interior supports for
            % shear and neg. moment as well as positioning of
            % double trucks (combined centroid over interior
            % supports
                for pp=1:length(Pier.Trucks)
                    if Pier.Trucks(pp)==1
                        offset = Centroid(Pier.Trucks(pp)) + Truck.Spacing(Pier.Trucks(pp),1);
                    else
                        offset = 0;
                    end
                    WheelLine(jj,ii,kk).L(3,:,n) = [truckMidAxle(2*jj+1,ii) - Centroid(Pier.Trucks(pp)) - Truck.Spacing(Pier.Trucks(pp),1) + offset, Lane(ii,3,kk)];
                    WheelLine(jj,ii,kk).L(2,:,n) = [truckMidAxle(2*jj+1,ii) - Centroid(Pier.Trucks(pp)) + offset, Lane(ii,3,kk)];

                    WheelLine(jj,ii,kk).R(3,:,n) = [truckMidAxle(2*jj+1,ii) - Centroid(Pier.Trucks(pp)) - Truck.Spacing(Pier.Trucks(pp),1) + offset, Lane(ii,2,kk)];
                    WheelLine(jj,ii,kk).R(2,:,n) = [truckMidAxle(2*jj+1,ii) - Centroid(Pier.Trucks(pp)) + offset, Lane(ii,2,kk)];

                    if Truck.Spacing(Pier.Trucks(pp),2)~=0
                        WheelLine(jj,ii,kk).L(1,:,n) = [truckMidAxle(2*jj+1,ii) - Centroid(Pier.Trucks(pp)) + Truck.Spacing(Pier.Trucks(pp),2) + offset, Lane(ii,3,kk)];
                        WheelLine(jj,ii,kk).R(1,:,n) = [truckMidAxle(2*jj+1,ii) - Centroid(Pier.Trucks(pp)) + Truck.Spacing(Pier.Trucks(pp),2) + offset, Lane(ii,2,kk)];
                    else
                        WheelLine(jj,ii,kk).L(1,:,n) = -99;
                        WheelLine(jj,ii,kk).R(1,:,n) = -99;
                    end
                    
                    %Report index of 1st double truck
                    if Pier.Trucks(pp) == 4
                        TruckDblind = n;
                    end
                    n=n+1;
                end
            end
            
        end

        %Wheel load positions at abutments - only for shear
        if Options.LoadRating.ShearRating
            truckBackAxle(1) = NodeCoord(1,1) + max(tan(Parameters.SkewNear*pi/180)*(Lane(ii,2:3,kk) - NodeCoord(1,2)));
            truckBackAxle(2) = NodeCoord(end-1,1) + min(tan(Parameters.SkewNear*pi/180)*(Lane(ii,2:3,kk) - NodeCoord(1,2)));
            jj=Parameters.Spans+1;
            n=1;
            for pp = 1:length(Abut.Trucks)
                for ss=1:2
                    WheelLine(jj,ii,kk).L(3,:,n) = [truckBackAxle(ss), Lane(ii,3,kk)];
                    WheelLine(jj,ii,kk).L(2,:,n) = [truckBackAxle(ss)+(-1)^(ss+1)*Truck.Spacing(Abut.Trucks(pp),1), Lane(ii,3,kk)];
                    
                    WheelLine(jj,ii,kk).R(3,:,n) = [truckBackAxle(ss), Lane(ii,2,kk)];
                    WheelLine(jj,ii,kk).R(2,:,n) = [truckBackAxle(ss)+(-1)^(ss+1)*Truck.Spacing(Abut.Trucks(pp),1), Lane(ii,2,kk)];
                    
                    if Truck.Spacing(Abut.Trucks(pp),2)~=0
                        WheelLine(jj,ii,kk).L(1,:,n) = [truckBackAxle(ss)+(-1)^(ss+1)*sum(Truck.Spacing(Abut.Trucks(pp),:),2), Lane(ii,3,kk)];
                        WheelLine(jj,ii,kk).R(1,:,n) = [truckBackAxle(ss)+(-1)^(ss+1)*sum(Truck.Spacing(Abut.Trucks(pp),:),2), Lane(ii,2,kk)];
                    else
                        WheelLine(jj,ii,kk).L(1,:,n) = -99;
                        WheelLine(jj,ii,kk).R(1,:,n) = -99;
                    end
                    n=n+1;
                end
            end
        end

        %% Find Lane Boundary Coordinates for lane load application
        LaneBound(ii,kk).L = [truckMidAxle(1:2:end,ii)+tan(Parameters.SkewNear*pi/180)*(-60),(Lane(ii,1,kk)-60)*ones(length(Node)+1,1)];
        LaneBound(ii,kk).R = [truckMidAxle(1:2:end,ii)+tan(Parameters.SkewNear*pi/180)*(60),(Lane(ii,1,kk)+60)*ones(length(Node)+1,1)];

    end
end

if ~exist('TruckDblind','var')
    TruckDblind = -99;
end
LoadCase = ApplyWheelLoads(uID, ArgIn, LoadCase, WheelLine, TruckDblind);
if strcmp(Parameters.Rating.Code, 'LRFD')
    LoadCase = ApplyLaneLoads(uID, Parameters, ArgIn, LoadCase, LaneBound, Node);
end

            
end %CreateTruckLoadPath()




