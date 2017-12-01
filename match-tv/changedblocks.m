function [fb,cb,mb] = changedblocks(f,c,m,tli,tlj,bri,brj)

% Return the blocks that were changed when generating a new candidate.
%
% Input:
% f:        current state (24-bit RGB)
% c:        candidate state (24-bit RGB)
% tli,tlj:  coordinates of the top-left pixel of the replaced area
% bri,brj:  coordinates of the bottom-right pixel of the replaced area
% Output:
% fb:       cell array of changed jpeg blocks, current state (24-bit RGB)
% cb:       cell array of changed jpeg blocks, candidate state (24-bit RGB)
% mb:       cell array of changed jpeg blocks, measurement (24-bit RGB)
%
% (c) Arttu Nieminen 2017

% Top-left block
[~,x,y] = neighbourhood(f,tli,tlj);

% Bottom-right block
[~,z,q] = neighbourhood(f,bri,brj);

% Blocks in-between
fb = cell(length(x:z),length(y:q));
cb = cell(length(x:z),length(y:q));
mb = cell(length(x:z),length(y:q));
ib = x:z;
jb = y:q;
for i = 1:length(ib)
    for j = 1:length(jb)
        fb{i,j} = jpegblock(f,ib(i),jb(j));
        cb{i,j} = jpegblock(c,ib(i),jb(j));
        mb{i,j} = jpegblock(m,ib(i),jb(j));
    end
end

end