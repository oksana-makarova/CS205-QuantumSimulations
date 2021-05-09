function [Vstore, Dstore, psi_out] = eig_load_balanced(N,blked_matrices,psi_in)
% Solving using blocking and GPU acceleration, with custom load-balancing
% Timing: Need to solve it more than once, and discard first time due to some
% messages that prints out due to lack of GUI. Ignore timediscard and
% timediscard2.
% gpu_bal is the eig time WITH custom load-balancing (different for odd or
% even problem size)

% create a parallel pool with as many workers as GPUs available
% parpool('local',gpuDeviceCount("available"));

store = {};
psi_out = {};

if mod(N, 2) == 0
    store{end+1} = blkdiag(blked_matrices{1:N/2-2});
    temp = psi_in{1};
    for i = 2:(N/2-2)
        temp = cat(1,temp,psi_in{i});
    end
    psi_out{end+1} = temp;
    
    store{end+1} = blked_matrices{N/2-1};
    psi_out{end+1} = psi_in{N/2-1};
    store{end+1} = blked_matrices{N/2};
    psi_out{end+1} = psi_in{N/2};
    store{end+1} = blked_matrices{N/2+1};
    psi_out{end+1} = psi_in{N/2+1};
    
    store{end+1} = blkdiag(blked_matrices{N/2+2:N-1});
    temp = psi_in{N/2+2};
    for i = N/2+3:(N-1)
        temp = cat(1,temp,psi_in{i});
    end
    psi_out{end+1} = temp;
else
%     store2{end+1} = blkdiag(store{1:((N-1)/2) - 2}, store{((N-1)/2) + 3:N-1});
%     store2{end+1} = blkdiag(store{(N-1)/2}, store{((N-1)/2) + 1});
%     store2{end+1} = blkdiag(store{((N-1)/2) - 1 }, store{((N-1)/2) + 2});   
    store{end+1} = blkdiag(blked_matrices{1:((N-1)/2) - 2});
    temp = psi_in{1};
    for i = 2:((N-1)/2) - 2
        temp = cat(1,temp,psi_in{i});
    end
    psi_out{end+1} = temp;
    
    store{end+1} = blked_matrices{((N-1)/2) - 1 };
    psi_out{end+1} = psi_in{((N-1)/2) - 1 };
    store{end+1} = blked_matrices{(N-1)/2};
    psi_out{end+1} = psi_in{((N-1)/2)};
    store{end+1} = blked_matrices{((N-1)/2) + 1};
    psi_out{end+1} = psi_in{((N-1)/2)+1};
    store{end+1} = blked_matrices{((N-1)/2) + 2};
    psi_out{end+1} = psi_in{((N-1)/2)+2};
    
    store{end+1} = blkdiag(blked_matrices{((N-1)/2) + 3:N-1});
    temp = psi_in{((N-1)/2) + 3};
    for i = ((N-1)/2) + 4:(N-1)
        temp = cat(1,temp,psi_in{i});
    end
    psi_out{end+1} = temp;
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
    Dstore{k} = diag(D);
end
% gpu_bal = toc

end
