% Preparation script for speed up
% Oksana, 04/30/2021


function ED_evolve_csv(NN, M, XXZCoeff, simnum, mydir)
%NN = 7; % number of spins
%M number of time points of interest
%XXZCoeff - parameter to tune the Hamiltonian 
%Delta - variance of disorder
%simnum - number of simulation for csv file
%mydir - directory name to save to 
%(Z state should never decay if disorder is 0; X and Y don't decay if XXZCoeff = 0)

%start the timer
tic;

%make directory if it does not exist
if ~exist(mydir, 'dir')
    mkdir(mydir)
end

sx = 0.5*[0, 1; 1 0];
sy = 0.5*[0 -1i; 1i 0];
sz = 0.5*[1 0; 0 -1];

v0 = [1; 0];
v1 = [0; 1];

%% parameters
a0 = 5;
J0 = 10;
Delta = 0.01; %variance of disorder 
%M = 1000;
%h3 = 3;
%t_pi = pi/(2*h3);
t_max = 10/(J0/a0^3);
t = linspace(0, t_max, M);

%initial wavefunction
theta = pi/2; %theta = pi/2 phi = 0 is X, theta = pi/2 phi = pi/2 is Y
phi = 0;
psi0 = cos(theta/2)*v0 + sin(theta/2)*exp(1i*phi)*v1;
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

%constructing Hamiltonian
ham = sparse(2^NN, 2^NN);
%ham = zeros(2^NN, 2^NN);
%% non-interacting part: disorder

%added Normally distributed disorder of variance Delta
for i = 1:NN
%     ham = ham + (-1)^(i) * h1 * oper_at(i).sx ...
%               + (-1)^(i+1) * h1 * oper_at(i).sy ...
%               + h0 * oper_at(i).sz;
    h_z = Delta * randn;      
    %h_z = 1;
    ham = ham + h_z * oper_at(i).sz;
end
%}

%% interacting part
%Note: this is a 1D chain of equally spaced spins
for i = 1:(NN - 1) % kron(A, B)*kron(C, D) = kron((A*C), (B*D))
    for j = (i+1):NN
        rij = a0 * (j - i);
        Jij = J0 / rij^3; %note 1/6 that came from another code convention
        %want: H = 1/6 * Jij(SS + XXZCoeff(SxSx + SySy - 2 SzSz))
        ham = ham + 1/6 * Jij * ((oper_at(i).sx * oper_at(j).sx ...
                         + oper_at(i).sy * oper_at(j).sy...
                         + oper_at(i).sz * oper_at(j).sz)... % SS part
                         + XXZCoeff * ... 
                         (oper_at(i).sx * oper_at(j).sx ...
                         + oper_at(i).sy * oper_at(j).sy...   
                         - 2 * oper_at(i).sz * oper_at(j).sz)); % tuned part
    end
end
%}
%Evolution

%% change of basis
%old_ham = ham;
[eigvecs, eigvals] = eig(full(ham), 'vector');
%trans_ham = eigvecs * eigvals * inv(eigvecs);

psiEig_i = eigvecs' * psi_i; %coordinate transformation
psiEig_i_times = repmat(psiEig_i, 1, M);
eigs_ts = eigvals * t;
evolver = exp(-1i*eigs_ts);

%% evolving the state
psiEig_f_times = psiEig_i_times .* evolver;

%convert the state back to original basis and normalize
psi_f_times = eigvecs * psiEig_f_times; 
norm_psi = vecnorm(psi_f_times);
psi_f_times = bsxfun(@rdivide, psi_f_times, norm_psi);

%% measure Z polarization in the most bruteforce way
SN = sparse(2^NN, 2^NN);
%SN = zeros(2^NN, 2^NN);

%Measure in all bases
 %along X 
for i = 1:NN
    SX = SN + oper_at(i).sx;
end
 %along Y
for i = 1:NN
    SY = SN + oper_at(i).sy;
end
%Along Z
for i = 1:NN
    SZ = SN + oper_at(i).sz;
end

%<psi|Sz|psi>, normalize by 2/(the number of spins) so that it
%stays between -1 and 1
%initial_polarization = real(psi_f_times(:, 1)' * SN * psi_f_times(:, 1))
%final_polarization = real(psi_f_times(:, M)' * SN * psi_f_times(:, M))
Zpolarization = zeros(1, M);
for i = 1:M
    Zpolarization(i) = real(psi_f_times(:, i)' * SZ * psi_f_times(:, i)) *2/NN;
end

%Find the Y polarization
Ypolarization = zeros(1, M);
for i = 1:M
    Ypolarization(i) = imag(psi_f_times(:, i)' * SY * psi_f_times(:, i)) *2/NN;
end

%Find the X polarization
Xpolarization = zeros(1, M);
for i = 1:M
    Xpolarization(i) = imag(psi_f_times(:, i)' * SX * psi_f_times(:, i)) *2/NN;
end

% f1 = figure; close(f1);
% plot(t, polarization, 'LineWidth',2.0);
% xlabel("time")
% ylabel("normalized polarization")
% ylim([-1.1 1.1])

%% trace out first qubit using SVD
% psi_mat = transpose(psi_f_times(:, M));
% psi_mat = [psi_mat(1:length(psi_mat)/2); psi_mat((length(psi_mat)/2+1):end)];
% [U,S,V] = svd(psi_mat);
% Rho_1_svd = S(1, 1)^2*(U*v0)*(U*v0)'+S(2, 2)^2*(U*v1)*(U*v1)'


%% density matrix
% Rho_tot = zeros(size(psi_f_times, 1));
% for i = 1:M
%     Rho_i = psi_f_times(:, i)*psi_f_times(:, i)';
%     Rho_tot = Rho_tot + Rho_i; 
% end
%Rho_i = psi_i*psi_i';
%Rho_avg = Rho_tot / M;
%Rho_f = psi_f_times(:, M)*psi_f_times(:, M)';

%both have to always be one: just a sanity check
% Tr_init = trace(Rho_i)
% Tr_final = trace(Rho_f)


%Record time elapsed for function call, also save to csv
mytime = toc;


%Open and save results to CSV file 
%Save 1 by (M + 3) matrix containing in order the simulation number, the 
%time for the simulation to run, the type of calculation, 
%and all M values in the calculation
A = [simnum, mytime, 0, t;...
    simnum, mytime, 1, Xpolarization; ...
    simnum, mytime, 2, Ypolarization; ...
    simnum, mytime, 3, Zpolarization];

%signifying the calculation
csvfilename = strcat([mydir, '/', num2str(simnum), '_simnum__', ...
    num2str(NN),'_spins__', num2str(M) '_steps__', ...
    num2str(XXZCoeff), '_XXZCoeff__data.csv']);
writematrix(A, csvfilename);


end
