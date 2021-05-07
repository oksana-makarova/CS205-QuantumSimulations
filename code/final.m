% Problem size
N = 13;

% Construct block-diagonal matrix
B = ones(nchoosek(N,1));
lengths = double.empty;
lengths(end+1) = nchoosek(N,1);

if mod(N, 2) == 0 
    for i = 2:N/2
        size = nchoosek(N,i);
        A = ones(size);
        B = blkdiag(B, A);
        lengths(end+1) = size;
    end

    for i = N/2-1:-1:1
        size = nchoosek(N,i);
        A = ones(size);
        B = blkdiag(B, A);
        lengths(end+1) = size;
    end
else
    for i = 2:(N-1)/2
        size = nchoosek(N,i);
        A = ones(size);
        B = blkdiag(B, A);
        lengths(end+1) = size;
    end
    
    for i = (N-1)/2:-1:1
        size = nchoosek(N,i);
        A = ones(size);
        B = blkdiag(B, A);
        lengths(end+1) = size;
    end
end

    

% Split block-diagonal matrix into blocks
ii = 1;
jj = 1;
store = {};
for i = lengths
out = B(ii:ii+i-1,jj:jj+i-1);
store{end+1} = out;
ii = ii + i;
jj = jj + i;
end


% Solve block-diagonal matrix eigensystem serially
tic
[V,D] = eig(B);
serial_time = toc


% Solving using blocking and GPU acceleration, no custom load-balancing
% Need to solve it more than once, and discard first time due to some
% messages that prints out due to lack of GUI. Ignore timediscard and
% timediscard2.
% gpu_no_bal is the eig time WITHOUT custom load-balancing (uses default
% MATLAB load-balancing)
% gpu_bal is the eig time WITH custom load-balancing (different for odd or
% even problem size)

numGPUs = gpuDeviceCount("available")

% create a parallel pool with as many workers as GPUs available
parpool(numGPUs) 
Vstore = cell(1,length(store));
Dstore = cell(1,length(store));
tic
parfor k = 1:length(store)
    item = gpuArray(store{k});
    [V,D] = eig(item);
    Vstore{k} = V;
    Dstore{k} = D;
end
timediscard = toc


Vstore = cell(1,length(store));
Dstore = cell(1,length(store));
tic
parfor k = 1:length(store)
    item = gpuArray(store{k});
    [V,D] = eig(item);
    Vstore{k} = V;
    Dstore{k} = D;
end
gpu_no_bal = toc


% With custom load-balancing
store2 = {};

if mod(N, 2) == 0
    store2{end+1} = blkdiag(store{1:N/2-2});
    store2{end+1} = store{N/2-1};
    store2{end+1} = store{N/2};
    store2{end+1} = store{N/2+1};
    store2{end+1} = blkdiag(store{N/2+2:N-1});
else
%     store2{end+1} = blkdiag(store{1:((N-1)/2) - 2}, store{((N-1)/2) + 3:N-1});
%     store2{end+1} = blkdiag(store{(N-1)/2}, store{((N-1)/2) + 1});
%     store2{end+1} = blkdiag(store{((N-1)/2) - 1 }, store{((N-1)/2) + 2});
    
    
    store2{end+1} = blkdiag(store{1:((N-1)/2) - 2});
    store2{end+1} = store{((N-1)/2) - 1 };
    store2{end+1} = store{(N-1)/2};
    store2{end+1} = store{((N-1)/2) + 1};
    store2{end+1} = store{((N-1)/2) + 2};
    store2{end+1} = blkdiag(store{((N-1)/2) + 3:N-1});

end


tic
parfor k = 1:length(store2)
    item = gpuArray(store2{k});
    [V,D] = eig(item);
    Vstore2{k} = V;
    Dstore2{k} = D;
end
timediscard2 = toc


Vstore2 = cell(1,length(store2));
Dstore2 = cell(1,length(store2));

tic
parfor k = 1:length(store2)
    item = gpuArray(store2{k});
    [V,D] = eig(item);
    Vstore2{k} = V;
    Dstore2{k} = D;
end
gpu_bal = toc

exit
