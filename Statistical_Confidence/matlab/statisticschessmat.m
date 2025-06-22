function [pt,res]=statisticschessmat(varargin)

% Comments

samples={};

for i=1:nargin
	samples{i}=load(varargin{i})';
end

[pt,res] = estadistico(samples, nargin);

