function [Z, E] =   S3CD(X, W, lambda, garma, beta, rho, DEBUG)

% 低秩稀疏联合优化算法计算

clear global;
global M;           %  

addpath('..\utilities\PROPACK');

if (~exist('DEBUG','var'))
    DEBUG = 0;
end

if nargin < 6
    rho = 1.9;
end

%%  parameters 

if nargin < 5
    beta = 1;  %1
end

if nargin < 4
    garma = 1;   %1
end

if nargin < 3
    lambda = 0.5;   %0.5
end




%%  
nv = length(X);
E = cell(1, nv);
Y1 = cell(1, nv);
Y2 = cell(1, nv);
Z = cell(1, nv);
J = cell(1, nv);
XZ = zeros(1, nv);
sv = 5;
svp = sv;

for idx = 1 : nv
    [d, n] = size(X{idx});
    J{idx} = zeros(n, n);
    E{idx} = sparse(d, n);
    Z{idx} = eye(n, n);

    Y1{idx} = zeros(d, n);
    Y2{idx} = zeros(n, n);
    % XZ{idx} = zeros(d, n);
end



% Construct the K-NN Graph
for idx = 1 : nv
    if nargin < 2  ||  isempty(W)
        W{idx} = constructW (X{idx}');
    end
    DCol = full(sum(W{idx},2));

    % unnormalized Laplacian;
    D = spdiags(DCol,0,speye(size(W{idx},1)));
    L{idx} = D - W{idx};
end


normfX = norm(X{2},'fro');
tol1 = 1e-4;              % threshold for the error in constraint
tol2 = 1e-5;              %  threshold for the change in the solutions
[d n] = size(X{2});
opt.tol = tol2;            %  precision for computing the partial SVD
opt.p0 = ones(n,1);

% 迭代次数
maxIter = 400; %!!!!!!!!!!!

max_mu = 1e10;
norm2X = norm(X{2},2);


mu = 10;  %1e-6 10
eta = 800; %800


%% Initializing optimization variables

convergenced = 0;
iter = 0;

if DEBUG
    disp(['initial,rank(Z)=' num2str(rank(Z))]);
end

while iter<maxIter
    iter = iter + 1;
    for idx = 1 : nv

       
        
        data_view = X{idx};
        [d, n] = size(data_view);

        %copy E, J  and Z to compute the change in the solutions
        Ek = E{idx};
        Zk = Z{idx};
        Jk = J{idx};

        XZ = X{idx}*Z{idx};
        ZLT = Z{idx}* L{idx}';
        ZL = Z{idx}*L{idx};

        %solving Z
        %-----------Using PROPACK--------------%
        M =  beta* (ZLT + ZL);
        M = M + mu *X{idx}' *(XZ -X{idx} + E{idx} -Y1{idx}/mu);
        M = M +mu *(Z{idx}- J{idx}+Y2{idx}/ mu);
        M = Z{idx} - M/eta;

        %    [U, S, V] = lansvd(M, n, n, sv, 'L', opt);
        %[U, S, V] = lansvd(M, n, n, sv, 'L');
        [U, S, V] = svd((M+eps),'econ');

        S = diag(S);
        svp = length(find(S>1/(mu*eta)));
        if svp < sv
            sv = min(svp + 1, n);
        else
            sv = min(svp + round(0.05*n), n);
        end

        if svp>=1
            S = S(1:svp)-1/(mu*eta);
        else
            svp = 1;
            S = 0;
        end

        A.U = U(:, 1:svp);
        A.s = S;
        A.V = V(:, 1:svp);

        Z{idx} = A.U*diag(A.s)*A.V';
        XZ = X{idx}*Z{idx};               


        % solving J
        temp = Z{idx}+Y2{idx}/mu;
        J{idx} = max(0, temp - lambda/mu) + min(0, temp + lambda/mu);
        J{idx} = max(0,J{idx});


        % solving E
        temp = X{idx}- XZ;
        temp = temp+Y1{idx}/mu;
        E{idx} = max(0, temp - garma/mu)+ min(0, temp + garma/mu);

        relChgZ = norm(Zk - Z{idx},'fro')/normfX;
        relChgE = norm(E{idx} - Ek,'fro')/normfX;
        relChgJ = norm(J{idx} - Jk,'fro')/normfX;
        relChg =   max( max(relChgZ, relChgE), relChgJ);

        dY1 = X{idx} - XZ - E{idx};
        recErr1 = norm(dY1,'fro')/normfX;
        dY2 =  Z{idx} - J{idx};
        recErr2 = norm(dY2,'fro')/normfX;
        recErr = max(recErr1, recErr2);

        convergenced = recErr <tol1  && relChg < tol2;

        if DEBUG
            if iter==1 || mod(iter,50)==0 || convergenced
                disp(['iter ' num2str(iter) ',mu=' num2str(mu) ...
                    ',rank(Z)=' num2str(svp) ',relChg=' num2str(relChg)...
                    ',recErr=' num2str(recErr)]);
            end
        end

        if convergenced
            break;
        else
            Y1{idx} = Y1{idx} + mu*dY1;
            Y2{idx} = Y2{idx} + mu*dY2;

            if mu*relChg < tol2
                mu = min(max_mu, mu*rho);
            end
        end
    end
end



