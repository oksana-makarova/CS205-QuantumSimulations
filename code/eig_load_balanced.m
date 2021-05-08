function [Vstore, Dstore] = eig_load_balanced(N,blked_matrices)
% Solving using blocking and GPU acceleration, with custom load-balancing
% Timing: Need to solve it more than once, and discard first time due to some
% messages that prints out due to lack of GUI. Ignore timediscard and
% timediscard2.
% gpu_bal is the eig time WITH custom load-balancing (different for odd or
% even problem size)

% create a parallel pool with as many workers as GPUs available
% parpool('local',gpuDeviceCount("available"));

store = {};

if mod(N, 2) == 0
    store{end+1} = blkdiag(blked_matrices{1:N/2-2});
    store{end+1} = blked_matrices{N/2-1};
    store{end+1} = blked_matrices{N/2};
    store{end+1} = blked_matrices{N/2+1};
    store{end+1} = blkdiag(blked_matrices{N/2+2:N-1});
else
%     store2{end+1} = blkdiag(store{1:((N-1)/2) - 2}, store{((N-1)/2) + 3:N-1});
%     store2{end+1} = blkdiag(store{(N-1)/2}, store{((N-1)/2) + 1});
%     store2{end+1} = blkdiag(store{((N-1)/2) - 1 }, store{((N-1)/2) + 2});   
    store{end+1} = blkdiag(blked_matrices{1:((N-1)/2) - 2});
    store{end+1} = blked_matrices{((N-1)/2) - 1 };
    store{end+1} = blked_matrices{(N-1)/2};
    store{end+1} = blked_matrices{((N-1)/2) + 1};
    store{end+1} = blked_matrices{((N-1)/2) + 2};
    store{end+1} = blkdiag(blked_matrices{((N-1)/2) + 3:N-1});

end

Vstore = cell(1,length(store));
Dstore = cell(1,length(store));


% tic;
% parfor k = 1:length(store)
%     item = gpuArray(store{k});
%     [V,D] = eig(item);
%     Vstore{k} = V;
%     Dstore{k} = D;
% end
% timediscard2 = toc


% tic;
parfor k = 1:length(store)
    item = gpuArray(store{k});
    [V,D] = eig(item);
    Vstore{k} = V;
    Dstore{k} = D;
end
% gpu_bal = toc

end