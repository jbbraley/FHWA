function St7ApplyNodeMoment(uID, LoadCase, Nodes, Moment)
%ST7APPLYNODEMOMENT      Applies point force to specified nodes in a St7 model
%   uID     -   Numeric identifier of open St7 file
%   Nodes   -   Array of all nodes to which the force is to be applied
%   Moment   -   Vector of moments about the global principle directions ([X, Y, Z])
%
%   Created 7/15/14
%                   John Braley
%
for ii = 1:length(Nodes)
    iErr = calllib('St7API', 'St7SetNodeMoment3', uID, Nodes(ii), LoadCase, Moment);
    HandleError(iErr);
end