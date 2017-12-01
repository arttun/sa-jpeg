function j = nextind(i,n)

% Returns the next index.
%
% Input:
% i:    current index
% n:    maximum index: once reached, return to index 1
% Output:
% j:    new index
%
% (c) Arttu Nieminen 2017

if i < n
    j = i+1;
else
    j = 1;
end

end