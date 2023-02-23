function rss = y_dist0(est,y,x3,x4)
%%%%%%%%%% Null Model (Least-Sqaured Errors)
% est0 = [r; q; K]
r = est(1);
q = est(2);
K = est(3);
% fitted y
yhat = 2*r/(2+r)*log(q*K) - 2*r/(2+r)*x3 - q/(2+r)*x4;
% residual sum of squares
rss = (y-yhat)'*(y-yhat);
end