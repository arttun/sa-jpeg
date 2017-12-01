function [c,fb,cb,mb] = candidate(f,m,img,b)

% Generates a new candidate state.
%
% Input:
% f:        current state (24-bit RGB)
% m:        measurement (24-bit RGB)
% img:      model images (cell array)
% b:        block size (integer)
% Output:
% c:        new candidate state (24-bit RGB)
% fb:       a cell array of jpeg blocks that were changed, current state
% cb:       a cell array of jpeg blocks that were changed, candidate state
% mb:       a cell array of jpeg block that were changed, measurement
% 
% (c) Arttu Nieminen 2017

% Force blocks to be on a grid
grid_on = false;

% Choose random model image
g = img{randi(length(img))};

% Choose random blocks/pixels of both images
if grid_on
    i = (randi(ceil(size(f,1)/b))-1)*b+1;
    j = (randi(ceil(size(f,2)/b))-1)*b+1;
    k = (randi(ceil(size(g,1)/b))-1)*b+1;
    l = (randi(ceil(size(g,2)/b))-1)*b+1;
else
    i = randi(size(f,1));
    j = randi(size(f,2));
    k = randi(size(g,1));
    l = randi(size(g,2));
end

% Replace a block in current state with a block in model image
[c,tli,tlj,bri,brj] = replace(f,g,i,j,k,l,b);

% Find changed blocks
[fb,cb,mb] = changedblocks(f,c,m,tli,tlj,bri,brj);

end