function [b,x,y] = neighbourhood(f,i,j)

% Returns the 8x8 JPEG block of pixel (i,j) of image f.
% Returns the incomplete block if the block is incomplete (near border).
% Returns an empty array if the pixel is outside of the image.
%
% Input:
% f:    input image (24-bit RGB)
% i,j:  coordinates of the pixel
% Output:
% b:    8x8 block (24-bit RGB)
% x,y:  coordinates of the jpeg block
%
% (c) Arttu Nieminen 2017

[h,w,~] = size(f);
if i > h || j > w
    fprintf('Warning: neighbourhood: pixel outside of image\n');
    b = int8.empty(0,0,0);
else
    x = ceil(i/8);
    y = ceil(j/8);
    b = jpegblock(f,x,y);
end

end

