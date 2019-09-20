function m = GetMACValue(u1, u2)
% u2 must be of the same length or longer than u1 !!!

% Checks is first modal set is only one being checked
if isempty(u2)
    u2 = u1;
end

% preallocate MAC
m = zeros(size(u1,2), size(u2,2));

% Sizes of u1 and u2
n1 = size(u1,2);
n2 = size(u2,2);

% error screen
if isreal(u1) && isreal(u2)
   % compute mac for real arrays
   for ii=1:n1
       for jj=1:n2
           % get valid (non NaN) nodes for each shape and only compare
           % those
           ind = nonzeros([1:size(u1,1)]'.*~isnan(u1(:,ii)).*~isnan(u2(:,jj)));
           m(ii,jj)=(u1(ind,ii)'*u2(ind,jj))^2/...
                    ((u2(ind,jj)'*u2(ind,jj))*(u1(ind,ii)'*u1(ind,ii)));
       end
   end
else
   % compute mac for complex arrays
   for ii=1:n1
       for jj=1:n2
           m(ii,jj)=(u1(:,ii)'*conj(u2(:,jj)))^2/...
                    ((u2(:,jj)'*conj(u2(:,jj)))*(u1(:,ii)'*conj(u1(:,ii))));
       end
   end
end

end
