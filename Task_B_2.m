%% Variable Naming Convention 
% CP---> Combined population
% sp---> survived population


%% clearing the workspace and clearing the command window
clear 
clc
%% Data for Preferability
Task_A_1


%% Loading the Sampling plan for initialisation

% P=struct2array(load("more_random_population.mat"));
Task_A_1;
P=X_sobol;

Convergence_data=[];
%% Initialising the population 
goal_vector_1=[0.7 -inf -inf -inf -inf -inf -inf -inf -inf];
goal_vector_2=[0.7 6 50 -inf -inf -inf -inf -inf -inf];
goal_vector_3=[0.7 6 50 2 10 10 8 20 1];
priority_vector_1=[1 0 0 0 0 0 0 0 0];
priority_vector_2=[2 1 1 0 0 0 0 0 0];
priority_vector_3=[3 2 2 1 0 1 0 0 1];
 for iteration=1:150

Z=optimizeControlSystem(P);
P=[];
% Creating a new array of selected values of kp & ki after optimization 
P(:,1:2)=Z(:,10:11);
% seperating the optimized values from the kp and ki values
Z=Z(:,1:9);



%% Assigning goal_vector and Priority_vector before further processing

if iteration<150 
    goal_vector=goal_vector_1;
    priority_vector=priority_vector_1;
% if iteration<50
%     goal_vector=goal_vector_2;
%     priority_vector=priority_vector_2;
% if iteration<150
%     goal_vector=goal_vector_3;
%     priority_vector=priority_vector_3;
end 

%% Calculating fitness

% Non-dominated sorting
rank=rank_prf(Z,goal_vector,priority_vector);

% Crowding Distance 
distance=crowding(Z,rank);


% Getting the fitness value 
maximum=max(rank);
fitness=maximum-rank(:,1);

%% Performing selection-for-variation
selected=btwr(fitness);
selected=unique(selected);

%% Perform Variation 

% creating an array called parent of selected parameters
len=length(selected);
for i=1:len
    a=selected(i);
    if a>length(P)
        continue
    end
    parents(i,1)=P(a,1);
    parents(i,2)=P(a,2);
end

% creating bounds for inputting to different variation operator
kp_min=min(parents(:,1));
kp_max=max(parents(:,1));
ki_min=min(parents(:,2));
ki_max=max(parents(:,2));
bounds=[kp_min,ki_min;kp_max,ki_max];

% Simulated Binary Crossover
children_sbx=sbx(parents,bounds);

% polynomial mutation
children_polymut=polymut(parents,bounds);

%% performing selection-for-survival

%concatinating the two populations i.e. parent and children population
cp=cat(1,parents,children_sbx,children_polymut);

% Evaluating results for the population 
cp_Z=optimizeControlSystem(cp);
cp=[];
cp=cp_Z(:,10:11);
cp_Z=cp_Z(:,1:9);

%finding the rank of combined population 
rank_of_cp=rank_prf(cp_Z,goal_vector,priority_vector);;

% finding the fitness of combined pipulation
max_rank_cp=max(rank_of_cp);
fitness_of_cp=max_rank_cp-rank_of_cp(:,1);

% crowding/distance for use in reducerNSGA_II operator
distance_cp=crowding(cp_Z,rank_of_cp);

% selection for survival operator
indices_sp =reducerNSGA_II(cp,rank_of_cp,distance_cp);

l=length(indices_sp);
for i=1:l
    b=indices_sp(i,1);
    Convergence_set(i,:)=cp_Z(b,:);
    passing_parameters(i,:)=cp(b,:);
end


convergence=Hypervolume_MEX(Convergence_set)
P=[];
P=passing_parameters;
sprintf('iteration %d', iteration)
Convergence_data(iteration,1)=convergence;
if convergence==0
    break
end

 end
test_parameters=mean(passing_parameters)
result=evaluateControlSystem(test_parameters)
plot(Convergence_data)
title('convergence curve for NSGA-II Optimizer')