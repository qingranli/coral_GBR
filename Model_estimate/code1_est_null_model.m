%% Estimate the null model: LS with constraints

% OLS ===========================================================%
lm0 = fitlm(fishDT,'y ~ x3 + x4','Exclude',1:N);
theta = lm0.Coefficients.Estimate;
r0 = -2*theta(2)/(2+theta(2));
q0 = -(2+r0)*theta(3);
K0 = exp(theta(1)*(2+r0)/(2*r0))/q0;
OLSest0 = [r0;q0;K0];
RSS0 = lm0.SSE; % sum of squared errors

if all(OLSest0>0)==true
    model = "null"; method = "OLS";
    fprintf('\n --- Null Model (OLS estimates) --- \n')
    fprintf('r0 = %.4g, q0 = %.4g, K0 = %.4g \n',r0,q0,K0)
    fprintf('Residual Sum of Squares = %.4f\n',RSS0)
else
    fprintf('Need to add constraints to LS estimation...\n')
    model = "null"; method = "LScon";

% LS with constraints ===========================================%
est0 = max(0,OLSest0); %initialization
LB = zeros(3,1); UB = []; %lower and upper bounds
myoption = optimset('Display','off','MaxFunEvals',1e+8,...
    'TolX',1e-8,'MaxIter',1e+5);
y = fishDT.y(keepID); 
x3 = fishDT.x3(keepID); x4 = fishDT.x4(keepID);
tic
fvalmin = 9999; rng("default")
for i = 1:100
    % global search: fmincon (100 iterations)
    gs = GlobalSearch;
    func = @(estX)y_dist0(estX,y,x3,x4);
    problem = createOptimProblem('fmincon','x0',est0,...
        'objective',func,'lb',LB,'ub',UB,'options',myoption);    
    [est, fval] = run(gs,problem); %solve problem
    if fval < fvalmin % update result with min fval
        fvalmin = fval;
        r0 = est(1); q0 = est(2); K0 = est(3);
        RSS0 = fval;
    end
    disp(i)
end
toc
fprintf('\n --- Null Model (LS estimates) --- \n')
fprintf('r0 = %.4g, q0 = %.4g, K0 = %.4g \n',r0,q0,K0)
fprintf('Residual Sum of Squares = %.4f\n',RSS0)
end