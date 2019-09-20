function [ Stress ] = Force2Stress( M1, M2, AF, Argin)

Stress = abs(M1/Argin.S.STnc) + abs(M2/Argin.S.S2) + abs(AF/Argin.A);
end

