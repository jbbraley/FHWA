function NormalizedModeShapes = NormalizeModeShapes(ModeShapes)
% Takes any mode shapes in array form where 
% Rows: Z data
% Columns: Shapes
% Returns normalize mode shape

NormalizedModeShapes = zeros(size(ModeShapes));
for i=1:size(ModeShapes,2)
    [~,ind]=max(abs(ModeShapes(:,i)));
    NormalizedModeShapes(:,i)=ModeShapes(:,i)/ModeShapes(ind,i);
end

end      % NormalizeModeShapes()