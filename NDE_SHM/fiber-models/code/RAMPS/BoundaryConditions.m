function BoundaryConditions(uID, Node, Parameters, FCaseNum)
%% Set Boundary Conditions for Piers
for h = 1:Parameters.Spans + 1
    if h > Parameters.Spans
        span = Parameters.Spans;
    else
        span = h;
    end
    
    % Restraints
    if Parameters.Bearing.Type(h) == 1 %fixed
        fixity = Parameters.Bearing.Fixed.Fixity(1:6); 
        disp = Parameters.Bearing.Fixed.Disp;

        springVal = Parameters.Bearing.Fixed.Spring(1:6).*10.^Parameters.Bearing.Fixed.Alpha(1:6,1)';
    else % expansion
        fixity = Parameters.Bearing.Expansion.Fixity(1:6); 
        disp = Parameters.Bearing.Expansion.Disp;
        
        springVal = Parameters.Bearing.Expansion.Spring(1:6).*10.^Parameters.Bearing.Expansion.Alpha(1:6,1)';
    end
    
    % Set Fixity
    for i=1+Parameters.Model.OMesh:Parameters.Model.WMesh:(Parameters.NumGirder-1)*Parameters.Model.WMesh+1+Parameters.Model.OMesh
        if h > Parameters.Spans                       % Last pier
            k = find(Node(span).ID(:,i,4),1,'last');
        else                                          % all other piers
            k = find(Node(span).ID(:,i,4),1,'first');
        end
        
        iErr = calllib('St7API', 'St7SetNodeRestraint6', uID,...
            Node(span).ID(k,i,4),FCaseNum,1,fixity,disp);
        HandleError(iErr);
        
        iErr = calllib('St7API', 'St7SetNodeKTranslation3F', uID,...
            Node(span).ID(k,i,4),FCaseNum,1,springVal(1:3));
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetNodeKRotation3F', uID,...
            Node(span).ID(k,i,4),FCaseNum,1,springVal(4:6));
        HandleError(iErr);
    end
    
    % Alignment Bearing
    if (Parameters.Bearing.Fixed.Fixity(7) == 1 && Parameters.Bearing.Type(h) == 1) ||... %fixed
            (Parameters.Bearing.Expansion.Fixity(7) == 1 && Parameters.Bearing.Type(h) == 0) ||... %expansion
            (Parameters.Bearing.Fixed.Spring(7) ~= 0 && Parameters.Bearing.Type(h) == 1) ||... %fixed
            (Parameters.Bearing.Expansion.Spring(7) ~= 0 && Parameters.Bearing.Type(h) == 0) %expansion
                  
        % check if fixed or expansion
        if Parameters.Bearing.Type(h) == 1
            fixity = Parameters.Bearing.Fixed.Fixity(1:6); 
            fixity(2) = Parameters.Bearing.Fixed.Fixity(7); % translation in transverse direction - if spring fixity is zero
            
            disp = Parameters.Bearing.Fixed.Disp;
            springVal = Parameters.Bearing.Fixed.Spring(1:6).*10.^Parameters.Bearing.Fixed.Alpha(1:6,1)';
            springVal(2) = Parameters.Bearing.Fixed.Spring(7)*10.^Parameters.Bearing.Fixed.Alpha(7,1)';
        else
            fixity = Parameters.Bearing.Expansion.Fixity(1:6); 
            fixity(2) = Parameters.Bearing.Expansion.Fixity(7); % translation in transverse direction - if spring fixity is zero
            
            disp = Parameters.Bearing.Expansion.Disp;
            springVal = Parameters.Bearing.Expansion.Spring(1:6).*10.^Parameters.Bearing.Expansion.Alpha(1:6,1)';
            springVal(2) = Parameters.Bearing.Expansion.Spring(7)*10.^Parameters.Bearing.Expansion.Alpha(7,1)';
        end
        
        midgirder = ceil(Parameters.NumGirder/2);
        midnode = 1+Parameters.Model.OMesh+Parameters.Model.WMesh*(midgirder-1);

        if h > Parameters.Spans
            k = find(Node(span).ID(:,midnode,4),1,'last');
        else
            k = find(Node(span).ID(:,midnode,4),1,'first');
        end
        
        iErr = calllib('St7API', 'St7SetNodeRestraint6', uID,...
            Node(span).ID(k,midnode,4),FCaseNum,1,fixity,disp);
        HandleError(iErr);
        
        iErr = calllib('St7API', 'St7SetNodeKTranslation3F', uID,...
            Node(span).ID(k,midnode,4),FCaseNum,1,[springVal(1:3)]);
        HandleError(iErr);
    end
    
    % Longitudinal Fixity Bearing
    if (Parameters.Bearing.Fixed.Fixity(8) == 1 && Parameters.Bearing.Type(h) == 1) ||... %fixed
            (Parameters.Bearing.Expansion.Fixity(8) == 1 && Parameters.Bearing.Type(h) == 0) %expansion
        
        fixity(1) = 1; % translation in longitudinal direction
        
        % check if fixed or expansion
        if Parameters.Bearing.Type(h) == 1
            disp = Parameters.Bearing.Fixed.Disp;
        else
            disp = Parameters.Bearing.Expansion.Disp;
        end

        firstnode = 1+Parameters.Model.OMesh;
        
        endgirder = Parameters.NumGirder;
        endnode = 1+Parameters.Model.OMesh+Parameters.Model.WMesh*(endgirder-1);

        if h > Parameters.Spans % Last pier
            kf = find(Node(span).ID(:,firstnode,4),1,'last');
            ke = find(Node(span).ID(:,endnode,4),1,'last');
        else                    % all others
            kf = find(Node(span).ID(:,firstnode,4),1,'first');
            ke = find(Node(span).ID(:,endnode,4),1,'first');
        end
        
        % First Girder
        iErr = calllib('St7API', 'St7SetNodeRestraint6', uID,...
            Node(span).ID(kf,firstnode,4),FCaseNum,1,fixity,disp);
        HandleError(iErr);
   
        % Last girder
        iErr = calllib('St7API', 'St7SetNodeRestraint6', uID,...
        Node(span).ID(ke,endnode,4),FCaseNum,1,fixity,disp);
        HandleError(iErr);

    end
end
end %BoundaryConditions()