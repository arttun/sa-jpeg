function r = randomstate(m,img,b)

% Generates a random initial state
% by combining random blocks from model images.
%
% Input:
% m:    measurement (24-bit RGB image)
% img:  model images (cell array of 24-bit RGB images)
% b:    size of block (bxb pixels)
% Output:
% r:    random initial state (24-bit RGB image)
%
% (c) Arttu Nieminen 2017

% Dimensions
n_h = ceil(size(m,1)/b);
n_w = ceil(size(m,2)/b);
n_img = length(img);

% New image
r = zeros(size(m,1),size(m,2),3,'uint8');

% Go through blocks
for i = 1:n_h
    for j = 1:n_w
        
        % Top-left pixel of block (i,j)
        ri = (i-1)*b+1;
        rj = (j-1)*b+1;
        
        % Random model image
        g = img{randi(n_img)};
       
        % Random block of model image
        gi = (randi(ceil(size(g,1)/b))-1)*b+1;
        gj = (randi(ceil(size(g,2)/b))-1)*b+1;
        
        % Replace
        r = replace(r,g,ri,rj,gi,gj,b);
        
    end    
end
    
end