function a = acceptprob(e,t,e0)

% Computes the acceptance probability
% of the Simulated annealing algorithm.
%
% Input:
% e:    energy change (energy of candidate - energy of current state)
% t:    current temperature
% e0:   initial energy (for normalised probability; optional)
% Output:
% a:    acceptance probability (scalar)
%
% (c) Arttu Nieminen 2017

if nargin < 3
    e0 = 1.0;
end

a = exp((-e)/(e0*t));

end