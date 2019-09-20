function NBI = TranslateNBIData(NBI)
for i=1:size(NBI,2)
    NBI(i).LengthOption(1,:) = 'Center';
    NBI(i).WidthOption(1,:) ='Out';
    
    % NBI(i) Design
    if isnan(NBI(i).DesignLoad) || isempty(NBI(i).DesignLoad)
        NBI(i).DesignCode = 'Not Recorded';
    elseif (str2double(NBI(i).DesignLoad) >= 1 && str2double(NBI(i).DesignLoad) <= 6) || strcmp(NBI(i).DesignLoad,'9') % ASD
        NBI(i).DesignCode = 'ASD';
    elseif strcmp(NBI(i).DesignLoad, 'A') || strcmp(NBI(i).DesignLoad, 'B')
        NBI(i).DesignCode = 'LRFD';
    elseif strcmp(NBI(i).DesignLoad, 'C')
        NBI(i).DesignCode = 'Other';
    elseif strcmp(NBI(i).DesignLoad, '0')
        NBI(i).DesignCode = 'Unknown';
    else
        NBI(i).DesignCode = 'Not Recorded';
    end
    
    % Posting
    if cell2mat(NBI(i).PostingEval(end)) <= 4
        NBI(i).PostingRequired = 'Yes';
    else
        NBI(i).PostingRequired = 'No';
    end
    
    % Year Reconstructed
    if isnan(NBI(i).YearReconstr) || isempty(NBI(i).YearReconstr)
        NBI(i).Reconstructed = 'Not Recorded';
    elseif NBI(i).YearReconstr ~= 0
        NBI(i).Reconstructed = num2str(NBI(i).YearReconstr);
    else
        NBI(i).Reconstructed = 'Not Reconstructed';
    end
    
    % Truck Loads
    NBI(i).DesignTruckName = [];
    NBI(i).AltMilitaryLoad = [];
    NBI(i).Load = [];
    NBI(i).LaneLoad = [];
    NBI(i).Tandem = [];
    NBI(i) = GetTruckLoads(NBI(i));
    
    % Rating Methods
    % Operating Rating
    if isnan(NBI(i).OprRateMethod) || isempty(NBI(i).OprRateMethod)
        NBI(i).OpRatingMethod = 'Not Recorded';
        NBI(i).OprRating = 'Not Recorded';
    elseif NBI(i).OprRateMethod == 0
        NBI(i).OpRatingMethod = 'Field eval. + eng. judgement';
    elseif NBI(i).OprRateMethod == 1
        NBI(i).OpRatingMethod = 'Load Factor';
        NBI(i).OprRating = NBI(i).OprRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).OprRateMethod == 2
        NBI(i).OpRatingMethod = 'Allowable Stress';
        NBI(i).OprRating = NBI(i).OprRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).OprRateMethod == 3
        NBI(i).OpRatingMethod = 'Load and Resistance Factor';
        NBI(i).OprRating = NBI(i).OprRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).OprRateMethod == 4
        NBI(i).OpRatingMethod = 'Load Testing';
        NBI(i).OprRating = NBI(i).OprRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).OprRateMethod == 5
        NBI(i).OpRatingMethod = 'No Rating Performed';
        NBI(i).OprRating = 'Not Recorded';
    elseif NBI(i).OprRateMethod == 6
        NBI(i).OpRatingMethod = 'Load Factor';
    elseif NBI(i).OprRateMethod == 7
        NBI(i).OpRatingMethod = 'Allowable Stress';
    elseif NBI(i).OprRateMethod == 8
        NBI(i).OpRatingMethod = 'Load and Resistance Factor';
    else
        NBI(i).OpRatingMethod = 'Not Recorded';
        NBI(i).OprRating = 'Not Recorded';
    end
    
    % INventory Rating
    if isnan(NBI(i).InvRateMethod) || isempty(NBI(i).InvRateMethod)
        NBI(i).InvRatingMethod = 'Not Recorded';
        NBI(i).InvRating = 'Not Recorded';
    elseif NBI(i).OprRateMethod == 0
        NBI(i).InvRatingMethod = 'Field eval. + eng. judgement';
    elseif NBI(i).InvRateMethod == 1
        NBI(i).InvRatingMethod = 'Load Factor';
        NBI(i).InvRating = NBI(i).InvRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).InvRateMethod == 2
        NBI(i).InvRatingMethod = 'Allowable Stress';
        NBI(i).InvRating = NBI(i).InvRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).InvRateMethod == 3
        NBI(i).InvRatingMethod = 'Load and Resistance Factor';
        NBI(i).InvRating = NBI(i).InvRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).InvRateMethod == 4
        NBI(i).InvRatingMethod = 'Load Testing';
        NBI(i).InvRating = NBI(i).InvRating/10/32.4; % MS18 truck load - convert weight to ratio
    elseif NBI(i).InvRateMethod == 5
        NBI(i).InvRatingMethod = 'No Rating Performed';
        NBI(i).InvRating = 'Not Recorded';
    elseif NBI(i).InvRateMethod == 6
        NBI(i).InvRatingMethod = 'Load Factor';
    elseif NBI(i).InvRateMethod == 7
        NBI(i).InvRatingMethod = 'Allowable Stress';
    elseif NBI(i).InvRateMethod == 8
        NBI(i).InvRatingMethod = 'Load and Resistance Factor';
    else
        NBI(i).InvRatingMethod = 'Not Recorded';
        NBI(i).InvRating = 'Not Recorded';
    end
end
end
