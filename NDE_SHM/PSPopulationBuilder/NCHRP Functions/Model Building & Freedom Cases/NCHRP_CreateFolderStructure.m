% NCHRP_CreateFolderStructure(Spans,structureType,suiteNo)

spans = 3;
structureType = 'Pre-Stressed';
suiteNo = 1;

% Prompt user for main file directory
directory = uigetdir;

% Create main directory ---------------------------------------------------
main = [directory '\' structureType '\' num2str(spans) '-Span' '\Suite ' num2str(suiteNo)];
mkdir(main);

% Create Sub-directories --------------------------------------------------

% Extracted Result Files
% Dead Load
mkdir([main '\Extracted Result Files\Dead Load'])
% Live Load
mkdir([main '\Extracted Result Files\Live Load'])
% Rotational Settlement
mkdir([main '\Extracted Result Files\Rotational Settlement'])
% Vertical Settlement
mkdir([main '\Extracted Result Files\Vertical Settlement'])

% MATLAB Functions
mkdir([main '\MATLAB Functions'])

% Model Back-Up
mkdir([main '\Model Back-Up'])

% Model Files
mkdir([main '\Model Files'])

% TS Results
mkdir([main '\TS Results'])

% Dead Load
mkdir([main '\Extracted Result Files\Dead Load\A1'])
mkdir([main '\Extracted Result Files\Dead Load\A2'])
mkdir([main '\Extracted Result Files\Dead Load\P1'])
mkdir([main '\Extracted Result Files\Dead Load\P2'])
mkdir([main '\Extracted Result Files\Dead Load\A1-F'])
mkdir([main '\Extracted Result Files\Dead Load\A2-F'])
mkdir([main '\Extracted Result Files\Dead Load\P1-F'])
mkdir([main '\Extracted Result Files\Dead Load\P2-F'])

% Live Load
mkdir([main '\Extracted Result Files\Live Load\A1\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\A1\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\A2\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\A2\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\P1\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\P1\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\P2\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\P2\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\A1-F\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\A1-F\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\A2-F\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\A2-F\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\P1-F\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\P1-F\Barriers Off'])
mkdir([main '\Extracted Result Files\Live Load\P2-F\Barriers On'])
mkdir([main '\Extracted Result Files\Live Load\P2-F\Barriers Off'])

% Rotational Settlement
mkdir([main '\Extracted Result Files\Rotational Settlement\A1\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A1\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A1-F\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A1-F\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2-F\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2-F\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1-F\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1-F\Barriers Off\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2-F\Barriers On\Positive'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2-F\Barriers Off\Positive'])

mkdir([main '\Extracted Result Files\Rotational Settlement\A1\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A1\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A1-F\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A1-F\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2-F\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\A2-F\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1-F\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P1-F\Barriers Off\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2-F\Barriers On\Negative'])
mkdir([main '\Extracted Result Files\Rotational Settlement\P2-F\Barriers Off\Negative'])

% Vertical Settlement
mkdir([main '\Extracted Result Files\Vertical Settlement\A1\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A1\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A2\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A2\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P1\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P1\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P2\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P2\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A1-F\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A1-F\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A2-F\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\A2-F\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P1-F\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P1-F\Barriers Off'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P2-F\Barriers On'])
mkdir([main '\Extracted Result Files\Vertical Settlement\P2-F\Barriers Off'])









