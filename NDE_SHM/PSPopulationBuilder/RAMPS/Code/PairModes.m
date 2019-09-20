function meshData = PairModes(Options, meshData, rePair) 
%%%%%%% Don't Enforce Mode Order %%%%%%
numCorrMode = length(Options.Correlation.expModes);
numAnaMode = size(meshData.freq,1);
corrMode = Options.Correlation.expModes;
MAC = meshData.MAC;
C = zeros(numCorrMode,1);
I = zeros(numCorrMode,2);
I(:,1) = Options.Correlation.expModes;
MACsearchindex=1:numAnaMode;

if rePair 
    for i=1:numCorrMode
        % Find index of max MAC value for current experimental frequency
        % Use this to pair exp to analytical frequency
        [~,ind] = max(MAC(corrMode(i),MACsearchindex),[],2);
        I(i,2) = MACsearchindex(ind);
        C(i) = MAC(corrMode(i),MACsearchindex(ind));
        % Subtract out analytical mode vector from MAC search index so it cannot be
        % paired with any other experimental mode
        MACsearchindex(ind)=[];
    end
    
    meshData.pairedModes = I;
else
    IND = sub2ind(size(MAC),meshData.pairedModes(:,1),meshData.pairedModes(:,2));
    C = MAC(IND); 
end

meshData.pairedMAC = C;