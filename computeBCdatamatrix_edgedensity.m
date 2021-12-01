function [BCmatrix, BC_mean, BC_std] = computeBCdatamatrix_edgedensity(BC_filename) 
%[BCmatrix, BC_mean, BC_std] = computeBCdatamatrix_edgedensity(BC_filename)    
%Computes a data matrix with Betti curves (for computing average and std dev)
%
%   INPUT:
%   BC_filename  name of the cell array with Betti curves, e.g. "BCincr_80exp"
%   
%   
%
%   OUTPUT:
%   BCmatrix  cell array with matrices of Betti curves:
%             BCmatrix{jj, k_betti}{r,s}  is a  1210 x N_groups matrix
%             with Betti curves on columns (each column corresponds to a group,
%             so there are typically 80 columns).
%   
%             jj is the step in the "adding neurons" process (jj=1 means all selected neurons are present)
%             k_betti is the dimension of Betti numbers, typically 1,2,3
%             r is the index for k, typically k =[0,1]
%             s is the index for q, typically q = [1 2 5 10 20 50 100 200]  
%
%   BC_mean   cell array with vectors of mean Betti curves:
%             BC_mean{jj, k_betti}{r,s}  is a  1 x 1210 vector
%
%   
%   BC_std    cell array with vectors of std deviations of Betti curves:
%             BC_std{jj, k_betti}{r,s}  is a  1 x 1210 vector
%
% Andrea Guidolin (11 Nov 2021)
%--------------------------------------------------------------------------


BC = load(BC_filename);

lk = size(BC.(BC_filename){1, 1},1); %length of k
lq = size(BC.(BC_filename){1, 1},2); %length of q

N_select = size(BC.(BC_filename),1); %N selected neurons (typically 4)
N_groups = size(BC.(BC_filename),2); %N groups (typically 80)

max_betti = 3; %max dimension of Betti numbers (typically 3)

xmax = 1210; %max length of Betti curve


BCmatrix = cell(N_select, max_betti);

for jj = 1 : N_select   

    for k_betti = 1 : max_betti
        
        for r = 1 : lk
            for s = 1 : lq

                BCmatrix{jj, k_betti}{r,s} = zeros(xmax, N_groups);

                for gr_count = 1 : N_groups
                    
                    

                    Bcurve = BC_rescale_edgedensity(BC.(BC_filename){jj, gr_count}{r, s});
                    
                    %check to correct size error in Betti curves
                    %(replaces non-existing curve by vector of zeros)
                    if size(Bcurve,2) < max_betti
                        Bcurve_bis = zeros(1210, max_betti);
                        s1Bcurve = size(Bcurve,1);
                        s2Bcurve = size(Bcurve,2);
                        Bcurve_bis(1:s1Bcurve, 1:s2Bcurve) = Bcurve;
                        Bcurve = Bcurve_bis;
                    end
                    
                    BCmatrix{jj, k_betti}{r,s}(:,gr_count) = Bcurve(:,k_betti);
                    
                end
                
            end
        end
        
    end
    
end



%COMPUTE MEAN AND STD OF MATRICES IN BCMATRIX (AS OPTIONAL OUTPUTS)

BC_mean = cell(N_select, max_betti);
BC_std = cell(N_select, max_betti);

for jj = 1 : N_select   
    for k_betti = 1 : max_betti        
        for r = 1 : lk
            for s = 1 : lq

                BC_mean{jj, k_betti}{r, s} = mean(BCmatrix{jj, k_betti}{r, s}', 1);
                BC_std{jj, k_betti}{r, s}  = std(BCmatrix{jj, k_betti}{r, s}',0,1);
                
            end
        end       
    end    
end


end


