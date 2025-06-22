function neg=negrea (tab)

neg = [];

for i=1:size(tab,1)
	neg = [neg; (tab(i,3)*tab(i,5) > 0) * ones(1,5)];
end
