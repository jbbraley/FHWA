function LoadCase = CreateTruckLoadPath(uID, Parameters, Options, Node, LoadCase)
%% Get Deck Boundary Dimensions
% Find ID #s of corners of deck for each span
for ii=1:length(Node)
    y = find(~any(Node(ii).ID(:,:,6),1),1,'first')-1;
    if y == 0 && any(Node(ii).ID(:,1,5))
        y = y + 1;
    end

    x = find(Node(ii).ID (:,y,1),1,'first');
    Corner(1,1) = Node(ii).ID (x,y,1);
    x = find(Node(ii).ID (:,y,1),1,'last');
    Corner(2,1) = Node(ii).ID (x,y,1);
    
    y = find(~any(Node(ii).ID (:,:,6),1),1,'last')+1;
    if y > size(Node(ii).ID ,2) && any(Node(ii).ID (:,end,5))
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
    NodeCoord(2*ii+1,:) = [Node(ii).x(find(Node(ii).Num==Corner(2,1))), Node(ii).y(find(Node(ii).Num==Corner(2,1)))];
    NodeCoord(2*(ii+1),:) = [Node(ii).x(find(Node(ii).Num==Corner(2,2))), Node(ii).y(find(Node(ii).Num==Corner(2,2)))];
    
end

%% Get CenterLine Y-coord of Deck
Centerline = (NodeCoord(2,2) - NodeCoord(1,2))/2 + NodeCoord(1,2);

%% Get Lane width
NumLane = Parameters.Rating.NumLane;

LaneWidth = Parameters.Rating.LaneWidth; %(NodeCoord(2,2)-NodeCoord(1,2))/NumLane;
Shldr = Parameters.Rating.Shldr;

% Offset to move truck to within 2' of lane edge
laneoffset = Parameters.Rating.LaneOffset;


for jj=1:3
   
%% Find Lane Boundaries
for i=1:NumLane
    % Offset case: shifted all left, shifted all right, shifted toward center
    if jj == 1
        offset = Shldr+laneoffset;
    elseif jj == 2
        offset = -Shldr-laneoffset;
    else
        if i<(NumLane+1)/2
            offset = laneoffset;
        elseif i == (NumLane+1)/2
            offset = 0;
        else
            offset = -laneoffset;
        end
    end
    
    % 
    
    % Centerline y-coord of lane
    Lane(i,1,jj) = Centerline + offset - ((NumLane - 1)/2 * (LaneWidth)) + (i-1)*(LaneWidth);
    
    % Wheel lines of lane
    Lane(i,2,jj) = Lane(i,1,jj) + (3*12);
    Lane(i,3,jj) = Lane(i,1,jj) - (3*12);
end
end

  
%% Get Left Midspan Coords of Deck
HalfSpans = zeros(2*Parameters.Spans+1,1);
HalfSpans(2:2:end-1) = (NodeCoord(3:2:end-1,1)-NodeCoord(1:2:end-2,1))/2+NodeCoord(1:2:end-3,1);
HalfSpans(1:2:end) = NodeCoord(1:2:end,1);
% 
% if all(Parameters.Length >= 45.7632*12)   % Use Design Truck
%     RatingLoad.A(1) = 8000;
%     RatingLoad.A(2) = 32000;
%     RatingLoad.A(3) = 32000;
% 
%     RatingLoad.FS = 168;
%     RatingLoad.S(1) = 168;
%     RatingLoad.S(3) = 360; % Alternate rear axle spacing of 30ft.
% else  % Use Alt. Military Loading
%     if strcmp(Parameters.Design.Code, 'ASD')
%         RatingLoad.A(1) = 0;
%         RatingLoad.A(2) = 24000;
%         RatingLoad.A(3) = 24000;
% 
%         RatingLoad.FS = 0;
%         RatingLoad.S(1) = 48;
%         RatingLoad.S(3) = 0;
%     elseif strcmp(Parameters.Design.Code,'LRFD')
%         RatingLoad.A(1) = 0;
%         RatingLoad.A(2) = 25000;
%         RatingLoad.A(3) = 25000;
% 
%         RatingLoad.FS = 0;
%         RatingLoad.S(1) = 48;
%         RatingLoad.S(3) = 0;
%     end
% end

%% Distance from central axle
% Centroid(1) for 1 truck with S(1) axle spacing. Centroid(2) for 1
% truck with S(3) axle spacing. Centroid(3) for 1st truck for 2 trucks with S(1)
% axle spacing and minimum of 50ft. apart. Centroid(4) for 2nd truck.
Centroid(1) = (Parameters.Rating.Load.FS*Parameters.Rating.Load.A(1) - Parameters.Rating.Load.S(1)*Parameters.Rating.Load.A(3))/(Parameters.Rating.Load.A(2)+Parameters.Rating.Load.A(3)+Parameters.Rating.Load.A(1));
if Parameters.Rating.Load.S(3)~=0
    Centroid(2) = (Parameters.Rating.Load.FS*Parameters.Rating.Load.A(1) - Parameters.Rating.Load.S(3)*Parameters.Rating.Load.A(3))/(Parameters.Rating.Load.A(2)+Parameters.Rating.Load.A(3)+Parameters.Rating.Load.A(1));

    if strcmp(Parameters.Rating.Code, 'LRFD') %&& all(Parameters.Length >= 680)
        TruckDist = max(0.8*mean(Parameters.Length)-sum(Parameters.Rating.Load.S(1:2)), 50*12); % Ideally set at .4 away from support
    Centroid(3) = ((sum(Parameters.Rating.Load.S(1:2))+TruckDist+Centroid(1))*sum(Parameters.Rating.Load.A)+Centroid(1)*sum(Parameters.Rating.Load.A))/(2*sum(Parameters.Rating.Load.A));
    Centroid(4) = Centroid(3)-(sum(Parameters.Rating.Load.S(1:2))+TruckDist);
    end
end
%% Find Wheel Load Positions
% Design Load
for kk = 1:3
    for i = 1:NumLane
        m=1;
        truckMidAxle(:,i) = HalfSpans + tan(Parameters.SkewNear*pi/180)*(Lane(i,1,kk) - NodeCoord(1,2));


        for jj= 1:length(Node)

            % Offset trucks to 0.4 or 0.6 of span length as appropriate
            if length(Node)~=1 
                if jj == 1
                    offset = -0.1*Parameters.Length(jj);
                elseif jj==length(Node)
                    offset = 0.1*Parameters.Length(jj);
                else
                    offset = 0;
                end
            else
                offset = 0;
            end

            % Wheel load positions at midspans
            WheelLine(1,i,kk).L(3,:,jj) = [truckMidAxle(2*jj,i) + offset - Centroid(1) - Parameters.Rating.Load.S(1), Lane(i,3,kk)];
            WheelLine(1,i,kk).L(2,:,jj) = [truckMidAxle(2*jj,i) + offset - Centroid(1), Lane(i,3,kk)];

            WheelLine(1,i,kk).R(3,:,jj) = [truckMidAxle(2*jj,i) + offset - Centroid(1) - Parameters.Rating.Load.S(1), Lane(i,2,kk)];
            WheelLine(1,i,kk).R(2,:,jj) = [truckMidAxle(2*jj,i) + offset - Centroid(1), Lane(i,2,kk)];

            if Parameters.Rating.Load.FS~=0
                WheelLine(1,i,kk).L(1,:,jj) = [truckMidAxle(2*jj,i) + offset - Centroid(1) + Parameters.Rating.Load.FS, Lane(i,3,kk)];
                WheelLine(1,i,kk).R(1,:,jj) = [truckMidAxle(2*jj,i) + offset - Centroid(1) + Parameters.Rating.Load.FS, Lane(i,2,kk)];
            else
                WheelLine(1,i,kk).L(1,:,jj) = 0;
                WheelLine(1,i,kk).R(1,:,jj) = 0;
            end

            if jj~=length(Node)
            % Wheel load posiitions over interior supports for
            % shear and neg. moment as well as positioning of
            % double trucks (combined centroid over interior
            % supports
                for k=1:length(Centroid)
                    if k==2
                        RearAxleSp = Parameters.Rating.Load.S(3);
                    else
                        RearAxleSp = Parameters.Rating.Load.S(1);
                    end
                    WheelLine(k+1,i,kk).L(3,:,m) = [truckMidAxle(2*jj+1,i) - Centroid(k) - RearAxleSp, Lane(i,3,kk)];
                    WheelLine(k+1,i,kk).L(2,:,m) = [truckMidAxle(2*jj+1,i) - Centroid(k), Lane(i,3,kk)];

                    WheelLine(k+1,i,kk).R(3,:,m) = [truckMidAxle(2*jj+1,i) - Centroid(k) - RearAxleSp, Lane(i,2,kk)];
                    WheelLine(k+1,i,kk).R(2,:,m) = [truckMidAxle(2*jj+1,i) - Centroid(k), Lane(i,2,kk)];

                    if Parameters.Rating.Load.FS~=0
                        WheelLine(k+1,i,kk).L(1,:,m) = [truckMidAxle(2*jj+1,i) - Centroid(k) + Parameters.Rating.Load.FS, Lane(i,3,kk)];
                        WheelLine(k+1,i,kk).R(1,:,m) = [truckMidAxle(2*jj+1,i) - Centroid(k) + Parameters.Rating.Load.FS, Lane(i,2,kk)];
                    else
                        WheelLine(k+1,i,kk).L(1,:,m) = 0;
                        WheelLine(k+1,i,kk).R(1,:,m) = 0;
                    end
                end
                m=m+1;
            end
        end

        %Wheel load positions at abutments
        truckBackAxle(1) = NodeCoord(1,1) + max(tan(Parameters.SkewNear*pi/180)*(Lane(i,2:3,kk) - NodeCoord(1,2)));
        truckBackAxle(2) = NodeCoord(end-1,1) + min(tan(Parameters.SkewNear*pi/180)*(Lane(i,2:3,kk) - NodeCoord(1,2)));
        if length(Node)~=1
            Position = length(Centroid)+1;
        else
            Position = 1;
        end
        for p=1:2
            WheelLine(Position+p,i,kk).L(3,:) = [truckBackAxle(p), Lane(i,3,kk)];
            WheelLine(Position+p,i,kk).L(2,:) = [truckBackAxle(p)+(-1)^(p+1)*(Parameters.Rating.Load.S(1)), Lane(i,3,kk)];

            WheelLine(Position+p,i,kk).R(3,:) = [truckBackAxle(p), Lane(i,2,kk)];
            WheelLine(Position+p,i,kk).R(2,:) = [truckBackAxle(p)+(-1)^(p+1)*(Parameters.Rating.Load.S(1)), Lane(i,2,kk)];

            if Parameters.Rating.Load.FS~=0
                WheelLine(Position+p,i,kk).L(1,:) = [truckBackAxle(p)+(-1)^(p+1)*(Parameters.Rating.Load.S(1)+Parameters.Rating.Load.FS), Lane(i,3,kk)];
                WheelLine(Position+p,i,kk).R(1,:) = [truckBackAxle(p)+(-1)^(p+1)*(Parameters.Rating.Load.S(1)+Parameters.Rating.Load.FS), Lane(i,2,kk)];
            else
                WheelLine(Position+p,i,kk).L(1,:) = 0;
                WheelLine(Position+p,i,kk).R(1,:) = 0;
            end
        end

        %% Find Lane Boundary Coordinates for lane load application
        LaneBound(i,kk).L = [truckMidAxle(1:2:end,i)+tan(Parameters.SkewNear*pi/180)*(-60),(Lane(i,1,kk)-60)*ones(length(Node)+1,1)];
        LaneBound(i,kk).R = [truckMidAxle(1:2:end,i)+tan(Parameters.SkewNear*pi/180)*(60),(Lane(i,1,kk)+60)*ones(length(Node)+1,1)];

    end
end
   
LoadCase = ApplyWheelLoads(uID, Parameters, Options, LoadCase, WheelLine);
if strcmp(Parameters.Rating.Code, 'LRFD')
LoadCase = ApplyLaneLoads(uID, Parameters, LoadCase, LaneBound, Node);
end

            
end %CreateTruckLoadPath()




