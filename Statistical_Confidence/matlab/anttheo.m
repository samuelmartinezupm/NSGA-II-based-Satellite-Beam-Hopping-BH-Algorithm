function esp=anttheo(tau0, rho, hm, hb, fitm, fitb, alpha, beta, colsize, steps)

taub = tau0;
taum = tau0;

pmalo = (alpha * log(taum) + beta * log(hm) - log(taum^alpha * hm^beta + taub^alpha * hb^beta));


for s=1:steps

	pmalo = pmalo + colsize * (alpha * log(taum) + beta * log(hm) - log(taum^alpha * hm^beta + taub^alpha * hb^beta));

	
	taub = taub * (1-rho);
	taum = taum * (1-rho) + 1/fitm;

end

pm = exp(pmalo);
pb = 1-pm;

esp = pm*fitm + pb*fitb;
