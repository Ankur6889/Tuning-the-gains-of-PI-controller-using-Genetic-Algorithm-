A=X_fullfact;
B=X_rlh;
C=X_lhsdesign;
D=X_sobol;

%% plotting scatter plot 

figure('Name','Scatter plot for different design');
subplot 221
plotmatrix(A(:,1),A(:,2));
title('for full factorial design')

subplot 222
plotmatrix(B(:,1),B(:,2));
title('for Latin hypercube design with provided function');

subplot 223
plotmatrix(C(:,1),C(:,2));
title('for Latin hypercube design using matlab inbuilt function');

subplot 224
plotmatrix(D(:,1),D(:,2));
title('for sobol sampling ');

%% Plotting Parallel Co-ordinates

figure('Name','parallel co-ordinates plot for different design');
subplot 221
parallelcoords(A);
title('for full factorial design')

subplot 222
parallelcoords(B);
title('for Latin hypercube design with provided function');

subplot 223
parallelcoords(C);
title('for Latin hypercube design using matlab inbuilt function');

subplot 224
parallelcoords(D);
title('for sobol sampling ');

