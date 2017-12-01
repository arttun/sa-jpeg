function [r,tli,tlj,bri,brj] = replace(f,g,fi,fj,gi,gj,b)

% Replaces block starting from pixels (fi,fj) of image f 
% with block starting from pixels (gi,gj) of image g and returns the result
%
% Note: 
% (1) This method also works if blocks are incomplete (smaller than bxb), 
% which can happen near the right or bottom side of the image.
% (2) If the block in image f is not as wide or not as high as the block
% in image g, the block in f is replaced with the up-leftmost pixels of 
% block in g that correspond to the pixels in block in f. Vice versa, if 
% block in image f is wider or higher than the block in image g, then only
% those up-leftmost pixels of block in f are replaced that correspond to 
% the pixels in block g.
%
% Input:
% f:        original image (24-bit RGB)
% g:        model image (24-bit RGB)
% fi,fj:	coordinates of the top-left pixel of the block in image f
% gi,gj:	coordinates of the top-left pixel of the block in image g
% b:        block size (bxb pixels)
% Output:
% r:        resulting image (24-bit RGB)
% tli,tlj:  coordinates of the top-left pixel of replaced area
% bri,brj:  coordinates of the bottom-right pixel of replaced area
%
% (c) Arttu Nieminen 2017

% Copy old image
r = f;

% Image sizes
[fh,fw,~] = size(f);
[gh,gw,~] = size(g);

% Top-left pixel
tli = fi;
tlj = fj;

% Replace all possible pixels in the block
for k = 1:b
    for l = 1:b
        fx = fi-1+k;
        fy = fj-1+l;
        gx = gi-1+k;
        gy = gj-1+l;
        if fx <= fh && fy <= fw && gx <= gh && gy <= gw
            r(fx,fy,1) = g(gx,gy,1);
            r(fx,fy,2) = g(gx,gy,2);
            r(fx,fy,3) = g(gx,gy,3);
            bri = fx; 
            brj = fy;
        end
    end    
end

end