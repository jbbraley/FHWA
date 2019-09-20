function SetBeamStiffness(propList,Stiffness,Parameters, uID)

% Get Material Property Data for each entity of inerest
for ii = 1:length(propList)  
    mData(ii,:) = Parameters.St7Prop(propList(ii)+2).MatData;
end

switch Stiffness
    case 'On'
        St7SetMaterialData(uID, propList, mData);
    case 'Off'
        mData(:,1) = 5;
        St7SetMaterialData(uID, propList, mData);
    case 'Rigid'
%         mData(:,1) = 290000000000;
        mData(:,1) = 290000000000000000;
        St7SetMaterialData(uID, propList, mData);
end

end