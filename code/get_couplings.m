% Provided by Black Diamond team of Lukin group

function [Js, Pos, L] = get_couplings(P)
% GET_COUPLINGS - Randomly place some spins and generate interaction coefficients
%
%   P.N [int]: Number of spins
%   P.J0 [float, GHz]: Spin-spin interaction strength
%   P.JDipole [float, GHz nm^P.Alpha]: Intrinsic coupling strength
% 
% OPTIONAL FIELDS
%   P.RCutoff [float, nm]: Minimum distance between spins
%   P.SimMace: Build an ensemble of extra spins for MACE simulations. (Now applies to ED & DTWA)
%       Requires P.nMace, which is the total number of spins in the ensemble
%   P.BoundaryConditions [str]: 'Periodic' or 'Open'. Default is Periodic.
%   P.Alpha [float]: change the coupling matrix element to 1/r^P.alpha. Default is 3
%       If P.Alpha = 0, then all couplings will just be P.J0. Still generates Pos.
%       If P.Alpha = inf, then the nearest neightbors will experience a coupling of J0 * (dipolar angular factor)
%           and all other couplings will be zero.
%       For both 0 and inf, the spin-spin spacing is set to 1.
%   P.SpatialDim [int 1-3]: Line (1), plane (2) or cube (3) of spins. Default is 3.
%   P.Lattice [string]: Positional ordering. Square or None. Defaults to None
%   P.QuantizationAxis [length-3 array]: Quantization axis of the spins. Default is +z ([0,0,1])
%           Must be unit norm!
%   P.JMax [float]: Maximum value Js can take. Any values larger than P.JMax will be set to P.JMax
%   P.SortSpinsByPos [boole]: Sort the spin from closest to furthest from the origin if true
%   Not yet implemented: P.JCutoff [float]: Upper bound allowed for Js. If a Js exceeds JCutoff, we redo the disorder average
% 
%   [Js, Pos, L] = get_couplings(P) [matrix, matrix, float]: P.NxP.NCoupling
%       matrix, P.Nx3 array of spin positions, bounding box size

rMinTolerance = 1e-6; % for P.Alpha=inf, numerical rounding errors prevent 
                      % us from finding all the nearest neighbors unless we
                      % define 'nearest neighbor' with a looser bound

if isfield(P, 'RCutoff')
    RCutoff = P.RCutoff;
else
    RCutoff = 0;
end

if isfield(P, 'BoundaryConditions')
    BoundaryConditions = P.BoundaryConditions;
else
    BoundaryConditions = 'Periodic';
end
if isfield(P, 'Alpha')
    Alpha = P.Alpha;
else
    Alpha = 3;
end

% Add extra spins in the Hamiltonian for MACE simulations
if isfield(P, 'SimMace') && P.SimMace
    N = P.nMace;
else
    N = P.N;
end

if isfield(P, 'SpatialDim')
    SpatialDim = P.SpatialDim;
else
    SpatialDim = 3;
end
if isfield(P, 'Lattice')
    Lattice = P.Lattice;
else
    Lattice = 'None';
end
if isfield(P, 'QuantizationAxis')   % Let QuantizationAxis = None give isotropic system
    QuantizationAxis = P.QuantizationAxis;
else
    QuantizationAxis = [0,0,1];
end
if isfield(P, 'JMax')
    JMax = P.JMax;
else
    JMax = inf;
end
if isfield(P, 'SortSpinsByPos')
    SortSpinsByPos = P.SortSpinsByPos;
else
    SortSpinsByPos = true;
end

if Alpha == 0 || Alpha == inf
    AverageSpacing = 1;
else
    AverageSpacing = (P.JDipole/P.J0)^(1/Alpha);
end
% L ^ SpatialDim = P.N * AverageSpacing ^ SpatialDim
L = P.N ^ (1/SpatialDim) * AverageSpacing;

happy = false;  % why not? :(

while ~happy
    
    if strcmp(Lattice, 'None')
        Pos = L * rand(N,3) - L/2;  % Uniformly position spins in a box
    elseif strcmp(Lattice, 'Square')
        Pos = get_square_lattice(N, AverageSpacing, SpatialDim);
    end
    
    if SpatialDim < 3
        Pos(:,3) = 0;
    end
    if SpatialDim < 2
        Pos(:,2) = 0;
    end
    
    % Sort the spins from closest to furthest
    if SortSpinsByPos
        [~, sorted_indices] = sort(sum(Pos.^2,2), 'ascend');
        Pos = Pos(sorted_indices, :);
    end

    % periodic boundary conditions
    if strcmp(BoundaryConditions, 'Periodic')
        dist_x = min(abs(repmat(Pos(:,1),[1,N]) - repmat(Pos(:,1)',[N,1])), abs(L - abs(repmat(Pos(:,1),[1,N]) - repmat(Pos(:,1)',[N,1])))) ;
        dist_y = min(abs(repmat(Pos(:,2),[1,N]) - repmat(Pos(:,2)',[N,1])), abs(L - abs(repmat(Pos(:,2),[1,N]) - repmat(Pos(:,2)',[N,1])))) ;
        dist_z = min(abs(repmat(Pos(:,3),[1,N]) - repmat(Pos(:,3)',[N,1])), abs(L - abs(repmat(Pos(:,3),[1,N]) - repmat(Pos(:,3)',[N,1])))) ;
    elseif strcmp(BoundaryConditions, 'Open')
        dist_x = abs(Pos(:,1) - Pos(:,1)');
        dist_y = abs(Pos(:,2) - Pos(:,2)');
        dist_z = abs(Pos(:,3) - Pos(:,3)');
    end

    % Eliminate self-coupling
    dist = sqrt(dist_x.^2 + dist_y.^2 + dist_z.^2) + diag(Inf * ones(N,1));

    % Enforce a minimum spacing of r_cut
    if min(min(dist)) > RCutoff % || ~all(Js <= JCutoff)   % Add this to enforce JCutoff (move below code above this line)
        happy = true;
    else
        happy = false;
        disp('Not happy because too close! Retrying');
    end
end

% cosThetas = dist_z ./ dist;
CosThetas = (dist_x * QuantizationAxis(1) + dist_y * QuantizationAxis(2) + dist_z * QuantizationAxis(3)) ./ dist;
qs = - 1 + 3 * CosThetas.^2;

if Alpha == 0   % Note that we ignore qs here
    Js = (ones(size(qs)) - eye(length(qs))) * P.J0;
elseif Alpha == inf
    if strcmp(Lattice, 'None')
        warning('get_couplings.m: Alpha = inf but there is no lattice. This is probably not desired. Only two spins will experience any interactions.')
    end
    Js = zeros(P.N, P.N);
    rMin = min(dist(:)) * (1+rMinTolerance);
    Js(dist(:) <= rMin) = P.J0;
    Js = Js .* qs;
else
    Js = P.JDipole * (qs ./ dist.^Alpha);
end

% Set an upper bound on J
Js(Js > JMax) = JMax;
Js(Js < -JMax) = -JMax;     % 2020-07-30: I had originally forgotten this

end


function Pos = get_square_lattice(N, AverageSpacing, SpatialDim)
if abs(N ^ (1/SpatialDim) - round(N ^ (1/SpatialDim))) > 10e-13
    error('P.N should be an integer raised to the power of P.SpatialDim')
end
Pos = zeros(N,3);
if SpatialDim == 1
    Pos(:,1) = ((0:(N-1)) - (N-1)/2) * AverageSpacing;
elseif SpatialDim == 2
    n = round(sqrt(N));
    Pos(:,1) = (mod(0:(N-1), n) - (n-1)/2) * AverageSpacing;
    Pos(:,2) = (floor((0:(N-1))/n) - (n-1)/2) * AverageSpacing;
elseif SpatialDim == 3
    n = round(N^(1/3));
    Pos(:,1) = (mod(0:(N-1), n) - (n-1)/2) * AverageSpacing;
    Pos(:,2) = (mod(floor((0:(N-1))/n), n) - (n-1)/2) * AverageSpacing;
%     Pos(:,3) = (floor((0:(N-1))/n^2) - (n^2-1)/2) * AverageSpacing;  % This was incorrect
    Pos(:,3) = (floor((0:(N-1))/n^2) - (n-1)/2) * AverageSpacing;
end
end

