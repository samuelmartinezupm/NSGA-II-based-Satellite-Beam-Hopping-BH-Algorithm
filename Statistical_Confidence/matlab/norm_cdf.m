function retval = norm_cdf(x,mu,sigma)
% usage: retval = norm_cdf(x,mu,sigma)
% description: returns the cumulative distribution function for
% a normal random variable of mean mu and variance sigma^2 at x.

% Contact: Tom Shores, tshores1@math.unl.edu

if (nargin <= 2)
	sigma=1.0;
end

if (nargin <= 1)
	mu=0;
end

retval = (1+erf((x-mu)/(sigma*sqrt(2))))/2;

