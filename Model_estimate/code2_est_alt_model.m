% OLS ===============================================================%
lm1 = fitlm(fishDT,'y ~ x2 + x3 + x4','Exclude',1:N);
eta = lm1.Coefficients.Estimate;
r = -2*eta(3)/(2+eta(3));
q = -(2+r)*eta(4);
beta = exp(eta(1)*(2+r)/(2*r))/q;
gamma = eta(2)*(2+r)/r;
OLSest1 = [r;q;beta;gamma];
RSS1 = lm1.SSE; % sum of squared errors

if all(OLSest1>0)==true
    model = "alt"; method = "OLS";
    fprintf('\n --- Alternative Model (OLS estimates) --- \n')
    fprintf('r =%.4g, q =%.4g, beta =%.4g, gamma =%.4g \n',r,q,beta,gamma)
    fprintf('Residual Sum of Squares = %.4f\n',RSS1)
else
    fprintf('Need to add constraints to LS estimation...\n')
    model = "alt"; method = "LScon";
    % LS with constraints ===========================================%
    fval = 9999; rng("default")
    while(fval - RSS0 > 1e-5) % re-estimate until RSS <= RSS0
        est0 = [r0; q0; K0; 0.0001*rand()]; %initialization
        LB = zeros(4,1); UB = []; %lower and upper bounds
        myoption = optimset('Display','none','MaxFunEvals',1e+8,...
            'TolX',1e-8,'MaxIter',1e+5);
        y = fishDT.y(keepID); x2 = fishDT.x2(keepID);
        x3 = fishDT.x3(keepID); x4 = fishDT.x4(keepID);
        % global search: fmincon
        gs = GlobalSearch;
        func = @(estX)y_dist1(estX,y,x2,x3,x4);
        problem = createOptimProblem('fmincon','x0',est0,...
            'objective',func,'lb',LB,'ub',UB,'options',myoption);
        
        [est, fval] = run(gs,problem); %solve problem
    end
    r = est(1); q = est(2); beta = est(3); gamma = est(4);
    RSS1 = fval;
    
    fprintf('\n --- Alternative Model (LS estimates) --- \n')
    fprintf('r =%.4g, q =%.4g, beta =%.4g, gamma =%.4g \n',r,q,beta,gamma)
    fprintf('Residual Sum of Squares = %.4f\n',RSS1)
end
