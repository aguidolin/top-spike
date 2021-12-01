function BC = computeBCripser_fulldataset_incr(arrayVPM)
%   BC = COMPUTEBCRIPSER_FULLDATASET_INCR(arrayVPM)
%
%   INPUT:
%       VPM          cell array with Victor Purpura distance matrices
%
%   OUTPUT:
%       BC           cell array with Betti curves
%
%   Notes:
%   
%   VPM{jj, gr_count} contains the VP matrices computed from
%                     one0_SL.spikes{jj, gr_count}, for all choices of
%                     parameters of the Victor-Purpura distance
%   
%   BC{jj,gr_count}   contains the associated Betti curves, for the Betti
%                     numbers beta1, beta2 and beta3
%
%   Each BC{jj, gr_count}{r,s} contains the Betti curves for the r-th entry of k
%       and the s-th entry of q  (k,q vectors of parameters for the Victor-Purpura distance,
%       specified before computing VPM)
%
%   NOTE: uses  computeBCripser(A,'enumeration','incr')
%   to compute the increasing filtration
%
%   Required: Ripser, by Ulrich Bauer (https://github.com/Ripser/ripser)
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------


lk = size(arrayVPM{1, 1},1);
lq = size(arrayVPM{1, 1},2);

%number of groups of responses in the input structure
N_groups = size(arrayVPM,2);

%number of steps in the (optional) process of "adding neurons" (number of selected neurons)
N_selected = size(arrayVPM,1);

%output cell array, containing Betti curves
BC = cell(N_selected,N_groups);



%Add to VP distance matrix a small random noise to break "ties" (entries
% with equal values) before computing Betti curves.
%Compute a random noise matrix for every group, but use the same for all
% the N_selected VP matrices of a fixed group
n_resp = 64;
Xnoise = cell(1, N_groups);
for gr_count = 1 : N_groups
    A = rand(n_resp);
    %random noise (symmetric matrix with 0s on main diagonal)
    Xnoise{gr_count} = triu(A,1) + triu(A,1)'; 
end





for jj_addn = 1 : N_selected
    
    for gr_count = 1 : N_groups   %parfor: problem with matrix_simplices.txt
        
        VPMfixIndx = arrayVPM{jj_addn,gr_count};
        
        sizeVPMfixIndx = size(VPMfixIndx{1,1},1); %to select square submatrix of Xnoise of appropriate size 
        
        BCfixIndx = cell(lk,lq); 
        
        
        
        for r = 1:lk
            for s = 1:lq
                BCfixIndx{r,s} = computeBCripser(VPMfixIndx{r,s} + ...
                    0.00001*Xnoise{gr_count}(1:sizeVPMfixIndx,1:sizeVPMfixIndx), ...
                    'enumeration', 'incr');      
            end
        end

        fprintf('Computed: (%d of %d),  group  %d of %d \n', jj_addn, N_selected, gr_count, N_groups);  
        
        BC{jj_addn,gr_count} = BCfixIndx;

    end  
end

end