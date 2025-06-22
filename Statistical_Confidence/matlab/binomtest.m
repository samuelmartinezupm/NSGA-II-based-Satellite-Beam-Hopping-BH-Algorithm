
function pval=binomtest(a,Na, b, Nb)

%function pval=binomtest(a,Na, b, Nb)

logcomba = sum (log (a+1:Na)) - sum (log(1:(Na-a)));
logcombb = sum (log (b+1:Nb)) - sum (log(1:(Nb-b)));

logpot1 = (a+b) * (log (a+b) - log(Na+Nb));
logpot2 = (Na+Nb-a-b) * (log (Na+Nb-a-b) - log (Na+Nb));

pval = exp(logcomba+logcombb+logpot1+logpot2);

