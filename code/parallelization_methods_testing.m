%clear all;
%close all;
%clc;

%--------------------------------------------------------------------------
% Purpose of this code is to test parallelization and processing methods
% for large matrices.
% Make sure MATLAB Parallelization Toolkit or whatever is installed
% - parpool('..',x): makes pool of x workers, using either 'threads'
% (Shared memory) or 'local' (Distribtued memory)
%     'threads' --> reduced mem usage, faster communication
%     (parfor,parfeval)
%     'local' --> most general case, good for protyping
%     (parfor,parfeval,spmd)
%     This function should be called first it seems for the methods 
%       specified below. 
%     Takes a lil time to get setup, so the code will need to be run TWICE
%       to see the real speedup (NOT THIS CODE THOUGH, see parfor on online
%       documentation).
%
%
% Different parallelization methods will include:
% - distributed array: MATLAB distributes data over 1 dimension as evenly
%   as possible between workers
%     Multiple uses will be explored
%     
% - codistribtued array: User controls how MATLAB distribtues array between
%   bewteen workers. 
%     Multiple uses will be explored
%
%
% In addition to to parallelization methods, processing methods for speedup
% will also be delved into. These include:
% - parfor: splits execution of for loops over workers in parallel pool
%     Synchronous
%     
% - parfeval: splits function execution over parallel pool 
%     Asynchronous
%     
% - spmd: executes code in parallel over parallel pool
%     Synchronous
%--------------------------------------------------------------------------


%% Testing Processing Methods (parfor, parfeval, spmd)
%n = 50; %# of trials

% %Make struct for timings
% t1 = struct('parforTime',zeros(n,1),'parfevalTime',zeros(n,1),...
%     'spmdTime',zeros(n,1),'serialTime',zeros(n,1));
% 
% Initialize parallel pool (use all 4 cores) 
%lepool = parpool('local',4);
%workers = lepool.NumWorkers;
% 
% %%% It's known that spmd is better for operations while parfor/parfeval
% %%%   are better for generating matrices. Let's try both out, starting with
% %%%   creating big matrices of different sizings
% 
% %Timings pt1: Matrix generation
% N = [11,12,13,14]; %matrix sizing for 2^N
% 
% fprintf('Sizing for random square matrix creation (2^ ): [');
% fprintf('%g ', N);
% fprintf(']\n');
% disp('-------------------------------------------');
% 
% 
% for i = 1:n    
%     %Create cell array with dimensions 1 x #ofworkers
%     %  Each cell element is an empty matrix (will be 2^N x 2^N)
%     tic;
%     mats1 = cell(1,workers);
%     parfor j = 1:workers
%         mats1{j} = rand(2^N(j));
%     end
%     t1.parforTime(i) = toc;
%     
%     %parfeval usage here: (function, # of outputs, input1)
%     tic;
%     f(1:workers) = parallel.FevalFuture;
%     for j = 1:workers
%         f(j) = parfeval(@rand,1,2^N(j));
%     end
%     mats2 = fetchOutputs(f, "UniformOutput", false)';
%     t1.parfevalTime(i) = toc;
%     clear f;
%     
%     %round it out with spmd. Create the matrix once per worker
%     %  labindex: index of each worker
%     tic;
%     spmd
%         mats3 = rand(2^N(labindex));
%     end
%     eigns = {mats3{:}}; %don't know what this does explicitly
%     t1.spmdTime(i) = toc;
%     
%     %Let's see how the serial implementation does
%     %   Time the creation of 4 random matrices
%     tic;
%     for j = 1:length(N)
%         rand(2^N(j));
%     end
%     t1.serialTime(i) = toc;
%     
%     %fprintf('Iteration %4.1f complete \n',i);
% end
% 
% 
% disp('-------------------------------------------');
% fprintf('Average time using parfor over %4.1f iterations: %4.4fs \n',...
%     n,mean(t1.parforTime))
% fprintf('Average time using parfeval over %4.1f iterations: %4.4fs \n',...
%     n,mean(t1.parfevalTime))
% fprintf('Averge time using spmd over %4.1f iterations: %4.4fs \n',...
%     n,mean(t1.spmdTime))
% fprintf('Averge serial time over %4.1f iterations: %4.4fs \n',...
%     n,mean(t1.serialTime))
% 
% %--------------------------------------------------------------------------
% 
% %%% Now let's try some matrix multiplication.
% t2 = struct('parforTime',zeros(n,1),'parfevalTime',zeros(n,1),...
%     'spmdTime',zeros(n,1),'serialTime',zeros(n,1));
% clear N;    N = 11;
% 
% 
% fprintf('\nSizing for random square matrix multiplication (2^ ): %4.2f \n',N);
% disp('-------------------------------------------');
% 
% 
% for i = 1:n    
%     %parfor
%     tic;
%     result1 = eye(2^N);
%     parfor j = 1:workers
%         result1 = result1*rand(2^N); %reduction variable across workers (maybe)
%     end
%     t2.parforTime(i) = toc;
%     
%     %parfeval
%     tic;
%     f(1:workers) = parallel.FevalFuture;
%     for j = 1:workers
%         f(j) = parfeval(@rand,1,2^N);
%     end
%     result2 =  fetchOutputs(f(1))*fetchOutputs(f(2))*...
%         fetchOutputs(f(3))*fetchOutputs(f(4));
%     t2.parfevalTime(i) = toc;
%     clear f;
%     
%     %spmd. labindex: index of each worker
%     spmdMult = @(A,B)A*B;
%     X = Composite(); %make composite object to be used by each worker
%     X{1} = rand(2^N);
%     X{2} = rand(2^N);
%     X{3} = rand(2^N);
%     X{4} = rand(2^N);
%     tic;
%     spmd
%         r = gop(spmdMult,X,1); 
%     end
%     result3 = {r{1}}; %don't know what this does explicitly
%     t2.spmdTime(i) = toc;
%     
%     %serial. Do matrix muliplication on 4 matrices of size 2^N x 2^N
%     tic;
%     result4 = rand(2^N)*rand(2^N)*rand(2^N)*rand(2^N);
%     t2.serialTime(i) = toc;
%     
%     %fprintf('Iteration %4.1f complete \n',i);
% end
% 
% disp('-------------------------------------------');
% fprintf('Average time using parfor over %4.1f iterations: %4.4fs \n',...
%     n,mean(t2.parforTime))
% fprintf('Average time using parfeval over %4.1f iterations: %4.4fs \n',...
%     n,mean(t2.parfevalTime))
% fprintf('Averge time using spmd over %4.1f iterations: %4.4fs \n',...
%     n,mean(t2.spmdTime))
% fprintf('Averge serial time over %4.1f iterations: %4.4fs \n',...
%     n,mean(t2.serialTime))
% 
% %--------------------------------------------------------------------------
% 
% 
% %% Testing Parallelization Methods (distributed array, codistribtued array)
% %%% Apparently, you can control the
% %%% block sizing of the co-distributed array, so their may be an optimal
% %%% block size for performing this eig function evaluation.
% %%%
% %%% Going to sweep over various block sizings using co-distributed arrays
% %%% and see if there's an optimal one. Vary the size (N) of the various
% %%% sims
% %%%
% %%% After that, re-do the timings as usual with the new optimal block size.

% numBlocksweep = 50;
% cdistTimings = struct('N11',zeros(numBlocksweep,1),...
%     'N12',zeros(numBlocksweep,1),'N13',zeros(numBlocksweep,1),...
%     'N14',zeros(numBlocksweep,1));
% fields = fieldnames(cdistTimings);
% 
% %If only testing this segment, initialize the pool so the timings aren't
% %messed up
% parpool('local',4);
% 
% for i=1:numel(fields)
%     disp('-------------------------------------------');
%     fprintf('Starting iteration with N = %4.1f \n',N(i));
%     
%     temp = rand(2^N(i));
%     testMat = temp*temp';
% 
%     %Block sizing vector
%     blksizes = linspace(0.1*(2^N(i)),0.5*(2^N(i)),numBlocksweep);
%     
%     for j = 1:length(blksizes)
%         tic;
%         spmd(4)
%             D = codistributed(testMat,...
%                 codistributor2dbc([2,2],cast(blksizes(j),'uint8')));
%             eig(D,'nobalance');
%         end
%         cdistTimings.(fields{i})(j) = toc;
%         clear D;
% 
% 
%         fprintf('Iteration %4.1f complete \n',j);
%     end
%     
%     %Plot them boiz
%     figure();
%     plot(blksizes/(2^N(i)),cdistTimings.(fields{i}));
%     titleStr = strcat('Eig Function Evaluation with Worker Blocking: N = ',...
%         int2str(N(i)));
%     title(titleStr);
%     xlabel('Block Size [Fraction of 2^N]');
%     ylabel('Timings [s]');
%     shg;
% end
% 
% 
% %%% Now let's test how these methods work for the eig function. Based on
% %%% MATLAB's documentation, you use distributed arrays or GPUs to handle
% %%% eig function for parallelization. 
% 
% t3 = struct('distTime',zeros(n,1),'codistTime',zeros(n,1),...
%     'serialTime',zeros(n,1));
% %Clear N;  
% N = 12;
% temp = rand(2^N);
% testMat = temp*temp';
% 
% %If only testing this segment, initialize the pool so the timings aren't
% %messed up
% parpool('local',4);
% 
% fprintf('\nEig function evaluation with random symmetric matix of size (2^ ): %4.2f \n',N);
% disp('-------------------------------------------');
% 
% for i = 1:n
%     %distributed
%     tic;
%     D = distributed(testMat);
%     eig(D);
%     t3.distTime(i) = toc;
%     
%     %codistributed (32% block size)
%     clear D;
%     tic;
%     spmd(4)
%         D = codistributed(testMat,...
%             codistributor2dbc([2,2],cast(0.32*(2^N),'uint8')));
%         eig(D,'nobalance');
%     end
%     t3.codistTime(i) = toc;
% 
%     %serial
%     tic;
%     eig(testMat);
%     t3.serialTime(i) = toc;  
%     
%     fprintf('Iteration %4.1f complete \n',i);
% end
% 
% 
% fprintf('Averge time using distributed arrays over %4.1f iterations: %4.4fs \n',...
%     n,mean(t3.distTime))
% fprintf('Averge time using co-distributed arrays over %4.1f iterations: %4.4fs \n',...
%     n,mean(t3.codistTime))
% fprintf('Averge serial time over %4.1f iterations: %4.4fs \n',...
%     n,mean(t3.serialTime))
%--------------------------------------------------------------------------
%% Putting things together
%%% So it looks like eig() is always gonna be the faster method for finding
%%% the eigenvalues / vectors of the matrix, but let's see how the new
%%% distribtued arrays work with matrix multiplication

% t4 = struct('parforTime',zeros(n,1),'parfevalTime',zeros(n,1),...
%     'distTime',zeros(n,1),'codistTime',zeros(n,1),...
%     'serialTime',zeros(n,1));
% %clear N;    
% N = 12;
% 
% testMat = rand(2^N);
% 
% fprintf('\nSizing for random square matrix multiplication (2^ ): %4.2f \n',N);
% disp('-------------------------------------------');
% 
% 
% for i = 1:n    
%     %parfor
%     tic;
%     result1 = eye(2^N);
%     parfor j = 1:workers
%         result1 = result1*(testMat*testMat'); %reduction variable across workers (maybe)
%     end
%     t4.parforTime(i) = toc;
%     
%     %parfeval
%     fevalMult = @(A,B)A*B;
%     tic;
%     f = parfeval(fevalMult,1,testMat,testMat');
%     result2 =  fetchOutputs(f);
%     t4.parfevalTime(i) = toc;
%     clear f;
%     
%     %distributed
%     tic;
%     A = distributed(testMat);
%     B = distributed(testMat');
%     result3 = A*B;
%     t4.distTime(i) = toc;
%     clear A B;
%     
%     
%     %co-distributed (32% block size)
%     tic;
%     spmd(4)
%         A = codistributed(testMat,...
%             codistributor2dbc([2,2],cast(0.32*(2^N),'uint8')))
%         B = codistributed(testMat',...
%             codistributor2dbc([2,2],cast(0.32*(2^N),'uint8')))
%         result4 = A*B;
%     end
%     t4.codistTime(i) = toc;
%     clear A B;
%     
%     
%     %serial. Do matrix muliplication on 4 matrices of size 2^N x 2^N
%     tic;
%     result5 = testMat*testMat';
%     t4.serialTime(i) = toc;
%     
%     fprintf('Iteration %4.1f complete \n',i);
%     pause
% end
% 
% disp('-------------------------------------------');
% fprintf('Average time using parfor over %4.1f iterations: %4.4fs \n',...
%     n,mean(t4.parforTime))
% fprintf('Average time using parfeval over %4.1f iterations: %4.4fs \n',...
%     n,mean(t4.parfevalTime))
% fprintf('Averge time using distributed arrays over %4.1f iterations: %4.4fs \n',...
%     n,mean(t4.distTime))
% fprintf('Averge time using co-distributed arrays over %4.1f iterations: %4.4fs \n',...
%     n,mean(t4.codistTime))
% fprintf('Averge serial time over %4.1f iterations: %4.4fs \n',...
%     n,mean(t4.serialTime))



%--------------------------------------------------------------------------

% Close pool
% delete(gcp);
%% Helper Functions

