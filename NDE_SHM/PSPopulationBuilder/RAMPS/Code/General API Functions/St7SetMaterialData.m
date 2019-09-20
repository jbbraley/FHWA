function St7SetMaterialData(uID, propList, mData)
% Sets material properties. 
% propList is list of N properties to be changed
% mData is Nx9 array for material data

for i=1:length(propList)
    Doubles = mData(i,:);
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, propList(i), Doubles);
    HandleError(iErr);
end

end %St7SetMaterialData()