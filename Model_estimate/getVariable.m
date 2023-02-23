function fishDT_new = getVariable(fishDT,reefDT)
% generate variables for the null and alternative models
fishDT.Et0 = (1e-4)*fishDT.Days; % rescale Days to (10,000 days)
fishDT.Etlag1 = [NaN; fishDT.Et0(1:end-1)];
fishDT.Ut0 = fishDT.CPUE; % catch (tonnes) per day
fishDT.Utlag1 = [NaN; fishDT.Ut0(1:end-1)];

reefDT.at0 = reefDT.COVER_live;
reefDT.atlag1 = [NaN; reefDT.at0(1:end-1)];

fishDT.y = log(fishDT.Ut0) - log(fishDT.Utlag1);
fishDT.x2 = log(reefDT.atlag1) + log(reefDT.at0);
fishDT.x3 = log(fishDT.Utlag1);
fishDT.x4 = fishDT.Et0 + fishDT.Etlag1; 

fishDT_new = fishDT;
fprintf('Variables generated ... continue\n')
end