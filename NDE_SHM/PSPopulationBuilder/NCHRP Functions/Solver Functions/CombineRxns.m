function TotalCombinedRxns = CombineRxns(Parameters,LLResults)

% Get results for every combination of truck and lane load for single lane

        % Obtain all possible lane combinations
        vect = 1:Parameters.Spans;
        vect = padarray(vect, [0,Parameters.Spans-1],'pre');
        LaneComb = unique(nchoosek(vect,Parameters.Spans),'rows');

        % Pre-allocate
        CombinedLaneRxns = [];
        CombinedRxns = [];
        TotalCombinedRxns = [];
        
        Trucks = size(LLResults.TruckLNodeRxn,4);

        for q = 1:size(LaneComb, 1)

            % Superposition of different lane combinations
            spans = nonzeros(LaneComb(q,:));
            CombinedLaneRxns = cat(6,CombinedLaneRxns,permute(sum(LLResults.LaneLNodeRxn(:,:,:,spans,:,:),4),[1 2 3 5 6 4]));

            % Superposition of trucks with different lane combinations
            for p = 1:Trucks
                CombinedRxns = cat(6,CombinedRxns, CombinedLaneRxns(:,:,:,:,:,q)+permute(LLResults.TruckLNodeRxn(:,:,:,p,:,:),[1 2 3 5 6 4]));
            end

        end

        % Get resutls for multiple presence combinations

        % Obtain all possible multiple presence combinations
        vect = 1:Parameters.Rating.LRFD.NumLane;
        vect = padarray(vect, [0,Parameters.Rating.LRFD.NumLane-1],'pre');
        MultiPresComb = unique(nchoosek(vect,Parameters.Rating.LRFD.NumLane),'rows');

        for q = 1:size(MultiPresComb,1)

            lanes = nonzeros(MultiPresComb(q,:));
            NumRatingLanes = length(lanes);

            % Multi-presence reduction factor
            if NumRatingLanes>3
                NumRatingLanes = 4;
            end
            redfact = Parameters.Rating.LRFD.MulPres(NumRatingLanes);

            % Superposition of multipresence combinations
            TotalCombinedRxns = cat(6,TotalCombinedRxns,permute(sum(CombinedRxns(:,:,lanes,:,:,:),3),[1 2 5 4 6 3])*redfact);
            
            

        end
end