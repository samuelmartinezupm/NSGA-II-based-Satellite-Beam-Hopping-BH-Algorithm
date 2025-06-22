function n=acoafp(rho)
opc=18;
fit=84569;
init=1;
n = log ((opc-2)*fit*rho*init+1)./log(1./(1-rho));

