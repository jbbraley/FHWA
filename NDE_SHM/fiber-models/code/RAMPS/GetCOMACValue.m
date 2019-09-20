function cm = GetCOMACValue(u1, u2)
% Syntax: cm = GetCOMACValue(u1, u2)
% 
% getcomac.m computes comac values for two modal arrays, u1 & u2.
% Complex mode check included to ensure correct comac values corresponding 
% to real/complex modes.
%
% Input: 
%       u1 - modal vector/array 1 [n x m]
%       u2 - modal vector/array 2 [n x m]
% 
% Output: 
%       cm - coMAC value array [n x 1]
% =========================================================================

% set up vars
[n, m] = size(u1);

if isempty(u2)
    u2 = u1;
end
[nn, mm] = size(u2);

cm = zeros(n,1);

% error screen arrays
if mm ~= m || nn ~= n
    error('Error: Modal vectors not consistent. Try again.');
end

% compute coMac
for ii = 1:n
    % get valid (non NaN) modes for each node and only compare
    % those
    ind = nonzeros([1:size(u1,2)].*~isnan(u1(ii,:)).*~isnan(u2(ii,:)));
    
    a = u1(ii,ind).*u2(ii,ind);
    b = u1(ii,ind).*conj(u1(ii,ind));
    c = u2(ii,ind).*conj(u2(ii,ind));
    
    cm(ii,:) = sum(a.^2)/(sum(b)*sum(c));
    
end
end