function [ new_cont ] = AddNotString(h, string, content)
%ADDNOTSTRING Adds additional string message to notification box

% h - notification box handle
% string - cell array containing new content in string form
% content - previous content in notification box

% new_cont - totla content in notification box after being updated

new_cont = [content string];
set(h, 'string', new_cont);
set(h, 'Value', length(new_cont));
drawnow


end

