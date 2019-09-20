function [ PSResults ] = PSForceResults( Parameters, Options, ModelPath, ModelName )
%PSRESULTS Opens P/S force result file and gathers responses
%   Result File is opened
%   Beam numbers corresponding to midspan location are found
%   Stress and Force are obtained and saved in PSResults data structure
%
%   Inputs:
%       Parameters  -   Structure containing meta data
%       Options     -   Structure containing modelling meta data
%       ModelPath   -   String defining the location of the St7 model file
%       ModelName   -   String defining the name of the St7 model file (without '.st7' extension)
%   Outputs:
%       PSResults   -   Structure containing recorded stress and member action responses
%                       PSResults.Str: vector of length = 18; Str(2) = Total Fiber Stress
%                       PSResults.Force: vector of length = 6; Force(2) = BM-axis1; Force(4) = BM-axis2; Force(5) = Axial
%
%   Example:
%       PSForceResults(Parameters, Option, 'C:\Documents\Models\', 'SampleModel')
%
%   Created 7/15/14
%               John Braley
%

global tyBEAM rtBeamStress rtBeamForce stBeamLocal 

%% Open Result File
uID = Options.St7.uID;
ResultCase = 1;
PSResultPath = [ModelPath ModelName '_PSF.lsa'];

St7OpenResultFile(uID, PSResultPath);

%% Pull Responses
for ii= 1:Parameters.Spans
    span = ii;
    
    % Determine order of node columns corresponding to girders
    y1 = find(any(Node(span).ID(:,:,3)),1,'first');
    y2 = find(any(Node(span).ID(:,:,3)),1,'last');
    y = (y2-y1)/(Parameters.NumGirder-1); 
    
    for jj=1:Parameters.NumGirder
        NumColumns = 18;
        BeamRes = zeros(NumColumns,1);
        BeamF = zeros(6,1);

        row = y1 + (jj-1)*y;
        x1 = find(Node(span).ID(:,row,3),1,'first');
        x2 = find(Node(span).ID(:,row,3),1,'last');

        cl = x1 + floor((x2-x1)/2);

        midspan = Node(span).ID(cl,row,3);
        BeamNum = Node(span).ElementCon(midspan,1);

        EltData = 0;
        [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
        HandleError(iErr);

        if rem(x2-x1,2) ~= 0 % Even number of nodes.  Get results at middle of element
            BeamPos = EltData/2;
            [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
            HandleError(iErr);

            [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
            HandleError(iErr);

        else % Odd number of nodes.  Get Results at end of element
            BeamPos = 0;
            [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
            HandleError(iErr);

             [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
            HandleError(iErr);
        end

        PSResults.Str(:,jj,span) = BeamRes;
        PSResults.Force(:,jj,span) = BeamF;
    end
end

St7CloseResultFile(uID);

% End PSResults
