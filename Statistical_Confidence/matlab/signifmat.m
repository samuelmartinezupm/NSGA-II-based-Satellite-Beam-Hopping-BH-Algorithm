function res=signifmat(est)

k=size(est,1);
n = (1+sqrt(1+8*k))/2;

res=zeros(n,n);

for i=1:size(est,1)
	if (est(i,3)*est(i,5) > 0)
		res(est(i,1),est(i,2)) = -sign(est(i,3));
		res(est(i,2),est(i,1)) = sign(est(i,3));
	end
end



