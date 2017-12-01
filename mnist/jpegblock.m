function b = jpegblock(f,x,y)

% Returns the JPEG block (x,y) of image f.
% (Block may be incomplete near the bottom/right edges of the image.)
%
% Input:
% f:    image (24-bit RGB)
% x,y:  coordinates of the block: xth row, yth column in the grid of blocks
% Output:
% b:    block of the image f (24-bit RGB)
%
% (c) Arttu Nieminen 2017

[h,w,~] = size(f);
k = (x-1)*8+1;
l = (y-1)*8+1;
m = min(x*8,h);
n = min(y*8,w);
b = f(k:m,l:n,:);

end

