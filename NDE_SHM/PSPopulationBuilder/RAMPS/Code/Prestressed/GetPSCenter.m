function [ PSCenter ] = GetPSCenter( Parameters, NumStrands )
%GETPSCENTER finds centroid of prestressing strands
%   Parameters  -   Parameters stucture
%   NumStrands  -   double: number of prestressing strands used in section
%
%   jbb     -   7/21/14
%
%   end

VertSpacing = 2; % 2 inch
BottomCover = 2; % 2 inch
AASHTOrows = ones(6,35)*2;
AASHTOrows(:,1:9) = [6 6 4 2 2 2 2 2 2; 8 8 6 4 2 2 2 2 2; 10 10 10 8 6 4 2 2 2; 12 12 12 10 8 6 4 2 2; 12 12 12 12 10 8 6 4 2; 12 12 12 12 10 8 6 4 2];
BTrows = ones(1,35)*2;
BTrows(1:5) = [12 12 8 4 2];

switch Parameters.Beam.Type
    case 'AASHTO'
        type = str2double(Parameters.Beam.Name(7));
        for ii=1:size(AASHTOrows,2)
            rows(ii) = sum(AASHTOrows(type,1:ii),2);
        end
        NumRows = find((rows-NumStrands)>=0,1,'first');
        NumLastRow = NumStrands-sum(AASHTOrows(type,1:NumRows-1));
        PSCenter = sum([AASHTOrows(type,1:NumRows-1) NumLastRow].*([0:NumRows-1]*VertSpacing+BottomCover))/NumStrands;
    case 'BulbTee'
        for ii=1:length(BTrows)
            rows(ii) = sum(BTrows(1:ii),2);
        end
        NumRows = find((rows-NumStrands)>=0,1,'first');
        NumLastRow = NumStrands-sum(BTrows(1:NumRows-1));
        PSCenter = sum([BTrows(1:NumRows-1) NumLastRow].*([0:NumRows-1]*VertSpacing+BottomCover))/NumStrands;
end

end

