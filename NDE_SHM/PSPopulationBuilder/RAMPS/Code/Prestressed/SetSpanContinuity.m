function [ BmNums ] = SetSpanContinuity( Node, Parameters, Status, Type, BmNums, uID )
%SETSPANCONTINUITY Releases or fixes connection between connecting beams over a pier
%   Node - Nodes file
%   Parameters - Parameters structure
%   Status - string specifying whether to 'realease' or 'fix'
%   Type - Specifies the type of release: 'translational' or 'rotational'
%   BmNums - Beam numbers of beams over interior supports, leave empty if number not known

if isempty(BmNums)
    %% Get Boundary Nodes
    [ BNodes ] = GetBoundaryNodes( Node, Parameters, 'girder' );
    %% Get corresponding beams
    % Select only nodes over interior supports
    PierNodes = [];
    BmNums = [];
    for ii = 2:size(BNodes,3)
        PierNodes = [PierNodes; BNodes(:,1,ii)];

        % Select corresponding beam numbers
        BmNums = [BmNums; Node(ii).ElementCon(BNodes(:,1,ii),1)];
    end
end
            

% Release beam ends
try
    St7BeamRelease( uID, BmNums, 1, Status , Type)
catch
    disp('Failed to modify beam connection fixity')
    return
end



end

