function AddSubfolders(dir)
%ADDSUBFOLDERS adds all the folders and subfolders within 'dir' to the path
if isempty(dir)
    dir  = cd;
end
addpath(genpath(dir))
end

