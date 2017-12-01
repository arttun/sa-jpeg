function e = energychange(fb,cb,mb,qf)

% Computes the change in energy from current to candidate state.
%
% Input:
% fb:   cell array of changed blocks, current state (24-bit RGB)
% cb:   cell array of changed blocks, candidate state (24-bit RGB)
% m:    measurement image (24-bit RGB)
% qf:   quality factor (real number in (0,100])
% Output:
% e:    energy change
%
% (c) Arttu Nieminen 2017

e = 0.0;
for i = 1:size(fb,1)
    for j = 1:size(fb,2)
        e = e - energy(fb{i,j},mb{i,j},qf) + energy(cb{i,j},mb{i,j},qf);
    end
end

end