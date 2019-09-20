function pairedCoord = PairCoord(N1, N2)
% Outputs index from N1 that are found in N2
% N1 and N2 are structures with the following:
% N.x - xcoord
% N.y - ycoord
%% Pair Nodes
% Calculate closest nodes
pairedCoord = zeros(length(N2.x),1);
for i=1:length(N2.x)
    [~, I] = min(sqrt((N1.x-N2.x(i)).^2+(N1.y-N2.y(i)).^2));
    pairedCoord(i) = I;
end
end %PairCoord()