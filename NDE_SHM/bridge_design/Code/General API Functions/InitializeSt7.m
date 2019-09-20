function InitializeSt7(printOption)

St7APIConst();

% Load the api of not already loaded
if printOption
    fprintf('Loading ST7API.DLL... ');
end

if ~libisloaded('St7API')
    loadlibrary('St7API.dll', 'St7APICall.h');
    iErr = calllib('St7API', 'St7Init');
    HandleError(iErr);
end

if printOption
    fprintf('Done \n');
end


end