function St7ApplyNodeForce(uID, LoadCase, Nodes, Force)
%ST7APPLYNODEFORCE      Applies point force to specified nodes in a St7 model
%   uID     -   Numeric identifier of open St7 file
%   Nodes   -   Array of all nodes to which the force is to be applied
%   Force   -   Vector of forces in the global principle directions ([X, Y, Z])
%
%   Created 7/15/14
%                   John Braley
%
for ii = 1:length(Nodes)
    iErr = calllib('St7API', 'St7SetNodeForce3', uID, Nodes(ii), LoadCase, Force);
    HandleError(iErr);
end