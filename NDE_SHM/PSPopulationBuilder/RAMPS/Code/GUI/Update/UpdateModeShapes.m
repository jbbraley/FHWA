function UpdateModeShapes(handles)
% get names of current objects
availNames = fieldnames(handles);

% Repopulate experimental mode shape plot
if ismember(availNames, 'axesExpModeShape');
    testData = getappdata(0,'expMeshData');
    if ~isempty(testData)
        axes(handles.axesExpModeShape);
        scatter3(testData.x,testData.y,testData.U);
    end
end

% Repopulate analytical mode shape plot
if ismember(availNames, 'axesAnaModeShape');
    meshData = getappdata(0,'anaMeshData');
    if ~isempty(meshData)
        axes(handles.axesExpModeShape);
        scatter3(testData.x,testData.y,testData.U);
    end  
end
end