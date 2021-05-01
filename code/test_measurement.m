% ED for block diagonal matrices; XXZ Hamiltonian 
% Preparation script for speed up
% Oksana, 04/30/2021


function test_measurement(NN)
%NN = 7; % number of spins
%M number of time points of interest
%XXZCoeff - parameter to tune the Hamiltonian (set to 0 - Z state will never decay)
sx = 0.5*[0, 1; 1 0];
sy = 0.5*[0 -1i; 1i 0];
sz = 0.5*[1 0; 0 -1];

v0 = [1; 0];
v1 = [0; 1];

%% parameters
theta = 0;
phi = 0;
psi0 = cos(theta/2)*v0 + sin(theta/2)*exp(-1i*phi)*v1;
psi_i = psi0;

for i = 2:NN
    psi_i = kron(psi0, psi_i);
end

%% define operators: we should end up with something like I*I*...*sx*...*I
%for each spin, where sx is the location in the chain of that particular spin
for i = 1:NN
    if i == 1 %first spin
        oper_at(i).sx = kron(speye(2^(NN-1)), sx);
        oper_at(i).sy = kron(speye(2^(NN-1)), sy);
        oper_at(i).sz = kron(speye(2^(NN-1)), sz);
    else %any further spin
        oper_at(i).sx = speye(2, 2);
        oper_at(i).sy = speye(2, 2);
        oper_at(i).sz = speye(2, 2);
        for j = 2:NN %find it's location in the chain to put sx there
            if i == j 
                oper_at(i).sx = kron(sx, oper_at(i).sx);
                oper_at(i).sy = kron(sy, oper_at(i).sy);
                oper_at(i).sz = kron(sz, oper_at(i).sz);
            else
                oper_at(i).sx = kron(speye(2, 2), oper_at(i).sx);
                oper_at(i).sy = kron(speye(2, 2), oper_at(i).sy);
                oper_at(i).sz = kron(speye(2, 2), oper_at(i).sz);
            end
        end
    end
end



%% measure Z polarization in the most bruteforce way
SzN = sparse(2^NN, 2^NN);
for i = 1:NN 
    SzN = SzN + oper_at(i).sz;
end
%need to change operator basis to the same as Hamiltonian
%H_original = Q*D*Q^(-1) -> Sz = Q*Sz*Q^(-1)
%SzN = eigvecs * SzN / eigvecs;

%<psi|Q*Sz*Q^(-1)|psi>, normalize by 2/(the number of spins) so that it
%stays between -1 and 1
final_Zpolarization = psi_i' * SzN * psi_i * 2/NN


end