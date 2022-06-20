clear
clc

%% Full Factorial Design 

X_fullfact=fullfactorial([50,2],2); % points at centre 

%% Latin Hyper Cube Design 
X_rlh=rlh(100,2,1);
X_rlh=sortrows(X_rlh);


%% Latin Hyper Cube using Inbuilt Matlab Function 

X_lhsdesign=lhsdesign(100,2);
X_lhsdesign=sortrows(X_lhsdesign);

%% Sobol Sampling 

p=sobolset(2);
X_sobol=net(p,101);
X_sobol=sortrows(X_sobol);
X_sobol=X_sobol(2:end,:)

%% Evaluatig Different Sampling plans 

phi_fullfactorial=mmphi(X_fullfact,10,2);
phi_rlh=mmphi(X_rlh,5,2);
phi_lhsdesign=mmphi(X_lhsdesign,5,2);
phi_sobol=mmphi(X_sobol,5,2);

%% Creating a table for phi_Q value of Different sampling plan

