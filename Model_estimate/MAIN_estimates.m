%% For the selected species
close all; clear; clc;
warning('off','all')

%% import data: fish catch & effort
QFish = readtable('QFish_20Species.csv', "TextType", "string");
coral = readtable('coral_GBR_by_shelf.csv', "TextType", "string");
% list of species and bio-shelf
spList = ["Trevallies"; "Coral trout"; "Saddletail Snapper";...
    "Redthroat Emperor"; "School Mackerel"; "Grey Mackerel"; ...
    "Tropical Rock Lobster";"Spanish Mackerel"; ...
    "Western King Prawn"; "Redspot King Prawn"];
reefList = ["I"; "O"; "O"; "I"; "I"; "I"; "I"; "I"; "I"; "I"];

%% select species
sp = 1;
Name = spList(sp); reefSlf = reefList(sp);
fishDT = QFish(strcmp(QFish.Species,Name),:);
reefDT = coral(strcmp(coral.Shelf, reefSlf),:);
fprintf('\n\nFish: %s [bio-Shelf = %s]\n',Name,reefSlf)
% generate variables
fishDT = getVariable(fishDT,reefDT);
keepID = ~isnan(fishDT.x3); % remove first N rows
N = length(keepID) - sum(keepID);

%% model estimate
% Null model estimation
code1_est_null_model
estSave0 = table(Name,reefSlf,model,method,RSS0,r0,q0,K0);
% Alternative model estimation
code2_est_alt_model
estSave1 = table(Name,reefSlf,model,method,RSS1,r,q,beta,gamma);

%% Boootstrap: data generation
y = fishDT.y(keepID); x2 = fishDT.x2(keepID);
x3 = fishDT.x3(keepID); x4 = fishDT.x4(keepID);
% fitted values from null model
yhat = 2*r0/(2+r0)*log(q0*K0) - 2*r0/(2+r0)*x3 - q0/(2+r0)*x4; 
uhat = y - yhat; % residuals (null model)
Imax = 1000; % maximum iterations 
% get bootstrap values
rng("default")
uboots = zeros(length(uhat),Imax);
yboots = zeros(length(yhat),Imax);
for i = 1:Imax % bootstrapping residuals & values
    uboots(:,i) = randsample(uhat,length(uhat),true);
    yboots(:,i) = yhat + uboots(:,i);
end

%% Bootstrap: estimate alt models
fprintf('\n========= Bootstrap starts ==========\n')
bootResults = table; % save results to table (bootstrap)
for i = 1:Imax   
    % y variable for iteration i 
    yi = yboots(:,i); 
    fishData = table(yi,x2,x3,x4);    
    % Alternative Model estimation (bootstrap)
    estSave1bt = bootstrap_alt_est2(fishData,r0,q0,K0,i);    
    % save estimates to results 
    bootResults = [bootResults; estSave1bt];
end % end bootstrap iter

%% print results
fprintf('\n\n[%d] Fish = %s (Reef = %s)\n',sp,Name,reefSlf);
disp(estSave0)
disp(estSave1)

pVal = (1/size(bootResults,1))*sum(bootResults.gamma > estSave1.gamma);
fprintf('gamma = %.4f\n',estSave1.gamma);
fprintf('p value = %.4f\n', pVal);

% save results to .mat 
save(sprintf("results_%s_%s_save.mat",Name,reefSlf),...
    'bootResults', 'estSave0','estSave1','pVal')