% Adding relevant parts of the big code base to prepare a physical system
% ED for block diagonal matrices; XXZ Hamiltonian 
% Oksana, 05/04/2021


%% Initialize simulation parameters

P.XXZCoeff = 1; % Hamiltonian of the form S.S + XXZCoeff (XX+YY-2ZZ)
P.N = 6;      % Number of spins
P.nIter = 5; % Number of iterations
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

if strcmp(P.Simulator,'newED')
    for i = 1:P.nIter
        rng(i); %select definite seeds for reproducibility
        [JMat, Pos] = get_couplings(P);
        
        %note that disorder is currently specified in ED_evolve_block_diag
        %itself and is currently set to 0
        ED_evolve_block_diag(P.N, P.nTimePoints, P.XXZCoeff, JMat, P.InitStates)       
    end
end
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


