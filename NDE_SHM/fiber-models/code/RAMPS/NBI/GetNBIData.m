function NBI = GetNBIData(NBI_data, StructureNo)

MetricToImp = 3.280839/10;

%% Find unique structure number identifiers
if isempty(StructureNo)
    StructureNo = NBI_data{1,2}(:);
    for i=2:19
        StructureNo = [StructureNo; NBI_data{i,2}(:)];
    end
    Structure = unique(StructureNo);
    first = zeros(size(Structure,1),1);
else
    Structure = StructureNo;
    first = 0;
end

%% Get Data From NBI Database
for j=1:size(Structure,1)
    for i=1:19
        [rn,cn] = find(strcmp(Structure(j),NBI_data{i,2}),1,'first');
        if isempty(cn)
            % Ratings
            NBI(j).DeckCond{i} = [];
            NBI(j).SuperstructureCond{i} = [];
            NBI(j).OperatingRating{i} = [];
            NBI(j).InventoryRating{i} = [];
            NBI(j).StructuralEval{i} = [];
            NBI(j).PostingEval{i} = [];
          
            % ADT
            NBI(j).ADT{i} = [];
            NBI(j).ADTT{i} = [];
            NBI(j).FuncClass{i}=[];
        elseif ~isempty(cn)
            % Ratings
            NBI(j).DeckCond{i} = NBI_data{i,67}{cn};
            NBI(j).SuperstructureCond{i} = NBI_data{i,68}{cn};
            NBI(j).OperatingRating{i} = NBI_data{i,73}{cn};
            NBI(j).InventoryRating{i} = NBI_data{i,75}{cn};
            NBI(j).StructuralEval{i} = NBI_data{i,76}{cn};
            NBI(j).PostingEval{i} = NBI_data{i,79}{cn};
            
            % ADT
            NBI(j).ADT{i} = NBI_data{i,30}{cn};
            NBI(j).ADTT{i} = NBI_data{i,111}{cn};
            NBI(j).FuncClass{i}=NBI_data{i,26}{cn};
            
            if first(j)==0;
                first(j)=1;
                NBI(j).StructureNumber(1,:) =  NBI_data{i,2}{1,cn};

                % Ratings
                NBI(j).DesignLoad(1) = NBI_data{i,32}{cn};
                NBI(j).OprRateMethod(1) = NBI_data{i,72}{cn};
                NBI(j).OprRating(1) = NBI_data{i,73}{cn};
                NBI(j).InvRateMethod(1) = NBI_data{i,74}{cn};
                NBI(j).InvRating(1) = NBI_data{i,75}{cn};
                
                % Year Built
                NBI(j).YearBuilt(1) = NBI_data{i,27}{cn};
                
                % Year Reconstructed
                NBI(j).YearReconstr(1) = NBI_data{i,106}{cn};
                
                % Skew 34 (35th column)
                NBI(j).Skew(1) = NBI_data{i,35}{cn};
                
                % Length 48 (column 55)
                NBI(j).MaxSpanLength(1) = round(NBI_data{i,55}{cn}*MetricToImp*12/3)*3;
                % Total Length 49 (column 56)
                NBI(j).TotalLength(1) = round(NBI_data{i,56}{cn}*MetricToImp*12/3)*3;
                % Main Unit Spans 45 (column 45)
                NBI(j).NumSpans(1) = NBI_data{i,52}{cn};
                
                % Left Sidewalk 50A (57)
                NBI(j).Sidewalk.Left(1) = round(NBI_data{i,57}{cn}*MetricToImp*12/3)*3;
                
                % Right Sidewalk 50B (58)
                NBI(j).Sidewalk.Right(1) = round(NBI_data{i,58}{cn}*MetricToImp*12/3)*3;
                
                % Roadway Width - Curb-to-Curb 51 (59)
                NBI(j).RoadWidth(1) = round(NBI_data{i,59}{cn}*MetricToImp*12/3)*3;
                
                % Deck Width - Out-to-Out 52 (60)
                NBI(j).Width(1) = round(NBI_data{i,60}{cn}*MetricToImp*12/3)*3;
            end
        end
    end
end
end %GetNBI()