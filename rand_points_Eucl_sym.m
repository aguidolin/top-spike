function X = rand_points_Eucl_sym(n,d)
%RAND_POINTS_EUCL_SYM  Symmetric matrix (with null diagonal entries) of Euclidean 
%   distances between n points randomly picked in a d-dimensional unit
%   cube.
%   
%   X = RAND_POINTS_EUCL_SYM(n,d) is a symmetric random n-by-n matrix with 0s on the main
%       diagonal
%
%   n number of points
%   d dimension of the affine space where we randomly sample points in a 
%       unit cube (0,1)^d
%
% Andrea Guidolin (11 Nov 2021)
%-------------------------------------------------

M = rand(n,d); % matrix of the random points (rows)
A = zeros(n);
for ii = 1:n
    for jj = ii+1:n
        A(ii, jj) = norm(M(ii,:)-M(jj,:));  % Euclidean distance
    end
end    
X = A + A';
end

