function  St7BeamRelease( uID, BmNums, BmEnds, Status , Type)
global kBeamEndRelReleased kBeamEndRelFixed kBeamEndRelPartial
%ST7BEAMRELEASE Releases moment or translation of beam ends
% uID - file identifier
% BmNums - vector containing all beam numbers that are to be released
% BmEnds - vector or scalar with values of 1 or 2 specifying which beam end is to be released
% Status - string specifying the status: released, fixed, or partial
% Type - specifies the type of release that is to be placed on the beams: rot, or trans

%% handle inputs
if isempty(uID)
    uID = 1;
end
if isempty(BmEnds)
    BmEnds = 1;
end

if length(BmEnds)==1
    BmEnds = ones(length(BmNums),1)*BmEnds;
end
if isempty(Status)
    Status = 'released';
end

for ii = 1:length(BmNums)
    BmNum = BmNums(ii);
    BmEnd = BmEnds(ii);
    Dbls = zeros(3,1);
    switch Status
        case {'released', 'release'}
            switch Type
                case {'r', 'rot', 'rotate', 'rotational'}
                    iErr = calllib('St7API', 'St7SetBeamRRelease3', uID, BmNum, BmEnd, [kBeamEndRelReleased kBeamEndRelReleased kBeamEndRelReleased], Dbls);
                    HandleError(iErr);
                case {'t', 'trans', 'translate', 'translational'}
                    iErr = calllib('St7API', 'St7SetBeamTRelease3', uID, BmNum, BmEnd, [kBeamEndRelReleased kBeamEndRelReleased kBeamEndRelReleased], Dbls);
                    HandleError(iErr);
                otherwise
                    return
            end
        case {'fixed', 'fix'}
            switch Type
                case {'r', 'rot', 'rotate', 'rotational'}
                    iErr = calllib('St7API', 'St7SetBeamRRelease3', uID, BmNum, BmEnd, [kBeamEndRelFixed kBeamEndRelFixed kBeamEndRelFixed], Dbls);
                    HandleError(iErr);
                case {'t', 'trans', 'translate', 'translational'}
                    iErr = calllib('St7API', 'St7SetBeamTRelease3', uID, BmNum, BmEnd, [kBeamEndRelFixed kBeamEndRelFixed kBeamEndRelFixed], Dbls);
                    HandleError(iErr);
                otherwise
                    return
            end
        case 'partial'
            switch Type
                case {'r', 'rot', 'rotate', 'rotational'}
                    iErr = calllib('St7API', 'St7SetBeamRRelease3', uID, BmNum, BmEnd, [kBeamEndRelPartial kBeamEndRelPartial kBeamEndRelPartial], Dbls);
                    HandleError(iErr);
                case {'t', 'trans', 'translate', 'translational'}
                    iErr = calllib('St7API', 'St7SetBeamTRelease3', uID, BmNum, BmEnd, [kBeamEndRelPartial kBeamEndRelPartial kBeamEndRelPartial], Dbls);
                    HandleError(iErr);
                otherwise
                    return
            end
        otherwise
            return
    end
end

