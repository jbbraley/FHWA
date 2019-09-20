function [ DoublesBm ] = St7GetBeamMaterialData(uID, PropNum)
%ST7GETBEAMMATERIALDATA Pulls material properties for specified property (must be beam
%property)
%   DoublesBm - contains all the material data for the specified beam property
DoublesBm = zeros(1,9);
[iErr, DoublesBm] = calllib('St7API', 'St7GetBeamMaterialData', uID, PropNum, DoublesBm);
if iErr==17
    fprintf('Beam property %d does not exist in model and was ignored\n',PropNum)
    return
end
HandleError(iErr);

end

