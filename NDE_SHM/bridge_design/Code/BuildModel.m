function [Parameters, Node] = BuildModel(uID, Options, Parameters)
global tyPLATE tyBEAM rgPlaneXYZ

%% Dimensions
if Parameters.Sidewalk.Left > 0
    Parameters.TotalLeftSidewalk = Parameters.Sidewalk.Left+Parameters.Barrier.Width;
else
    Parameters.TotalLeftSidewalk = 0;
end
if Parameters.Sidewalk.Right > 0
    Parameters.TotalRightSidewalk = Parameters.Sidewalk.Right+Parameters.Barrier.Width;
else
    Parameters.TotalRightSidewalk = 0;
end
%Checks dia stagger
if strcmp(Parameters.Dia.Config,'Normal')
    Parameters.Dia.Stagger = 1;
elseif strcmp(Parameters.Dia.Config,'Parallel')
     Parameters.Dia.Stagger = 0;
else
     Parameters.Dia.Stagger = 2;
end

% % Checks skew
% if (Parameters.SkewNear==0 && Parameters.SkewFar==0) ||...
%    (abs(Parameters.SkewNear)<20 && Parameters.SkewFar==Parameters.SkewNear) % No skew or equal skews under 20
%     Parameters.Dia.Stagger=0;
% elseif (Parameters.SkewNear==0 || Parameters.SkewFar==0) || Parameters.SkewNear~=Parameters.SkewFar % Unequal skews
%     Parameters.Dia.Stagger=1;
% end

% Get depth of long. beams
BeamDepth = Parameters.Beam.Int.d;

% Assume equal skew for continuous span bridges
if length(Parameters.Length) > 1
    Parameters.SkewAvg = mean([Parameters.SkewNear Parameters.SkewFar]);
    Parameters.SkewNear = Parameters.SkewAvg;
    Parameters.SkewFar = Parameters.SkewAvg;
    % Ensure dimensions of NumDia equals the number of spans else make scalar
%     if length(Parameters.NumDia) ~= 1 && length(Parameters.NumDia) ~= length(Parameters.Length)
%         Parameters.NumDia = mean(Parameters.NumDia);
%     end
end

% Determine bridge length
NLength = Parameters.TotalWidth*tan(Parameters.SkewNear*pi/180);
FLength = Parameters.TotalWidth*tan(Parameters.SkewFar*pi/180);

switch Parameters.LengthOption
    case 'Center'
        LLength = Parameters.Length-NLength/2+FLength/2;
        RLength = Parameters.Length+NLength/2-FLength/2;
        SpanLength = max([LLength; RLength],[],1); % Compares each entry against entry in same location in other vector, returns vector
        TotalLength = SpanLength+abs(NLength)/2+abs(FLength)/2;
    case 'Girder'
        if Parameters.SkewNear == Parameters.SkewFar
            LLength = Parameters.Length;
            RLength = Parameters.Length;
            SpanLength = Parameters.Length;
            if Parameters.SkewNear >= 0
            	TotalLength = Parameters.Length+NLength;
            else
                TotalLength = Parameters.Length-NLength;
            end
        elseif Parameters.SkewNear > Parameters.SkewFar
            LLength = Parameters.Length-NLength+FLength;
            RLength = Parameters.Length;
            SpanLength = Parameters.Length;
            TotalLength = Parameters.Length+min([abs(NLength), abs(FLength)]);
        else
            LLength = Parameters.Length;
            RLength = Parameters.Length+NLength-FLength;
            SpanLength = Parameters.Length;
            TotalLength = Parameters.Length+min([abs(NLength), abs(FLength)]);
        end      
end

%% Node Coordinates
% Determine Mesh Size
WDiv = Parameters.TotalWidth/(Parameters.NumGirder-1);
WMesh = ceil(WDiv/Options.Modeling.AvgMeshSize);
if WMesh<2
    WMesh = 2;
elseif rem(WMesh,2) ~= 0
    WMesh = WMesh-1;
end
WMeshSize = WDiv/WMesh;

if Parameters.Dia.Stagger==0 % Parallel with skew
    LDiv = SpanLength./(mean(Parameters.NumDia)+1);
elseif Parameters.Dia.Stagger==1 % Normal to girders
    LDiv = TotalLength./(mean(Parameters.NumDia)+1);
else
    LDiv(1:Parameters.Spans,1) = abs(WDiv*tan(Parameters.SkewNear*pi/180));
end

LMesh = ceil(LDiv/Options.Modeling.AvgMeshSize);
LMesh = floor(LMesh/2)*2; % Rounds down to even number
LMesh(find(~LMesh)) = 2; % Replaces zeros with 2

LMeshSize = LDiv./LMesh;
try
    LMesh(LMeshSize>3*WMeshSize) = LMesh(LMeshSize>3*WMeshSize)*3;
    LMeshSize(LMeshSize>3*WMeshSize) = LMeshSize(LMeshSize>3*WMeshSize)/3;
catch
end

try
    WMeshSize = zeros(length(LMeshSize),1)+WMeshSize;
    WMesh = zeros(length(LMesh),1)+WMesh;
catch
end

WMesh(WMeshSize>3*LMeshSize) = WMesh(WMeshSize>3*LMeshSize)*3;
WMeshSize(WMeshSize>3*LMeshSize) = WMeshSize(WMeshSize>3*LMeshSize)/3;

WMesh = max(WMesh);
WMeshSize = min(WMeshSize);


% OVerhang mesh
if Parameters.Overhang > 0
    OMesh = ceil(Parameters.Overhang/Options.Modeling.AvgMeshSize);
    if OMesh<2
        OMesh = 2;
    end
    OMeshSize = Parameters.Overhang/OMesh;

    if OMeshSize>3*WMeshSize
        OMeshSize=OMeshSize/3;
        OMesh=OMesh*3;
    end
else
    OMesh = 1;
    OMeshSize = Parameters.Beam.Ext.bf/2;
end

Parameters.Model.OMesh = OMesh;
Parameters.Model.WMesh = WMesh;
Parameters.Model.LMesh = LMesh;
Parameters.Model.OMeshSize = OMeshSize;
Parameters.Model.WMeshSize = WMeshSize;
Parameters.Model.LMeshSize = LMeshSize;

xOffset = 0;
u=0;
Node=struct([]);
%% Node Creation
for h = 1:Parameters.Spans % Begin loop for span node creation
    
    n = 0;
    % Node ID Number Matrices
    if Parameters.Dia.Stagger == 0 % Parallel with skew
        Node(h).ID = zeros(LMesh(h)*(Parameters.NumDia(h)+1)+1, (Parameters.NumGirder-1)*WMesh+1,6);
    elseif Parameters.Dia.Stagger == 1 % Normal to girders
        Node(h).ID = zeros(LMesh(h)*(Parameters.NumDia(h)+1)+1, (Parameters.NumGirder-1)*WMesh+1,6);
    else
        StaggerRows(h) = ceil(SpanLength(h)/LMeshSize(h));
        StaggerMesh(h) = floor((StaggerRows(h)-LMesh(h))/(Parameters.NumDia(h)+1));
        StaggerRem(h) = rem((StaggerRows(h)-LMesh(h)),Parameters.NumDia(h)+1);
        Node(h).ID = zeros(StaggerRows(h)+1, (Parameters.NumGirder-1)*WMesh+1,6);
    end
    
    % Boundary Nodes
    
    WNodesTotal=(Parameters.NumGirder-1)*WMesh+1;
    for i=1:WNodesTotal
        % Deck
        n=n+1;
        Node(h).Type(n,:) = 'Deck';
        nearxcoord = (i-1)*WMeshSize*tan(Parameters.SkewNear*pi/180);
        nearycoord = (i-1)*WMeshSize;
        Node(h).y(n)=nearycoord;
        Node(h).x(n)=nearxcoord;
        Node(h).z(n)=0;
        Node(h).Location(n,:) = 'NAbut';
        Node(h).ID(1,i,1)=n;


        n=n+1;
        Node(h).Type(n,:) = 'Deck';
        farxcoord = RLength(h)+(i-1)*WMeshSize*tan(Parameters.SkewFar*pi/180);
        farycoord = (i-1)*WMeshSize;
        Node(h).y(n)=farycoord;
        Node(h).x(n)=farxcoord;
        Node(h).z(n)=0;
        Node(h).Location(n,:) = 'FAbut';
        Node(h).ID(end,i,1)=n;


        % Girder
        if rem((i-1),WMesh)==0
            n=n+1;
            Node(h).x(n)= nearxcoord;
            Node(h).y(n)= nearycoord;
            Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
            Node(h).Type(n,:) = 'GMid';
            Node(h).Location(n,:) = 'NAbut';
            Node(h).ElementCon(n,:) = [0, 0];
            Node(h).ID(1,i,3)=n;

            n=n+1;
            Node(h).x(n)=farxcoord;
            Node(h).y(n)=farycoord;
            Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
            Node(h).Type(n,:) = 'GMid';
            Node(h).Location(n,:) = 'FAbut';
            Node(h).ElementCon(n,:) = [0, 0];
            Node(h).ID(end,i,3)=n;

            n=n+1;
            Node(h).x(n)= nearxcoord;
            Node(h).y(n)= nearycoord;
            Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
            Node(h).Type(n,:) = 'GTop';
            Node(h).Location(n,:) = 'NAbut';
            Node(h).ID(1,i,2)=n;

            n=n+1;
            Node(h).x(n)=farxcoord;
            Node(h).y(n)=farycoord;
            Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
            Node(h).Type(n,:) = 'GTop';
            Node(h).Location(n,:) = 'FAbut';
            Node(h).ID(end,i,2)=n;

            n=n+1;
            Node(h).x(n)= nearxcoord;
            Node(h).y(n)= nearycoord;
            Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
            Node(h).Type(n,:) = 'GBot';
            Node(h).Location(n,:) = 'NAbut';
            Node(h).ID(1,i,4)=n;
            n=n+1;
            Node(h).x(n)=farxcoord;
            Node(h).y(n)=farycoord;
            Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
            Node(h).Type(n,:) = 'GBot';
            Node(h).Location(n,:) = 'FAbut';
            Node(h).ID(end,i,4)=n;

            switch Parameters.Dia.Type
                case 'Beam'

                case 'Cross'
                    if i<(Parameters.NumGirder-1)*WMesh
                        n=n+1;
                        Node(h).x(n)= nearxcoord+WDiv/2*tan(Parameters.SkewNear*pi/180);
                        Node(h).y(n)= nearycoord+WDiv/2;
                        Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'DMid';
                        Node(h).Location(n,:) = 'NAbut';
                        Node(h).ID(1,i+WMesh/2,3)=n;

                        n=n+1;
                        Node(h).x(n)=farxcoord+WDiv/2*tan(Parameters.SkewFar*pi/180);
                        Node(h).y(n)=farycoord+WDiv/2;
                        Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'DMid';
                        Node(h).Location(n,:) = 'FAbut';
                        Node(h).ID(end,i+WMesh/2,3)=n;
                    end
                case 'Chevron'
                    if i<(Parameters.NumGirder-1)*WMesh
                        n=n+1;
                        Node(h).x(n)= nearxcoord+WDiv/2*tan(Parameters.SkewNear*pi/180);
                        Node(h).y(n)= nearycoord+WDiv/2;
                        Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'DMid';
                        Node(h).Location(n,:) = 'NAbut';
                        Node(h).ID(1,i+WMesh/2,2)=n;

                        n=n+1;
                        Node(h).x(n)=farxcoord+WDiv/2*tan(Parameters.SkewFar*pi/180);
                        Node(h).y(n)=farycoord+WDiv/2;
                        Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'DMid';
                        Node(h).Location(n,:) = 'FAbut';
                        Node(h).ID(end,i+WMesh/2,2)=n;
                    end
            end
        end
    end


    % Interior Nodes
    if Parameters.Dia.Stagger == 0 || Parameters.Dia.Stagger == 1
        for i=1:WNodesTotal
            for j=2:(Parameters.NumDia(h)+1)*LMesh(h)
                if Parameters.Dia.Stagger==0 % Parallel with skew
                    xcoord = (j-1)*LMeshSize(h)+(i-1)*WMeshSize*tan(Parameters.SkewNear*pi/180);
                    ycoord = (i-1)*WMeshSize;
                else % Normal to girder
                    ycoord = (i-1)*WMeshSize;
                    if Parameters.SkewNear>=0
                        xcoord = (j-1)*LMeshSize(h);
                    else
                        xcoord = (j-1)*LMeshSize(h)+NLength;
                    end
                end

    %             If node location is within boundaries of bridge geometry, set node
                if  xcoord >= (i-1)*WMeshSize*tan(Parameters.SkewNear*pi/180)+Options.Modeling.MinMeshSize &&...
                    xcoord <= (i-1)*WMeshSize*tan(Parameters.SkewFar*pi/180)+RLength(h)-Options.Modeling.MinMeshSize
    %                 
    %                 Deck nodes
                    n=n+1;
                    Node(h).x(n)=xcoord;
                    Node(h).y(n)=ycoord;
                    Node(h).z(n)=0;
                    Node(h).Type(n,:) = 'Deck';
                    Node(h).Location(n,:) = 'Inter';
                    Node(h).ID(j,i,1)=n;

    %                 Girder line nodes
                    if rem((i-1),WMesh)==0
    %                     Beginning nodes
                        n=n+1;
                        Node(h).x(n)=xcoord;
                        Node(h).y(n)=ycoord;
                        Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'GMid';
                        Node(h).Location(n,:) = 'Inter';
                        Node(h).ElementCon(n,:) = [0, 0];
                        Node(h).ID(j,i,3)=n;

                        n=n+1;
                        Node(h).x(n)=xcoord;
                        Node(h).y(n)=ycoord;
                        Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'GTop';
                        Node(h).Location(n,:) = 'Inter';
                        Node(h).ID(j,i,2)=n;

    %                     % On wind bracing row
    %                     if (rem((j-1),LMesh(h)/2)==0 && rem((j-1),LMesh(h))~=0) && Parameters.WindBracing==1 && (i==1+WMesh || i==(Parameters.NumGirder-1)*WMesh+1-WMesh)
    %                         n=n+1;
    %                         Node(h).x(n)=xcoord;
    %                         Node(h).y(n)=ycoord;
    %                         Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
    %                         Node(h).Type(n,:) = 'WiEB';
    %                         Node(h).Location(n,:) = 'Inter';
    %                         Node(h).ID(j,i,4)=n;
    %                     end

    %                     On diaphragm row
                        if rem((j-1),LMesh(h))==0

                            n=n+1;
                            Node(h).x(n)=xcoord;
                            Node(h).y(n)=ycoord;
                            Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
                            Node(h).Type(n,:) = 'GBot';
                            Node(h).Location(n,:) = 'Inter';
                            Node(h).ID(j,i,4)=n;

    %                         Checks if end middle diaphragm node will have
    %                         connector on next girder
                            if  xcoord >= (i-1+WMesh)*WMeshSize*tan(Parameters.SkewNear*pi/180)+Options.Modeling.MinMeshSize &&...
                                xcoord <= (i-1+WMesh)*WMeshSize*tan(Parameters.SkewFar*pi/180)+SpanLength(h)-Options.Modeling.MinMeshSize &&...
                                i+1 <= (Parameters.NumGirder-1)*WMesh

                                switch Parameters.Dia.Type
                                    case 'Beam'

                                    case 'Cross'
                                        n=n+1;
                                        if Parameters.Dia.Stagger==0 % Parallel with skew
                                            Node(h).x(n)=xcoord+WDiv/2*tan(Parameters.SkewNear*pi/180);
                                        else
                                            Node(h).x(n)=xcoord;
                                        end
                                        Node(h).y(n)=ycoord+WDiv/2;
                                        Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
                                        Node(h).Type(n,:) = 'DMid';
                                        Node(h).Location(n,:) = 'Inter';
                                        Node(h).ID(j,i+WMesh/2,3)=n;
                                    case 'Chevron'
                                        n=n+1;
                                        if Parameters.Dia.Stagger==0 % Parallel with skew
                                            Node(h).x(n)=xcoord+WDiv/2*tan(Parameters.SkewNear*pi/180);
                                        else
                                            Node(h).x(n)=xcoord;
                                        end
                                        Node(h).y(n)=ycoord+WDiv/2;
                                        Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
                                        Node(h).Type(n,:) = 'DMid';
                                        Node(h).Location(n,:) = 'Inter';
                                        Node(h).ID(j,i+WMesh/2,2)=n;
                                end
                            end
                        end
                    end
                end
            end
        end
    else % Staggered cross bracing
        for i=1:WNodesTotal
            Rem = StaggerRem(h);
            for j=2:(Parameters.NumDia(h)+1)*StaggerMesh(h)+StaggerRem(h)+LMesh(h)
                xcoord = (j-1)*LMeshSize(h)+(i-1)*WMeshSize*tan(Parameters.SkewNear*pi/180);
                ycoord = (i-1)*WMeshSize;

    %           Deck nodes
                n=n+1;

                Node(h).x(n)=xcoord;
                Node(h).y(n)=ycoord;
                Node(h).z(n)=0;
                Node(h).Type(n,:) = 'Deck';
                Node(h).Location(n,:) = 'Inter';
                Node(h).ID(j,i,1)=n;

    %             Girder line nodes
                if rem((i-1),WMesh)==0
%                     Beginning nodes
                    n=n+1;
                    Node(h).x(n)=xcoord;
                    Node(h).y(n)=ycoord;
                    Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
                    Node(h).Type(n,:) = 'GMid';
                    Node(h).Location(n,:) = 'Inter';
                    Node(h).ElementCon(n,:) = [0,0];
                    Node(h).ID(j,i,3)=n;
                    
                    n=n+1;
                    Node(h).x(n)=xcoord;
                    Node(h).y(n)=ycoord;
                    Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
                    Node(h).Type(n,:) = 'GTop';
                    Node(h).Location(n,:) = 'Inter';
                    Node(h).ID(j,i,2)=n;
                    
    %                 On diaphragm row
                    if Rem > 0
                        DiaBuffer=1;
                        Overflow=0;
                    else
                        DiaBuffer=0;
                        Overflow=StaggerRem(h);
                    end
                    if rem((j-1)-Overflow-LMesh(h)/2, StaggerMesh(h)+DiaBuffer)==0 &&...
                            j <= (Parameters.NumDia(h)+1)*StaggerMesh(h)+StaggerRem(h) &&...
                            j > 1+Overflow+LMesh(h)/2 &&...
                            i < (Parameters.NumGirder-1)*WMesh+1

                        Rem = Rem-1;

                        n=n+1;
                        Node(h).x(n)=xcoord;
                        Node(h).y(n)=ycoord;
                        Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
                        Node(h).Type(n,:) = 'GBot';
                        Node(h).Location(n,:) = 'Inter';
                        Node(h).ID(j,i,4)=n;

    %                     Checks if end middle diaphragm node will have
    %                     connector on next girder
                        if  xcoord >= (i)*WMeshSize*tan(Parameters.SkewNear*pi/180) &&...
                                xcoord <= (i)*WMeshSize*tan(Parameters.SkewFar*pi/180)+SpanLength(h) &&...
                                i+1 <= (Parameters.NumGirder-1)*WMesh

                            switch Parameters.Dia.Type
                                case 'Beam'

                                case 'Cross'
                                    n=n+1;
                                    Node(h).x(n)=xcoord;
                                    Node(h).y(n)=ycoord+WDiv/2;
                                    Node(h).z(n)=-BeamDepth/2-Parameters.Deck.t/2-Parameters.Deck.Offset;
                                    Node(h).Type(n,:) = 'DMid';
                                    Node(h).Location(n,:) = 'Inter';
                                    Node(h).ID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,3)=n;

                                    n=n+1;
                                    Node(h).x(n)=xcoord;
                                    Node(h).y(n)=ycoord+WDiv;
                                    Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
                                    Node(h).Type(n,:) = 'GBot';
                                    Node(h).Location(n,:) = 'Inter';
                                    Node(h).ID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,4)=n;
                                case 'Chevron'
                                    n=n+1;
                                    Node(h).x(n)=xcoord+WDiv/2*tan(Parameters.SkewNear*pi/180);
                                    Node(h).x(n)=xcoord;
                                    Node(h).y(n)=ycoord+WDiv/2;
                                    Node(h).z(n)=-Parameters.Deck.t/2-Parameters.Deck.Offset;
                                    Node(h).Type(n,:) = 'DMid';
                                    Node(h).Location(n,:) = 'Inter';
                                    Node(h).ID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,2)=n;

                                    n=n+1;
                                    Node(h).x(n)=xcoord;
                                    Node(h).y(n)=ycoord+WDiv;
                                    Node(h).z(n)=-BeamDepth-Parameters.Deck.t/2-Parameters.Deck.Offset;
                                    Node(h).Type(n,:) = 'GBot';
                                    Node(h).Location(n,:) = 'Inter';
                                    Node(h).ID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,4)=n;
                            end
                        end
                    end
                end
            end
        end
    end

    % Rearrange ID matrix
    for i=1:size(Node(h).ID,2)
        k = find(Node(h).ID(2:end,i,1),1,'first')+1;
        if k~=2
            Node(h).ID(k-1,i,:)=Node(h).ID(1,i,:);
            Node(h).ID(1,i,:)=0;
        end
        k = find(Node(h).ID(2:end-1,i,1),1,'last')+1;
        if k~=size(Node(h).ID,1)-1
            Node(h).ID(k+1,i,:)=Node(h).ID(end,i,:);
            Node(h).ID(end,i,:)=0;
        end
    end

    %% Overhang Nodes
    % Add space for overhang nodes
    Node(h).ID = padarray(Node(h).ID, [0 OMesh], 0, 'both');

    kR = find(Node(h).ID(:,OMesh+1,1),1,'first'); %near right
    lR = find(Node(h).ID(:,OMesh+1,1),1,'last');  %far right
    kL = find(Node(h).ID(:,end-OMesh,1),1,'first'); %near left
    lL = find(Node(h).ID(:,end-OMesh,1),1,'last');  %far left

    % Boundary Nodes
    for i = 1:OMesh
        % Right
        % Near   
        n=n+1;
        xcoord = -i*OMeshSize*tan(Parameters.SkewNear*pi/180);
        ycoord = -i*OMeshSize;
        Node(h).x(n)=xcoord;
        Node(h).y(n)=ycoord;
        Node(h).z(n)=0;
        Node(h).Type(n,:) = 'Ovhg';
        Node(h).Location(n,:) = 'Right';
        Node(h).ID(kR,OMesh-i+1,1)=n;

        if i==OMesh && Parameters.Barrier.Height ~= 0
            n=n+1;
            Node(h).y(n)=ycoord;
            Node(h).x(n)=xcoord;
            if Parameters.TotalRightSidewalk>0
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2+Parameters.Sidewalk.Height;
            else
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2;
            end
            Node(h).Type(n,:) = 'Barr';
            Node(h).Location(n,:) = 'Right';
            Node(h).ID(kR,OMesh-i+1,5)=n;
        end

        % Far  
        n=n+1;
        xcoord = RLength(h)-i*OMeshSize*tan(Parameters.SkewFar*pi/180);
        ycoord = -i*OMeshSize;
        Node(h).x(n)=xcoord;
        Node(h).y(n)=ycoord;
        Node(h).z(n)=0;
        Node(h).Type(n,:) = 'Ovhg';
        Node(h).Location(n,:) = 'Right';
        Node(h).ID(lR,OMesh-i+1,1)=n;

        if i==OMesh && Parameters.Barrier.Height ~= 0
            n=n+1;
            Node(h).y(n)=ycoord;
            Node(h).x(n)=xcoord;
            if Parameters.TotalRightSidewalk>0
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2+Parameters.Sidewalk.Height;
            else
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2;
            end
            Node(h).Type(n,:) = 'Barr';
            Node(h).Location(n,:) = 'Right';
            Node(h).ID(lR,OMesh-i+1,5)=n;
        end

        % Left
        % Near   
        n=n+1;
        xcoord = NLength + i*OMeshSize*tan(Parameters.SkewNear*pi/180);
        ycoord = Parameters.TotalWidth+i*OMeshSize;
        Node(h).x(n)=xcoord;
        Node(h).y(n)=ycoord;
        Node(h).z(n)=0;
        Node(h).Type(n,:) = 'Ovhg';
        Node(h).Location(n,:) = 'Left ';
        Node(h).ID(kL,end-OMesh+i,1)=n;

        if i==OMesh && Parameters.Barrier.Height ~= 0
            n=n+1;
            Node(h).y(n)=ycoord;
            Node(h).x(n)=xcoord;
            if Parameters.TotalLeftSidewalk>0
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2+Parameters.Sidewalk.Height;
            else
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2;
            end
            Node(h).Type(n,:) = 'Barr';
            Node(h).Location(n,:) = 'Left ';
            Node(h).ID(kL,end-OMesh+i,5)=n;
        end

        % Far  
        n=n+1;
        xcoord = NLength + LLength(h) + i*OMeshSize*tan(Parameters.SkewFar*pi/180);
        ycoord = Parameters.TotalWidth+i*OMeshSize;
        Node(h).x(n)=xcoord;
        Node(h).y(n)=ycoord;
        Node(h).z(n)=0;
        Node(h).Type(n,:) = 'Ovhg';
        Node(h).Location(n,:) = 'Left ';
        Node(h).ID(lL,end-OMesh+i,1)=n;

        if i==OMesh && Parameters.Barrier.Height ~= 0
            n=n+1;
            Node(h).y(n)=ycoord;
            Node(h).x(n)=xcoord;
            if Parameters.TotalLeftSidewalk>0
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2+Parameters.Sidewalk.Height;
            else
                Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2;
            end
            Node(h).Type(n,:) = 'Barr';
            Node(h).Location(n,:) = 'Left ';
            Node(h).ID(lL,end-OMesh+i,5)=n;
        end
    end

    % Interior Nodes    
    for i=1:OMesh
        j=kR+1;
        while j<lR && Node(h).ID(j,OMesh+1,1)~=0 % Rightdeck edge node array is not zero
               
            % Right
%             if Parameters.Dia.Stagger==0 % Parallel with skew
                xcoord = -i*OMeshSize*tan(Parameters.SkewNear*pi/180)+(j-kR)*LMeshSize(h);
                ycoord = -i*OMeshSize;
%             else % Normal to girder
%                 ycoord = -i*OMeshSize;
%                 xcoord = Node(h).x(Node(h).ID(j,OMesh+1,1));
%             end

            if  xcoord >= -i*OMeshSize*tan(Parameters.SkewNear*pi/180)+Options.Modeling.MinMeshSize &&...
                xcoord <= -i*OMeshSize*tan(Parameters.SkewFar*pi/180)+RLength(h)-Options.Modeling.MinMeshSize 

                n=n+1;
                Node(h).x(n)=xcoord;
                Node(h).y(n)=ycoord;
                Node(h).z(n)=0;
                Node(h).Type(n,:) = 'Ovhg';
                Node(h).Location(n,:) = 'Right';
                Node(h).ID(j,OMesh-i+1,1)=n;

                if i==OMesh && Parameters.Barrier.Height ~= 0
                    n=n+1;
                    Node(h).y(n)=ycoord;
                    Node(h).x(n)=xcoord;
                    if Parameters.TotalRightSidewalk>0
                       Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2+Parameters.Sidewalk.Height;
                    else
                       Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2;
                    end
                    Node(h).Type(n,:) = 'Barr';
                    Node(h).Location(n,:) = 'Right';
                    Node(h).ID(j,OMesh-i+1,5)=n;
                end
            end

            j=j+1;
        end

        % Left
        j=kL+1;
        while j<lL && Node(h).ID(j,end-OMesh,1)~=0 % Left  deck edge node array is not zero       
%             if Parameters.Dia.Stagger==0 % Parallel with skew
                xcoord = NLength + i*OMeshSize*tan(Parameters.SkewNear*pi/180) + (j-kL)*LMeshSize(h);
                ycoord = Parameters.TotalWidth+i*OMeshSize;
%             else % Normal to girder
%                 ycoord = Parameters.TotalWidth+i*OMeshSize;
%                 xcoord = Node(h).x(Node(h).ID(j,end-OMesh,1));
%             end

            if  xcoord >= NLength + i*OMeshSize*tan(Parameters.SkewNear*pi/180)+ Options.Modeling.MinMeshSize &&...
                xcoord <= NLength + i*OMeshSize*tan(Parameters.SkewFar*pi/180) + LLength(h)-Options.Modeling.MinMeshSize 

                n=n+1;
                Node(h).x(n)=xcoord;
                Node(h).y(n)=ycoord;
                Node(h).z(n)=0;
                Node(h).Type(n,:) = 'Ovhg';
                Node(h).Location(n,:) = 'Left ';
                Node(h).ID(j,end-OMesh+i,1)=n;

                if i==OMesh && Parameters.Barrier.Height ~= 0
                    n=n+1;
                    Node(h).y(n)=ycoord;
                    Node(h).x(n)=xcoord;
                    if Parameters.TotalLeftSidewalk>0
                       Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2+Parameters.Sidewalk.Height;
                    else
                       Node(h).z(n)=Parameters.Barrier.Height/2+Parameters.Deck.t/2;
                    end
                    Node(h).Type(n,:) = 'Barr';
                    Node(h).Location(n,:) = 'Left ';
                    Node(h).ID(j,end-OMesh+i,5)=n;
                end
            end

            j=j+1;
        end
    end

    % Zip any gaps along boundaries due to minimum mesh size
    for i=1:OMesh
        % Right
        k = find(Node(h).ID(:,i,1),1,'first');
        while Node(h).ID(k+1,i,1) == 0
            Node(h).ID(k+1,i,:) = Node(h).ID(k,i,:);
            Node(h).ID(k,i,:) = 0;
            k = k+1;
        end
        k = find(Node(h).ID(:,i,1),1,'last');
        while Node(h).ID(k-1,i,1) == 0
            Node(h).ID(k-1,i,:)=Node(h).ID(k,i,:);
            Node(h).ID(k,i,:)=0;
            k = k - 1;
        end

        % Left
        k = find(Node(h).ID(:,end-OMesh+i,1),1,'first');
        while Node(h).ID(k+1,end-OMesh+i,1) == 0
            Node(h).ID(k+1,end-OMesh+i,:)=Node(h).ID(k,end-OMesh+i,:);
            Node(h).ID(k,end-OMesh+i,:)=0;
            k = k+1;
        end
        k = find(Node(h).ID(:,end-OMesh+i,1),1,'last');
        while Node(h).ID(k-1,end-OMesh+i,1) == 0
            Node(h).ID(k-1,end-OMesh+i,:)=Node(h).ID(k,end-OMesh+i,:);
            Node(h).ID(k,end-OMesh+i,:)=0;
            k = k-1;
        end
    end


    %% Sidewalk Nodes
    if Parameters.TotalLeftSidewalk>0
        if (Parameters.TotalLeftSidewalk-OMeshSize*OMesh)>0
            leftsidewalkmesh = round((Parameters.TotalLeftSidewalk-OMeshSize*OMesh)/WMeshSize)+OMesh;
        else
            leftsidewalkmesh = round(Parameters.TotalLeftSidewalk/OMeshSize);
        end

        for i=1:size(Node(h).ID,1)
            for j=(size(Node(h).ID,2)-leftsidewalkmesh):size(Node(h).ID,2)
                if Node(h).ID(i,j,1)~=0
                    n=n+1;
                    Node(h).y(n)=Node(h).y(Node(h).ID(i,j,1));
                    Node(h).x(n)=Node(h).x(Node(h).ID(i,j,1));
                    Node(h).z(n)=Parameters.Sidewalk.Height/2+Parameters.Deck.t/2;
                    Node(h).Type(n,:) = 'Sdwk';
                    Node(h).Location(n,:) = 'Left ';
                    Node(h).ID(i,j,6)=n;
                end
            end
        end
    end
    if Parameters.TotalRightSidewalk>0
        if (Parameters.TotalRightSidewalk-OMeshSize*OMesh)>0
            rightsidewalkmesh = round((Parameters.TotalRightSidewalk-OMeshSize*OMesh)/WMeshSize)+OMesh;
        else
            rightsidewalkmesh = round(Parameters.TotalRightSidewalk/OMeshSize);
        end

        for i=1:size(Node(h).ID,1)
            for j=1:rightsidewalkmesh+1
                if Node(h).ID(i,j,1)~=0
                    n=n+1;
                    Node(h).y(n)=Node(h).y(Node(h).ID(i,j,1));
                    Node(h).x(n)=Node(h).x(Node(h).ID(i,j,1));
                    Node(h).z(n)=Parameters.Sidewalk.Height/2+Parameters.Deck.t/2;
                    Node(h).Type(n,:) = 'Sdwk';
                    Node(h).Location(n,:) = 'Right';
                    Node(h).ID(i,j,6)=n;
                end
            end
        end
    end
    Node(h).x = Node(h).x+xOffset; %Shifts nodes over according to appropriate location for span.
    xOffset = xOffset + SpanLength(h);
end


%% Create Nodes in St7
for h=1:Parameters.Spans
    Node(h).Num = sort(nonzeros(Node(h).ID));
end

if Parameters.Spans > 1
    % Make nodes consistent by adding last number from previous span to all
    for h=1:Parameters.Spans - 1
        Node(h+1).ID(Node(h+1).ID>0) = Node(h+1).ID(Node(h+1).ID>0) + max(Node(h).Num);
        Node(h+1).Num = Node(h+1).Num + max(Node(h).Num);
    end
    
    % replace nodes from front of next span with nodes from end of previous span 
    for h=2:Parameters.Spans
        for i=1:size(Node(h-1).ID,2)
            % Find last rows of nodes in first span and first row of
            % nodes in second span
            rowID = find(Node(h-1).ID(:,i,1),1,'last');
            replaceID = Node(h-1).ID(rowID,i,:);
            replaceID = nonzeros(permute(replaceID, [3, 2, 1]));
            
            rowID = find(Node(h).ID(:,i,1),1,'first');
            deleteID = nonzeros(Node(h).ID(rowID,i,:));
            
            % Replace nodes in next span
            for j = 1:length(deleteID)
                Node(h).Type(Node(h).Num == deleteID(j),:) = Node(h-1).Type(Node(h-1).Num == replaceID(j),:);
                Node(h).Location(Node(h).Num == deleteID(j),:) = Node(h-1).Location(Node(h-1).Num == replaceID(j),:);
                
                Node(h).x(Node(h).Num == deleteID(j)) = Node(h-1).x(Node(h-1).Num == replaceID(j));
                Node(h).y(Node(h).Num == deleteID(j)) = Node(h-1).y(Node(h-1).Num == replaceID(j));
                Node(h).z(Node(h).Num == deleteID(j)) = Node(h-1).z(Node(h-1).Num == replaceID(j));
                
                % replace node numbers in ID structure
                Node(h).ID(Node(h).ID == deleteID(j)) = replaceID(j);
                Node(h).Num(Node(h).Num == deleteID(j)) = replaceID(j);
            end
        end
    
    % Sort Node.(h).Num and other node structure information
    [~, IX] = sort(Node(h).Num);
    Node(h).Num = Node(h).Num(IX);
    
    Node(h).Type = Node(h).Type(IX,:);
    Node(h).Location = Node(h).Location(IX,:);
    
    Node(h).x = Node(h).x(IX);
    Node(h).y = Node(h).y(IX);
    Node(h).z = Node(h).z(IX);

    % Find unique node number identifiers in all spans
    uniqueNode = [];
    for i = 1:Parameters.Spans
        uniqueNode = [uniqueNode; Node(i).Num];
    end
    uniqueNode = unique(uniqueNode);
        
    % Get missing node numbers
    nodeList = 1:max(Node(Parameters.Spans).Num);
    [Lia2, ~] = ismember(nodeList, uniqueNode, 'R2012a');
    misNum = nodeList(~Lia2);
    
    % Get missing node numbers in current span
    misNum = misNum(logical((misNum > min(Node(h).Num)) .* (misNum < max(Node(h).Num))));
    
    % Decrement node by node to fill in gaps
    while misNum(i) < max(Node(h).Num)
        Node(h).Num(Node(h).Num > misNum(i)) = Node(h).Num(Node(h).Num > misNum(i)) - 1;
        Node(h).ID(Node(h).ID > misNum(i)) = Node(h).ID(Node(h).ID > misNum(i)) - 1;
        if ~isempty(Node(h).Num > misNum(i))
            misNum(misNum > misNum(i)) = misNum(misNum > misNum(i)) - 1;
        end
        
        i = i + 1;
        if i > length(misNum)
            break
        end
    end
    end
    
    % Shift node numbers down to cover missing IDs
%     for h = 2:Parameters.Spans
%         if min(Node(h).Num) > max(Node(h-1).Num)
%             gap = min(Node(h).Num - Node(h-1).Num(i));
%             Node(h).Num = Node(h).Num - gap;
%             Node(h).ID = Node(h).ID - gap;
%         end
%         for i = 1:length(Node(h).Num) - 1
%             if Node(h).Num(i) ~= Node(h).Num(i+1)
%                 gap = Node(h).Num(i+1) - Node(h).Num(i);
%                 Node(h).Num(Node(h).Num > Node(h).Num(i)) = Node(h).Num(Node(h).Num > Node(h).Num(i)) - gap;
%                 Node(h).ID(Node(h).Num > Node(h).Num(i)) = Node(h).ID(Node(h).Num > Node(h).Num(i)) - gap;
%             end
%         end
%     end
end

replacementNodes = [];
for h=1:Parameters.Spans    % Create Model Nodes
    for i=1:length(Node(h).Num)
        if isempty(find(replacementNodes == Node(h).Num(i)))
            replacementNodes = [replacementNodes; Node(h).Num(i)];
            iErr = calllib('St7API', 'St7SetNodeXYZ', uID, Node(h).Num(i),...
                [Node(h).x(i), Node(h).y(i), Node(h).z(i)]);
            HandleError(iErr);
            iErr = calllib('St7API', 'St7SetNodeID', uID, Node(h).Num(i), Node(h).Num(i));
            HandleError(iErr);
        end
    end
end

%% Create elements
LinkNum=0; %Initialize link numbers.
EltNum=0;
BmNum = 0;
for h=1:Parameters.Spans
    NodeID = Node(h).ID;
    
    %% Create Deck Elements
    
    % Find property index for end diaphragms
    ind = find(strcmp({Parameters.St7Prop(:).propName},'Deck'));
    
    % Assign St7 Property Number
    PropNum=Parameters.St7Prop(ind).St7PropNum;
    
    for i = 1:size(NodeID,1)-1
        for j = 1:size(NodeID,2)-1
            Connection=0;
            deck=0;
            nodeblock = [NodeID(i,j,1), NodeID(i,j+1,1); NodeID(i+1,j,1), NodeID(i+1,j+1,1)];
            if all(all(nodeblock))==1 % no zeros
                deck = 1;
                Connection(1) = 4; % square
                Connection(2) = NodeID(i,j,1);
                Connection(3) = NodeID(i+1,j,1);
                Connection(4) = NodeID(i+1,j+1,1);
                Connection(5) = NodeID(i,j+1,1);
            elseif any(all(nodeblock))==1 && all(any(nodeblock))==1 % one zero
                deck = 1;
                Connection(1) = 3; % triangle
                if nodeblock(1,1)==0
                    Connection(2) = NodeID(i+1,j,1);
                    Connection(3) = NodeID(i+1,j+1,1);
                    Connection(4) = NodeID(i,j+1,1);
                elseif nodeblock(2,1)==0
                    Connection(2) = NodeID(i,j,1);
                    Connection(3) = NodeID(i+1,j+1,1);
                    Connection(4) = NodeID(i,j+1,1);
                elseif nodeblock(2,2)==0
                    Connection(2) = NodeID(i,j,1);
                    Connection(3) = NodeID(i+1,j,1);
                    Connection(4) = NodeID(i,j+1,1);
                else
                    Connection(2) = NodeID(i,j,1);
                    Connection(3) = NodeID(i+1,j,1);
                    Connection(4) = NodeID(i+1,j+1,1);
                end
            elseif all(any(nodeblock'))==1 % two zeros on the side
                deck = 1;
                Connection(1) = 3; % triangle
                if nodeblock(1,1)==0 % left side zero
                    k = find(NodeID(:,j,1),1,'last');
                    if k>i
                        k = find(NodeID(:,j,1),1,'first');
                    end
                    Connection(2) = NodeID(i+1,j+1,1);
                    Connection(3) = NodeID(i,j+1,1);
                    Connection(4) = NodeID(k,j,1);
                else % right side zero
                    k = find(NodeID(:,j+1,1),1,'last');
                    if k>i
                        k = find(NodeID(:,j+1,1),1,'first');
                    end
                    Connection(2) = NodeID(i,j,1);
                    Connection(3) = NodeID(i+1,j,1);
                    Connection(4) = NodeID(k,j+1,1);
                end
            end

            if deck==1
                EltNum=EltNum+1;
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyPLATE, EltNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyPLATE, EltNum, 1);
                HandleError(iErr);
            end
        end
    end

    %% Create SideWalk Elements
    
    % Find property index for end diaphragms
    ind = find(strcmp({Parameters.St7Prop(:).propName},'Sidewalk'));
    
    % Assign St7 Property Number
    PropNum=Parameters.St7Prop(ind).St7PropNum;
    
    if Parameters.TotalRightSidewalk>0
        for i = 1:size(NodeID,1)-1
            for j = 1:rightsidewalkmesh
                Connection=0;
                deck=0;
                nodeblock = [NodeID(i,j,6), NodeID(i,j+1,6); NodeID(i+1,j,6), NodeID(i+1,j+1,6)];
                if all(all(nodeblock))==1 % no zeros
                    deck = 1;
                    Connection(1) = 4; % square
                    Connection(2) = NodeID(i,j,6);
                    Connection(3) = NodeID(i+1,j,6);
                    Connection(4) = NodeID(i+1,j+1,6);
                    Connection(5) = NodeID(i,j+1,6);
                elseif any(all(nodeblock))==1 && all(any(nodeblock))==1 % one zero
                    deck = 1;
                    Connection(1) = 3; % triangle
                    if nodeblock(1,1)==0
                        Connection(2) = NodeID(i+1,j,6);
                        Connection(3) = NodeID(i+1,j+1,6);
                        Connection(4) = NodeID(i,j+1,6);
                    elseif nodeblock(2,1)==0
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j+1,6);
                        Connection(4) = NodeID(i,j+1,6);
                    elseif nodeblock(2,2)==0
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j,6);
                        Connection(4) = NodeID(i,j+1,6);
                    else
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j,6);
                        Connection(4) = NodeID(i+1,j+1,6);
                    end
                elseif all(any(nodeblock'))==1 % two zeros on the side
                    deck = 1;
                    Connection(1) = 3; % triangle
                    if nodeblock(1,1)==0 % left side zero
                        k = find(NodeID(:,j,6),1,'last');
                        if k>i
                            k = find(NodeID(:,j,6),1,'first');
                        end
                        Connection(2) = NodeID(i+1,j+1,6);
                        Connection(3) = NodeID(i,j+1,6);
                        Connection(4) = NodeID(k,j,6);
                    else % right side zero
                        k = find(NodeID(:,j+1,6),1,'last');
                        if k>i
                            k = find(NodeID(:,j+1,6),1,'first');
                        end
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j,6);
                        Connection(4) = NodeID(k,j+1,6);
                    end
                end

                if deck==1
                    EltNum=EltNum+1;
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyPLATE, EltNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyPLATE, EltNum, 1);
                    HandleError(iErr);
                end
            end
        end
    end

    if Parameters.TotalLeftSidewalk>0
        for i=1:size(NodeID,1)-1
            for j=(size(NodeID,2)-leftsidewalkmesh):size(NodeID,2)-1
                Connection=0;
                deck=0;
                nodeblock = [NodeID(i,j,6), NodeID(i,j+1,6); NodeID(i+1,j,6), NodeID(i+1,j+1,6)];
                if all(all(nodeblock))==1 % no zeros
                    deck = 1;
                    Connection(1) = 4; % square
                    Connection(2) = NodeID(i,j,6);
                    Connection(3) = NodeID(i+1,j,6);
                    Connection(4) = NodeID(i+1,j+1,6);
                    Connection(5) = NodeID(i,j+1,6);
                elseif any(all(nodeblock))==1 && all(any(nodeblock))==1 % one zero
                    deck = 1;
                    Connection(1) = 3; % triangle
                    if nodeblock(1,1)==0
                        Connection(2) = NodeID(i+1,j,6);
                        Connection(3) = NodeID(i+1,j+1,6);
                        Connection(4) = NodeID(i,j+1,6);
                    elseif nodeblock(2,1)==0
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j+1,6);
                        Connection(4) = NodeID(i,j+1,6);
                    elseif nodeblock(2,2)==0
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j,6);
                        Connection(4) = NodeID(i,j+1,6);
                    else
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j,6);
                        Connection(4) = NodeID(i+1,j+1,6);
                    end
                elseif all(any(nodeblock'))==1 % two zeros on the side
                    deck = 1;
                    Connection(1) = 3; % triangle
                    if nodeblock(1,1)==0 % left side zero
                        k = find(NodeID(:,j,6),1,'last');
                        if k>i
                            k = find(NodeID(:,j,6),1,'first');
                        end
                        Connection(2) = NodeID(i+1,j+1,6);
                        Connection(3) = NodeID(i,j+1,6);
                        Connection(4) = NodeID(k,j,6);
                    else % right side zero
                        k = find(NodeID(:,j+1,6),1,'last');
                        if k>i
                            k = find(NodeID(:,j+1,6),1,'first');
                        end
                        Connection(2) = NodeID(i,j,6);
                        Connection(3) = NodeID(i+1,j,6);
                        Connection(4) = NodeID(k,j+1,6);
                    end
                end

                if deck==1
                    EltNum=EltNum+1;
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyPLATE, EltNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyPLATE, EltNum, 1);
                    HandleError(iErr);
                end
            end
        end
    end
    
    %% Create Beam Elements
    if isfield(Parameters.Beam.Int.CoverPlate,'Length')
        CoverPl = nearest(Parameters.Beam.Int.CoverPlate.Length./LMeshSize);
    else
        Parameters.Beam.Int.CoverPlate.Length = 0;
        CoverPl = 0;
    end
    
    Connection=0;
    
    for i=1+OMesh:WMesh:(Parameters.NumGirder-1)*WMesh+1+OMesh
        kStart = find(NodeID(:,i,3),1,'first');
        kEnd = find(NodeID(:,i,3),1,'last');
        k = kStart;
        while k<size(NodeID,1) && NodeID(k+1,i,3)~=0
            BmNum=BmNum+1;
            Connection(1) = 2;
            Connection(2) = NodeID(k,i,3);
            Connection(3) = NodeID(k+1,i,3);
            Node(h).ElementCon(NodeID(k,i,3),1) = BmNum;
            Node(h).ElementCon(NodeID(k+1,i,3),2) = BmNum;
            
            % Check for coverplate region or prestressed
            if strcmp(Parameters.structureType, 'Prestressed')
                PropNum = Parameters.St7Prop(12).St7PropNum;
            else
                if Parameters.Beam.Int.CoverPlate.Length(1) ~= 0 &&...
                        (h==1 && k>kEnd-CoverPl(h)) ||...
                        (h==length(Parameters.Length) && k<CoverPl(h)+kStart) ||...
                        (h~=length(Parameters.Length) && h~=1 && (k<CoverPl(h)+kStart-1 || k>kEnd-CoverPl(h)))
                    % Int/Ext Check
                    if i == 1+OMesh || i == (Parameters.NumGirder-1)*WMesh+1+OMesh
                        PropNum = Parameters.St7Prop(7).St7PropNum;
                    else
                        PropNum = Parameters.St7Prop(8).St7PropNum;
                    end
                else % No coverplate region
                    % Int/Ext Check
                    if i == 1+OMesh || i == (Parameters.NumGirder-1)*WMesh+1+OMesh
                        PropNum = Parameters.St7Prop(5).St7PropNum;
                    else
                        PropNum = Parameters.St7Prop(6).St7PropNum;
                    end
                end
            end
            
            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
            HandleError(iErr);
            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
            HandleError(iErr);
            k=k+1;
        end
    end
    
    %     CoverPl = nearest(Parameters.Beam.CoverPlate.Length./LMeshSize);
%       Connection=0;
    
%     for i=1+OMesh:WMesh:(Parameters.NumGirder-1)*WMesh+1+OMesh
%         kStart = find(NodeID(:,i,3),1,'first');
%         kEnd = find(NodeID(:,i,3),1,'last');
%         k = kStart;
%         while k<size(NodeID,1) && NodeID(k+1,i,3)~=0
%             BmNum=BmNum+1;
%             Connection(1) = 2;
%             Connection(2) = NodeID(k,i,3);
%             Connection(3) = NodeID(k+1,i,3);
%             Node(h).ElementCon(NodeID(k,i,3),1) = BmNum;
%             Node(h).ElementCon(NodeID(k+1,i,3),2) = BmNum;
%             
%             % Check for coverplate region
%             if Parameters.Beam.CoverPlate.Length(1) ~= 0 &&...
%                     (h==1 && k>kEnd-CoverPl(h)) ||...
%                     (h==length(Parameters.Length) && k<CoverPl(h)+kStart) ||...
%                     (h~=length(Parameters.Length) && h~=1 && (k<CoverPl(h)+kStart-1 || k>kEnd-CoverPl(h)))
%                 % Int/Ext Check
%                 if i == 1+OMesh || i == (Parameters.NumGirder-1)*WMesh+1+OMesh
%                     PropNum = Parameters.Beam.Ext.CoverPlate.St7PropNum;
%                 else
%                     PropNum = Parameters.Beam.Int.CoverPlate.St7PropNum;
%                 end
%             else % No coverplate region
%                 % Int/Ext Check
%                 if i == 1+OMesh || i == (Parameters.NumGirder-1)*WMesh+1+OMesh
%                     PropNum = Parameters.Beam.Ext.St7PropNum;
%                 else
%                     PropNum = Parameters.Beam.Int.St7PropNum;
%                 end
%             end
%             
%             iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
%             HandleError(iErr);
%             iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
%             HandleError(iErr);
%             k=k+1;
%         end
%     end

    %% Abutment Cross-Bracing
    
    % Find property index for end diaphragms
    ind = find(strcmp({Parameters.St7Prop(:).propName},'End Diaphragm'));
    % Assign St7 Property Number
    PropNum=Parameters.St7Prop(ind).St7PropNum;
    
    Connection=0;
    for i=1+OMesh:WMesh:(Parameters.NumGirder-2)*WMesh+1+OMesh
        switch Parameters.Dia.Type
            case 'Beam'
    %             Near
                j = find(NodeID(:,i,3),1,'first');
                k = find(NodeID(:,i+WMesh,3),1,'first');
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,3);
                Connection(3) = NodeID(k,i+WMesh,3);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);

    %             Far
                if h == Parameters.Spans
                    j = find(NodeID(:,i,3),1,'last');
                    k = find(NodeID(:,i+WMesh,3),1,'last');
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,3);
                    Connection(3) = NodeID(k,i+WMesh,3);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                end
            case 'Cross'
    %             Near
                j = find(NodeID(:,i,3),1,'first');
                k = find(NodeID(:,i+WMesh/2,3),1,'first');
                l = find(NodeID(:,i+WMesh,3),1,'first');
    %             Top Horizontal
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,2);
                Connection(3) = NodeID(l,i+WMesh,2);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
    %             Bottom Horizontal
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,4);
                Connection(3) = NodeID(l,i+WMesh,4);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
    %             Cross
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,2);
                Connection(3) = NodeID(k,i+WMesh/2,3);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(k,i+WMesh/2,3);
                Connection(3) = NodeID(l,i+WMesh,4);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
    %             Cross
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,4);
                Connection(3) = NodeID(k,i+WMesh/2,3);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(k,i+WMesh/2,3);
                Connection(3) = NodeID(l,i+WMesh,2);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);

    %             Far
                if h == Parameters.Spans
                    j = find(NodeID(:,i,3),1,'last');
                    k = find(NodeID(:,i+WMesh/2,3),1,'last');
                    l = find(NodeID(:,i+WMesh,3),1,'last');
                    %             Top Horizontal
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,2);
                    Connection(3) = NodeID(l,i+WMesh,2);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    %             Bottom Horizontal
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,4);
                    Connection(3) = NodeID(l,i+WMesh,4);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    %             Cross
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,2);
                    Connection(3) = NodeID(k,i+WMesh/2,3);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(k,i+WMesh/2,3);
                    Connection(3) = NodeID(l,i+WMesh,4);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    %             Cross
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,4);
                    Connection(3) = NodeID(k,i+WMesh/2,3);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(k,i+WMesh/2,3);
                    Connection(3) = NodeID(l,i+WMesh,2);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                end
            case 'Chevron'
    %             Near
                j = find(NodeID(:,i,3),1,'first');
                k = find(NodeID(:,i+WMesh/2,2),1,'first');
                l = find(NodeID(:,i+WMesh,3),1,'first');
                % Top Horizontal
                BmNum=BmNum+1;
                Connection(1) =2;
                Connection(2) = NodeID(j,i,2);
                Connection(3) = NodeID(k,i+WMesh/2,2);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(k,i+WMesh/2,2);
                Connection(3) = NodeID(l,i+WMesh,2);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
                % Bottom Horizontal
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,4);
                Connection(3) = NodeID(l,i+WMesh,4);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
    %             Cross
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,4);
                Connection(3) = NodeID(k,i+WMesh/2,2);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
    %             Cross
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(k,i+WMesh/2,2);
                Connection(3) = NodeID(l,i+WMesh,4);
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);

    %             Far
                if h == Parameters.Spans
                    j = find(NodeID(:,i,3),1,'last');
                    k = find(NodeID(:,i+WMesh/2,2),1,'last');
                    l = find(NodeID(:,i+WMesh,3),1,'last');
                    % Top Horizontal
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,2);
                    Connection(3) = NodeID(k,i+WMesh/2,2);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(k,i+WMesh/2,2);
                    Connection(3) = NodeID(l,i+WMesh,2);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    % Bottom Horizontal
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,4);
                    Connection(3) = NodeID(l,i+WMesh,4);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    %             Cross
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(j,i,4);
                    Connection(3) = NodeID(k,i+WMesh/2,2);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                    %             Cross
                    BmNum=BmNum+1;
                    Connection(1) = 2;
                    Connection(2) = NodeID(k,i+WMesh/2,2);
                    Connection(3) = NodeID(l,i+WMesh,4);
                    iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                    HandleError(iErr);
                    iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                    HandleError(iErr);
                end
        end
    end

    % Find property index for interior diaphragms
    if strcmp(Parameters.structureType, 'Prestressed')
        ind = find(strcmp({Parameters.St7Prop(:).propName},'Diaphragm Concrete'));
    else
        ind = find(strcmp({Parameters.St7Prop(:).propName},'Int Diaphragm'));
    end
    
    % Assign St7 Property Number
    PropNum=Parameters.St7Prop(ind).St7PropNum;
    
    Connection=0;
    if Parameters.Dia.Stagger == 0 || Parameters.Dia.Stagger == 1
        for i=1+OMesh:WMesh:(Parameters.NumGirder-2)*WMesh+1+OMesh
            j = find(NodeID(:,i,3),1,'first');
            k = find(NodeID(:,i,3),1,'last');
            l = find(NodeID(:,i+WMesh,3),1,'first');
            m = find(NodeID(:,i+WMesh,3),1,'last');
            while j<k-1
                j=j+1; 
                if j~=l && j~=m && rem((j-1),LMesh(h))==0 && NodeID(j,i+WMesh,3)~=0  
                    switch Parameters.Dia.Type
                        case 'Beam'
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,3);
                            Connection(3) = NodeID(j,i+WMesh,3);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                        case 'Cross'
    %                         Top Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,2);
                            Connection(3) = NodeID(j,i+WMesh,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Bottom Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j,i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,2);
                            Connection(3) = NodeID(j,i+WMesh/2,3);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i+WMesh/2,3);
                            Connection(3) = NodeID(j,i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j,i+WMesh/2,3);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i+WMesh/2,3);
                            Connection(3) = NodeID(j,i+WMesh,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                        case 'Chevron'
                            % Top Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,2);
                            Connection(3) = NodeID(j,i+WMesh/2,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i+WMesh/2,2);
                            Connection(3) = NodeID(j,i+WMesh,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            % Bottom Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j,i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j,i+WMesh/2,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i+WMesh/2,2);
                            Connection(3) = NodeID(j,i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                    end
                end
            end
        end
    else % Staggered diaphragms
        for i=1+OMesh:WMesh:(Parameters.NumGirder-2)*WMesh+1+OMesh 
            Rem = StaggerRem(h);
            for j=2:(Parameters.NumDia(h)+1)*StaggerMesh(h)+StaggerRem(h)-LMesh(h)

                %On diaphragm row
                if Rem > 0
                    DiaBuffer=1;
                    Overflow=0;
                else
                    DiaBuffer=0;
                    Overflow=StaggerRem(h);
                end
                if rem((j-1)-Overflow-LMesh(h)/2, StaggerMesh(h)+DiaBuffer)==0 &&...
                   j > 1+Overflow+LMesh(h)/2
                    Rem=Rem-1;
                    switch Parameters.Dia.Type
                        case 'Beam'
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,3);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,3);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                        case 'Cross'
    %                         Top Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,2);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Bottom Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,2);
                            Connection(3) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,3);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,3);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,3);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            BmNum=BmNum+1;
                            Connection(1) = 3;
                            Connection(2) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,3);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                        case 'Chevron'
                            % Top Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,2);
                            Connection(3) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,2);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                            % Bottom Horizontal
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j,i,4);
                            Connection(3) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,2);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
    %                         Cross
                            BmNum=BmNum+1;
                            Connection(1) = 2;
                            Connection(2) = NodeID(j-LMesh(h)/2*sign(Parameters.SkewNear),i+WMesh/2,2);
                            Connection(3) = NodeID(j-LMesh(h)*sign(Parameters.SkewNear),i+WMesh,4);
                            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                            HandleError(iErr);
                            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                            HandleError(iErr);
                    end
                end
            end
        end
    end

    %% Wind Bracing
    % Connection=0;
    % if Parameters.WindBracing==1
    %     PropNum=7;
    %     l = find(NodeID(:,OMesh+1,4),1,'last');
    %     k = find(NodeID(:,OMesh+1,4),2,'first');
    %     j = find(NodeID(k(1)+1:end,OMesh+1+WMesh,4),1,'first');
    %     
    %     while j+k(1)<l && k(2)<=l
    %         BmNum=BmNum+1;
    %         Connection(1) = 2;
    %         Connection(2) = NodeID(k(1),OMesh+1,4);
    %         Connection(3) = NodeID(k(1)+j,OMesh+1+WMesh,4);
    %         
    %         iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
    %         HandleError(iErr);
    %         iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
    %         HandleError(iErr);
    %         
    %         BmNum=BmNum+1;
    %         Connection(1) = 2;
    %         Connection(2) = NodeID(k(1)+j,OMesh+1+WMesh,4);
    %         Connection(3) = NodeID(k(2),OMesh+1,4);
    %         
    %         iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
    %         HandleError(iErr);
    %         iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
    %         HandleError(iErr);
    %         
    %         if k(2)==l
    %             break
    %         end
    %         
    %         k(1) = k(2);
    %         k(2) = k(2) + find(NodeID(k(2)+1:end,OMesh+1,4),1,'first');
    %         j = find(NodeID(k(1)+1:end,OMesh+1+WMesh,4),1,'first');
    %     end
    %     
    %     k = find(NodeID(:,OMesh+(Parameters.NumGirder-1)*WMesh+1,4),2,'first');
    %     l = find(NodeID(:,OMesh+(Parameters.NumGirder-1)*WMesh+1,4),1,'last');
    %     j = find(NodeID(k(1)+1:end,OMesh+(Parameters.NumGirder-1)*WMesh+1-WMesh,4),1,'first');
    %     while j+k(1)<l && k(2)<=l
    %         BmNum=BmNum+1;
    %         Connection(1) = 2;
    %         Connection(2) = NodeID(k(1),OMesh+(Parameters.NumGirder-1)*WMesh+1,4);
    %         Connection(3) = NodeID(k(1)+j,OMesh+(Parameters.NumGirder-1)*WMesh+1-WMesh,4);
    %         
    %         iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
    %         HandleError(iErr);
    %         iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
    %         HandleError(iErr);
    %         
    %         BmNum=BmNum+1;
    %         Connection(1) = 2;
    %         Connection(2) = NodeID(k(1)+j,OMesh+(Parameters.NumGirder-1)*WMesh+1-WMesh,4);
    %         Connection(3) = NodeID(k(2),OMesh+(Parameters.NumGirder-1)*WMesh+1,4);
    %         
    %         iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
    %         HandleError(iErr);
    %         iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
    %         HandleError(iErr);
    %        
    %         if k(2)==l
    %             break
    %         end
    %         
    %         k(1) = k(2);
    %         k(2) = k(2) + find(NodeID(k(2)+1:end,OMesh+(Parameters.NumGirder-1)*WMesh+1,4),1,'first');
    %         j = find(NodeID(k(1)+1:end,OMesh+(Parameters.NumGirder-1)*WMesh+1-WMesh,4),1,'first');
    %     end
    % end

    %% Barrier Elements
    if Parameters.Barrier.Width>0
        % Right Barrier
        PropNum=Parameters.St7Prop(3).St7PropNum;
        Connection=0;
        k = find(NodeID(:,1,5),1,'first');
        while k<size(NodeID,1) && NodeID(k+1,1,5)~=0
            BmNum=BmNum+1;
            Connection(1) = 2;
            Connection(2) = NodeID(k,1,5);
            Connection(3) = NodeID(k+1,1,5);

            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
            HandleError(iErr);
            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
            HandleError(iErr);
            k=k+1;
        end

        % Left Barrier
        PropNum=Parameters.St7Prop(4).St7PropNum;
        Connection=0;
        k = find(NodeID(:,end,5),1,'first');
        while k<size(NodeID,1) && NodeID(k+1,end,5)~=0
            BmNum=BmNum+1;
            Connection(1) = 2;
            Connection(2) = NodeID(k,end,5);
            Connection(3) = NodeID(k+1,end,5);

            iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
            HandleError(iErr);
            iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
            HandleError(iErr);
            k=k+1;
        end
    end


    %% Create Deck To Girder Links and Create Girder to Cross-Bracing Links 
    PropNum = Parameters.St7Prop(11).St7PropNum;
    for i=1+OMesh:WMesh:(Parameters.NumGirder-1)*WMesh+1+OMesh
        for j=1:size(NodeID,1)
            if NodeID(j,i,2)~=0
                % Deck CL to beam top surface
%                 LinkNum = LinkNum + 1;
%                 iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
%                     rgPlaneXYZ, [2, NodeID(j,i,1), NodeID(j,i,2)]);
%                 HandleError(iErr);

                % Create beam as link
                BmNum=BmNum+1;
                Connection(1) = 2;
                Connection(2) = NodeID(j,i,1);
                Connection(3) = NodeID(j,i,2);
            
                iErr = calllib('St7API', 'St7SetElementConnection', uID, tyBEAM, BmNum, PropNum, Connection);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetEntityGroup', uID, tyBEAM, BmNum, 1);
                HandleError(iErr);
                k=k+1;
                
                % Beam CL to beam top surface
                LinkNum = LinkNum + 1;
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(j,i,3), NodeID(j,i,2)]);
                HandleError(iErr);
            end    
            if NodeID(j,i,4)~=0
                LinkNum = LinkNum + 1;
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(j,i,3), NodeID(j,i,4)]);
                HandleError(iErr);
            end
        end
    end


    %% Deck to Barrier Links
    if Parameters.Barrier.Width>0
        % Right Barrier
        k = find(NodeID(:,1,5),1,'first');
        while k<=size(NodeID,1) && NodeID(k,1,5)~=0
            LinkNum = LinkNum + 1;
            if Parameters.TotalRightSidewalk>0
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(k,1,6), NodeID(k,1,5)]);
                HandleError(iErr);
            else
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(k,1,1), NodeID(k,1,5)]);
                HandleError(iErr);
            end
            k=k+1;
        end

        % Left Barrier
        k = find(NodeID(:,end,5),1,'first');
        while k<=size(NodeID,1) && NodeID(k,end,5)~=0
            LinkNum = LinkNum + 1;
            if Parameters.TotalLeftSidewalk>0
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(k,end,5), NodeID(k,end,6)]);
                HandleError(iErr);
            else
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(k,end,1), NodeID(k,end,5)]);
                HandleError(iErr);
            end
            k=k+1;
        end
    end
    %% Deck to SideWalk Links
    % Right Sidewalk
    if Parameters.TotalRightSidewalk>0
        for i=1:rightsidewalkmesh+1
            k = find(NodeID(:,i,6),1,'first');
            while k<=size(NodeID,1) && NodeID(k,1,6)~=0
                LinkNum = LinkNum + 1;
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(k,i,1), NodeID(k,i,6)]);
                HandleError(iErr);
                k=k+1;
            end
        end
    end

    % Left Sidewalk
    if Parameters.TotalLeftSidewalk>0
        for i=(size(NodeID,2)-leftsidewalkmesh):size(NodeID,2)
            k = find(NodeID(:,i,6),1,'first');
            while k<=size(NodeID,1) && NodeID(k,i,6)~=0
                LinkNum = LinkNum + 1;
                iErr = calllib('St7API', 'St7SetRigidLink', uID, LinkNum, 1,...
                    rgPlaneXYZ, [2, NodeID(k,i,1), NodeID(k,i,6)]);
                HandleError(iErr);
                k=k+1;
            end
        end
    end
end
end %BuildModel()

