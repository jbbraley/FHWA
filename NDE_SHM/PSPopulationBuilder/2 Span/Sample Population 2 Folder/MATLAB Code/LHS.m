function x = LHS(lb,ub,n,p)
xn = lhsdesign(n,p);
x = bsxfun(@plus,lb,bsxfun(@times,xn,(ub-lb)));