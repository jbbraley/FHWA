function St7SetNonStructuralMass(uID, nodeNum, loadCase, nsMass, dynFactor, offsetList)
% // Function Inputs ------------------------------------------------------
% uID - Model ID
% nodeNum - list of RAMPS node #s
% loadCase - single value
% nsMass - non-structural mass, vector of length of nodeList or single value
% dynFactor - dynamic factor, vector of length of nodeList or single value
% offsetList - offset in XYZ coords, Nx3 array of length of nodeNum
% // St7 API Call Inputs --------------------------------------------------
% NodeNum - St7 node number
% CaseNum - St7 load case num
% Doubles[0] - Non-structural mass at node
% Doubles[1] - Dynamic factor (used to scale non-structural mass when
% performing dynamic analysis)
% Doubles[2..4] - 3 element array describing the offset in the XYZ
% cartesian coordinate system

% Load Case
CaseNum = loadCase;

% check nsMass for length
if length(nsMass) == length(nsMass) % different NS mass for each node
    nsList = nsMass;
else
    nsList = nsMass*ones(length(nodeNum),1); % same NS mass for each
end

% Check dynFactor for length
if isempty(dynFactor) % default
    dynList = ones(length(nodeNum),1);
elseif length(dynFactor) == length(nodeNum) % different dynamic factor for each node
    dynList = dynFactor;
else
    dynList = dynFactor*ones(length(nodeNum),1); % same dynamic factor for each
end

% Check offsetList
if isempty(offsetList)
    offsetList = zeros(length(nodeNum),3);
end

for i=1:length(nodeNum)
    NodeNum = nodeNum(i);
    
    Doubles(1) = nsList(i);
    Doubles(2) = dynList(i);
    Doubles(3:5) = offsetList(i,:);
    
    iErr = calllib('St7API', 'St7SetNodeNSMass5', uID, NodeNum, CaseNum, Doubles);
    HandleError(iErr);
end

end % St7SetNonStructuralMass()