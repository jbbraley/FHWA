function [FileName, PathName] = GetModelFiles(GetDir)
% Parameter file names end in '_Para.mat'
[FileName{1}, PathName{1}] = uigetfile([GetDir '*.mat'], 'Choose Parameters File');

% Load nodes file from same directory, if not found, ask for it
% node file names end in '_Nodes.mat'
fid = exist([PathName{1} FileName{1}(1:end-9) '_Node.mat'],'file');
if fid ~= 2
    [FileName{2}, PathName{2}] = uigetfile([GetDir '*.mat'], 'Choose Node File');
else
    PathName{2} = PathName{1};
    FileName{2} = [FileName{1}(1:end-9) '_Node.mat'];
end

% Load st7 file from same directory, if not found, ask for it
fid = exist([PathName{1} FileName{1}(1:end-9) '.St7'],'file');
if fid ~= 2
    [FileName{3}, PathName{3}] = uigetfile([GetDir '*.St7'], 'Choose St7 File');
else
    PathName{3} = PathName{1};
    FileName{3} = [FileName{1}(1:end-9) '.St7'];
end
end %GetModelFiles()