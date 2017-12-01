function e = energy(c,m,qf)

% Computes the energy of state c
%
% Input:
% c:    state (24-bit RGB)
% m:    measurement (24-bit RGB)
% qf:   quality factor (real number in (0,100])
% Output:
% e:    energy of c
%
% (c) Arttu Nieminen 2017

% Regularisation parameter
%l = 0.05;

% Squared L2-norm of difference
l2norm = diffnorm(compress(c,qf),m);

% Total variation
%[gx,gy] = gradient(im2double(c));
%tvgx = sum(abs(gx),4);
%tvgy = sum(abs(gy),4);
%tv = sum(tvgx(:)) + sum(tvgy(:));

e = l2norm;% + l * tv;

end