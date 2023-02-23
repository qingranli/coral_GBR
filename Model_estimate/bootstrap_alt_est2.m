function estSave1 = bootstrap_alt_est2(fishData,r0,q0,K0,iter)
% OLS ===============================================================%
lm1 = fitlm(fishData,'yi ~ x2 + x3 + x4');
eta = lm1.Coefficients.Estimate;
r = -2*eta(3)/(2+eta(3));
q = -(2+r)*eta(4);
beta = exp(eta(1)*(2+r)/(2*r))/q;
gamma = eta(2)*(2+r)/r;
OLSest1 = [r;q;beta;gamma]; % negative gamma is bounded at 0

if all(OLSest1>0)==true
    model = "alt"; method = "OLS"; RSS1 = lm1.SSE;
else
    model = "alt"; method = "LScon";
    % LS with constraints ===========================================%
    RSS1 = 9999; rng("default")
    for m = 1:100 % try 100 estimations
        est0 = [r0; q0; K0; 0.0001*rand()]; %initialization
        LB = zeros(4,1); UB = []; %lower and upper bounds
        myoption = optimset('Display','none','MaxFunEvals',1e+5,...
            'TolX',1e-5,'MaxIter',1e+5);
        yi = fishData.yi; x2 = fishData.x2; 
        x3 = fishData.x3; x4 = fishData.x4;
        % global search: fmincon
        func = @(estX)y_dist1(estX,yi,x2,x3,x4);      
        [est, fval] = fmincon(func,est0,[],[],[],[],LB,UB,[],myoption);         
        if fval < RSS1
            RSS1 = fval;
            r = est(1); q = est(2); beta = est(3); gamma = est(4);
        end
        fprintf('[iter = %d] %d /100 ================ \n',iter,m)
    end % end for m
    
end % end if

estSave1 = table(model,method,RSS1,r,q,beta,gamma,iter);
end