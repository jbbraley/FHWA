function RemoveAppData()
% Remove app data from root
try
    % Get field names from root app data to remove
    names = fieldnames(getappdata(0));
    for i=1:size(names,1)
        rmappdata(0,names{i});
    end
catch 
end
end