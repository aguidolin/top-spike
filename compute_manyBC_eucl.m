function B = compute_manyBC_eucl(n,d,k,enum)
%COMPUTE_MANYBC_EUCL Compute k times the Betti curves of uniform points in
%a unit cube within Euclidean space.
%
%   B = compute_manyBC_eucl(n,d,k,enum)
%
%   Input:
%   n     number of points
%   d     dimension of the space
%   k     number of iterations
%   enum  'incr' or 'decr', for increasing or decreasing filtrations
%
%   Output:
%   B     cell array of Betti curves (k iterations) of n uniform points in
%         a unit cube within d-dimensional Euclidean space.
%         The Betti curves are computed using the clique topology method,
%         enumerating the entries of the distance matrix increasingly or
%         decreasingly according to enum.
%         For each k_betti = 1,2,3, B{1,k_betti} is an L-by-k matrix
%         with L the length of each Betti curve (e.g. 1210 if n=64 and edge_density=0.6)
%         and column j contains the Betti curve of degree k_betti of the j-th iteration  
%
%   Uses the following functions:
%   rand_points_Eucl_sym
%   computeBCripser
%
% Andrea Guidolin (11 Nov 2021)
%-------------------------------------------------------------------------


edge_density = 0.6; %default : 0.6


% Compute distance matrices
M = rand_points_Eucl_sym(n,d);  

% Compute Betti curves (first time, to know their length)
X = computeBCripser(M, 'edge_density', edge_density, 'enumeration', enum);

lengthX = size(X,1);

% Betti curves (cell array storing all iterations, divided by Betti number 1,2,3)    
B = {zeros(lengthX, k), zeros(lengthX, k), zeros(lengthX, k)};

for k_betti = 1:3
    B{1, k_betti}(:,1) = X(:,k_betti);
end

% Repeat k-1 times
    
for jj = 1:k-1
    M = rand_points_Eucl_sym(n,d);
    
    X = computeBCripser(M, 'edge_density', edge_density, 'enumeration', enum);  

    for k_betti = 1:3
        B{1, k_betti}(:,jj+1) = X(:,k_betti);
    end

end


end
