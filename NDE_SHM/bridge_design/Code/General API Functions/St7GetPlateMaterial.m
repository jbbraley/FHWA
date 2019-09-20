function [ DoublesPl ] = St7GetPlateMaterial( uID, PropNum )

DoublesPl = zeros(1,8);
[iErr, DoublesPl] = calllib('St7API', 'St7GetPlateIsotropicMaterial', uID, PropNum, DoublesPl);
HandleError(iErr);
end

