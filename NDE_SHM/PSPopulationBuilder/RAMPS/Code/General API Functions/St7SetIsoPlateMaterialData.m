function St7SetIsoPlateMaterialData(uID, propList, mData)
% Sets material properties. 
% propList is list of N properties to be changed
% mData is Nx8 array for material data

for i=1:length(propList)
    Doubles = mData(i,:);
    iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, propList(i), Doubles);
    HandleError(iErr);
end

end %St7SetMaterialData()