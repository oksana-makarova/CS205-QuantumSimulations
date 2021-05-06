clear all
NN = 7; % number of spins

sx = [0, 1; 1 0];
sy = [0 -1i; 1i 0];
sz = [1 0; 0 -1];

v0 = [1; 0];
v1 = [0; 1];

h1 = 2*pi*0.1;
h0 = 2*pi*3;
a0 = 5;
J0 = 2*pi*52;
M = 1000;
%h3 = 3;
%t_pi = pi/(2*h3);
t_max = 1e6/(J0/a0^3);
t = linspace(t_max, 2*t_max, M);
theta = 0;
phi = 0;
psi0 = cos(theta)*v0 + 1i*sin(theta)*exp(-1i*phi)*v1;
psi_i = psi0;

for i = 2:NN
    psi_i = kron(psi0, psi_i);
end
%define operators: we should end up with something like I*I*...*sx*...*I
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

%constructing Hamiltonian
ham = sparse(2^NN, 2^NN);

%non-interacting part
for i = 1:NN
    ham = ham + (-1)^(i) * h1 * oper_at(i).sx ...
              + (-1)^(i+1) * h1 * oper_at(i).sy ...
              + h0 * oper_at(i).sz;
          
%    ham = ham + h0 * oper_at(i).sz;
end

%interacting part
for i = 1:(NN - 1) % kron(A, B)*kron(C, D) = kron((A*C), (B*D))
    for j = (i+1):NN
        rij = a0 * (j - i);
        dd = J0 / rij^3;
        ham = ham + dd * (oper_at(i).sx * oper_at(j).sx ...
                        + oper_at(i).sy * oper_at(j).sy...
                        - 2 * oper_at(i).sz * oper_at(j).sz); 
    end
end

%Evolution

%change of basis
[eigvecs, eigvals] = eig(full(ham), 'vector');
psiEig_i = inv(eigvecs)*psi_i; %coordinate transformation
psiEig_i_times = repmat(psiEig_i, 1, M);
eigs_ts = eigvals * t;
evolver = exp(-1i*eigs_ts);

%evolving the state
psiEig_f_times = psiEig_i_times .* evolver;
psi_f_times = eigvecs * psiEig_f_times;
norm_psi = vecnorm(psi_f_times);
psi_f_times = bsxfun(@rdivide, psi_f_times, norm_psi);

%density matrix
% Rho_tot = zeros(size(psi_f_times, 1));
% for i = 1:M
%     Rho_i = psi_f_times(:, i)*psi_f_times(:, i)';
%     Rho_tot = Rho_tot + Rho_i; 
% end
Rho_i = psi_i*psi_i';
%Rho_avg = Rho_tot / M;
Rho_f = psi_f_times(:, M)*psi_f_times(:, M)';

% state of a single qubit (#1). Tracing out density matrix
% N = NN - 1;
% v = [zeros(1, N) ones(1, N)];
% signs = unique(nchoosek(v, N), 'rows');
% Rho_1 = zeros(2);
% for k = 1:size(signs, 1) %construct operators for tracing out all qubits except for the first
%     permut = unique(perms(signs(k, :)), 'rows');
%     for j = 1:size(permut, 1)
%         par_tr_op = eye(2);
%         for i = 1:size(permut, 2)
%             if permut(j, i) == 0
%                 par_tr_op = kron(par_tr_op, v0);
%             else
%                 par_tr_op = kron(par_tr_op, v1);
%             end
%         end
%         Rho_1 = Rho_1 + par_tr_op'*Rho_f*par_tr_op;
%     end    
% end
% disp(Rho_1)

%trace out first qubit using SVD


%both have to always be zero: just a sanity check
Tr_init = trace(Rho_i)
Tr_final = trace(Rho_f)
