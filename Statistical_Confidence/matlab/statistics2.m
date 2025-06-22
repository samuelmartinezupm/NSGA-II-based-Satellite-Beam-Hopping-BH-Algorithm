function statistics2(f1,f2)

[pt,mc] = statistics(f1,f2);

if (pt < 0.05)
	disp('positive');
else
	disp('negative');
end
