function d = diffnorm(a,b)

% Computes the squared L2-norms of the differences
% between images a and b by color components
% and sums them up.
% a and b have to be of the same size (width & height).
%
% Input:
% a:    image (24-bit RGB)
% b:    image (24-bit RGB)
% Output:
% d:    result (scalar)
%
% (c) Arttu Nieminen 2017

aa = im2double(a);
bb = im2double(b);
s = (aa-bb).^2;
d = sum(s(:));

end