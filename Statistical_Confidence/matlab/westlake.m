
function pval = westlake(n1, N1, n2, N2)

p1 = n1/N1;
p2 = n2/N2;
p = (n1+n2)/(N1+N2);
z = (p1-p2)/sqrt(p*(1-p)*(1/N1+1/N2));

if z < 0
	nz = z;
	z = -nz;
else
	nz = -z;
end

normal=cdf('Normal',[nz z],0,1); 
pval = 1-(normal(2)-normal(1));
