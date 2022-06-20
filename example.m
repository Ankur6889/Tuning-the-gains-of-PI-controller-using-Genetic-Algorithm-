n= 50;
	[X,Y] = meshgrid([0:1/n:1]);
	X=X(:);Y=Y(:);
	R = X.^2+Y.^2;
	Ind = R<=1;
	XX=X(Ind);
	YY=Y(Ind);
	ZZ=sqrt(1-R(Ind));
	Res  = Hypervolume_MEX([XX,YY,ZZ],[1 1 1])
	disp('This result tends to 1-pi/6=0.4764 when n goes to infinity');
	scatter3(XX,YY,ZZ);