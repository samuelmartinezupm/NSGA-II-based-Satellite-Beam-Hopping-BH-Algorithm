function c=spearman(data)
cols = size(data,2);
ranks = tiedrank(data(:,1))';
for i=2:cols
	ranks=[ranks tiedrank(data(:,i))'];
end
c = corrcoef(ranks);
