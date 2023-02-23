function rss = y_dist1(est,y,x2,x3,x4)
%%%%%%%%%% Alternative Model (Least-Sqaured Errors)
% est0 = [r; q; beta; gamma]
r = est(1);
q = est(2);
beta = est(3);
gamma = est(4);

% fitted y
yhat = 2*r/(2+r)*log(q*beta)+r*gamma/(2+r)*x2- 2*r/(2+r)*x3 - q/(2+r)*x4;
% residual sum of squares
rss = (y-yhat)'*(y-yhat);
end