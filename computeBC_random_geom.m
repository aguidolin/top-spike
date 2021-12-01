% Computation of Betti curves of random and geometric models.
%
% Compute k times the Betti curves of n-by-n matrices associated with the following 
% geometric and random models:
%
% - Euclidean geometry model: n random points are uniformly sampled in a unit 
%   (hyper)cube within the d-dimensional Euclidean space
%
% - Hyperbolic geometry model: n random points are uniformly sampled in a 
%   d-dimensional hyperbolic space using the hyperbolic ball model (with a
%   choice of the parameter Rmax)
%
% - Random matrices: an n-by-n random symmetric matrix with zeros on the main diagonal 
%   is generated 
%
%
% Andrea Guidolin (11 Nov 2021)
%-------------------------------------------------------------------------


n = 64;            %number of points / size of the matrices
k_iter = 300;      %number of computations

Rmin = 0;

list_Rmax = 1:10;  %Rmax parameter for hyperbolic ball model
list_d = 1:15;     %dimension of geometric spaces


BCdecr_eucl = cell(1,length(list_d));
BCincr_eucl = cell(1,length(list_d));

BCdecr_hyp = cell(length(list_Rmax),length(list_d));
BCincr_hyp = cell(length(list_Rmax),length(list_d));

BCdecr_randsym = cell(1,1);
BCincr_randsym = cell(1,1);




for jj = 1:length(list_d)

    d = list_d(jj);
       
    BCdecr_eucl{1,jj} = compute_manyBC_eucl(n,d,k_iter,'decr');
    BCincr_eucl{1,jj} = compute_manyBC_eucl(n,d,k_iter,'incr');
    
    for ii = 1:length(list_Rmax)
        
        Rmax = list_Rmax(ii); 

        BCdecr_hyp{ii,jj} = compute_manyBC_hyp(n,d,Rmax,Rmin,k_iter,'decr');
        BCincr_hyp{ii,jj} = compute_manyBC_hyp(n,d,Rmax,Rmin,k_iter,'incr');
        
        fprintf('  Rmax %d\n',Rmax)

    end
    
    fprintf('Dimension %d\n',d)
end


BCdecr_randsym{1,1} = compute_manyBC_randsym(n,k_iter,'decr');
BCincr_randsym{1,1} = compute_manyBC_randsym(n,k_iter,'incr');


save('BCdecr_eucl','BCdecr_eucl')
save('BCincr_eucl','BCincr_eucl')

save('BCdecr_hyp','BCdecr_hyp')
save('BCincr_hyp','BCincr_hyp')

save('BCdecr_randsym','BCdecr_randsym')
save('BCincr_randsym','BCincr_randsym')