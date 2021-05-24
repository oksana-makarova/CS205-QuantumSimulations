% adding relevant parts of the big code base to prepare a physical system
% ED for block diagonal matrices; XXZ Hamiltonian 
% Oksana, 05/04/2021


%% Initialize simulation parameters
tic
P.XXZCoeff = 1; % Hamiltonian of the form S.S + XXZCoeff (XX+YY-2ZZ)
P.N = 12;      % Number of spins
P.nIter = 1; % Number of iterations
P.Alpha = 3; %scaling of interaction: 1/r^alpha
P.SpatialDim = 3; %system dimension: 1D, 2D, 3D
P.BoundaryConditions = 'Open'; % Periodic or Open

% P.Lattice = 'Square';
P.Simulator = 'newED';
P.nTimePoints = 1000; % Number of time steps at which we check polarization

P.InitStates = "X"; %X, Y, or Z
P.RCutoff = 0.2; % [nm] minimum spin-spin distance

P.JDipole = 0.0520;
P.J0 = (2*pi)*0.035e-3; % [GHz, angular]. Sets average NV-NV spacing
P.DisorderType = 'Gauss1';
P.Delta = (2*pi)*0; % [rad GHz] Disorder standard deviation

%% Run the simulation - we intentionally leave this in the script for flexibility

%independent of Sim Type
%PsisAv = zeros(3*P.N, P.nTimePoints+1, length(P.InitStates));
% PsisAll = zeros(3*P.N, P.nTimePoints+1, P.nDis, length(P.InitStates));
% Corrs = zeros(3*P.nSpinsCor, 3*P.nSpinsCor, P.nTimePoints+1, length(P.InitStates));

time_Ham = zeros(1, length(7:P.N));
time_all_blks = zeros(1, length(7:P.N));
time_block_timing_eig = zeros(length(7:P.N), (P.N+1));
time_block_timing_evol = zeros(length(7:P.N), (P.N+1));
time_meas = zeros(1, length(7:P.N));
time_tot = zeros(1, length(7:P.N));

if strcmp(P.Simulator,'newED')
    for i = 7:P.N
	tot = tic;
        rng(i); %select definite seeds for reproducibility
        [JMat, Pos] = get_couplings(P);
      
        %note that disorder is currently specified in ED_evolve_block_diag
        %itself and is currently set to 0
        [t_make_Ham, t_all_blks, block_timing_eig, block_timing_evol, t_meas] = ED_evolve_block_diag_GPU(i, P.nTimePoints, P.XXZCoeff, JMat, P.InitStates);       
        t_tot = toc(tot);
	
	time_Ham(i-6) = t_make_Ham;
	time_all_blks(i-6) = t_all_blks;
	time_block_timing_eig(i-6, 1:(i+1)) = block_timing_eig;
	time_block_timing_evol(i-6, 1:(i+1)) = block_timing_evol;
	time_meas(i-6) = t_meas;
	time_tot(i-6) = t_tot;	
    end
end

7:P.N
time_Ham
time_all_blks
time_block_timing_eig
time_block_timing_evol
time_meas
time_tot

toc
% %% Plot the results
% if isfield(P, 'FigNum')
%     set(0, 'DefaultAxesFontSize', 12)
%     figure(P.FigNum); clf; hold all
%     title(P.FigName)
%     % plot(Results.ts, Results.PsisAv(3:3:3*round(P.N/4), :, 1)')
%     plot(Results.ts, Results.PsisAv(3:3:end, :, 1)')
%     plot(Results.ts, Results.Signal, 'linewidth', 3)
%     xlabel('time [ns]'); ylabel('x, y coherence')
% 
% end

