function [medianx, IQR]=nonparamstad(x)
% compute the median
medianx = median(x);

% STEP 1 - rank the data
y = sort(x);

% compute 25th percentile (first quartile)
Q(1) = median(y(find(y<median(y))));

% compute 50th percentile (second quartile)
Q(2) = median(y);

% compute 75th percentile (third quartile)
Q(3) = median(y(find(y>median(y))));

% compute Interquartile Range (IQR)
IQR = Q(3)-Q(1);

