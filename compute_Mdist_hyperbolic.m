function M = compute_Mdist_hyperbolic(n,d,Rmax,Rmin)
%COMPUTE_MDIST_HYPERBOLIC Compute distance matrix of uniform points sampled in
%   hyperbolic space with the 1st method described in the script 
%   comparison_sampling_hyperbolic.m
%
%   Input:
%   n     number of points
%   d     dimension of the space
%   Rmax  dimension of the max radius of the disc
%   Rmin  dimension of the max radius of the disc (must be < Rmax)
%
%   Output:
%   M     symmetric matrix of distances between the n sampled points
%
% Andrea Guidolin (11 Nov 2021)
%-------------------------------------------------------------------------



% Sample n radii within [Rmin, Rmax] with distribution ~ sinh((d-1)x)
% (Inverse transform sampling)

u = rand(1,n);
x = acosh(u*(cosh((d-1)*Rmax)-cosh((d-1)*Rmin)) + cosh((d-1)*Rmin))/(d-1); 



% Sample n points uniformly on the (d-1)-sphere

tmp = randn(d,n);
mag = sqrt(sum(tmp.^2));
dm = diag(1./mag);
P = (tmp*dm)';  % sampled points on the (d-1)-sphere



% Sample points in the hyperbolic space (Poincaré d-ball model):
% scale each point on the (d-1)-sphere by the corresponding radius

PP = zeros(n,d);

for ii = 1:n
    
    PP(ii,:) = x(ii)*P(ii,:);

end



% Compute distance matrix:
% distance is defined as in formula (2) of the article
% [Zhou, Y., Smith, B. H., & Sharpee, T. O. (2018). Hyperbolic geometry of the olfactory space. Science advances, 4(8)]

M = zeros(n);

for ii = 1:n
    for jj = ii+1:n
        
        r1 = x(ii);  %radius of the point PP(ii,:)
        r2 = x(jj);  %radius of the point PP(jj,:)

        dist = real(acosh(cosh(r1)*cosh(r2)-sinh(r1)*sinh(r2)*(dot(PP(ii,:),PP(jj,:))/(norm(PP(ii,:))*norm(PP(jj,:))))));
        
        M(ii,jj) = dist;
        M(jj,ii) = dist;
        
    end
end


end

