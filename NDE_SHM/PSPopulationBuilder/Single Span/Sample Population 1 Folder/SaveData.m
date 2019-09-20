for ii=1:100
    M.Numstrands(ii) = ModelSpace(ii).NumStrands;
    M.BeamD(ii) = ModelSpace(ii).BeamD;
    M.Length(ii) = ModelSpace(ii).Length;
    MSection{ii} = ModelSpace(ii).SectionName;
    M.Skew(ii) = ModelSpace(ii).Skew;
    M.GirderSpacing(ii) = ModelSpace(ii).GirderSpacing;
    M.Width(ii) = ModelSpace(ii).Width;
    M.Beamfc(ii) = ModelSpace(ii).Beamfc;
end

allTable = [(1:100); M.Length; M.Width; M.Skew; M.GirderSpacing; M.BeamD; M.Beamfc; M.Numstrands]';
dlmwrite('run1bridgedata.txt', allTable)