function VPM = computeVPMpara(structSL, k, q)
%   VPM = COMPUTEVPMPARA(structSL, k, q)
%
%   Parallel computation of Victor-Purpura distance matrices
%
%   INPUT:
%       structSL     structure with fields 'spikes' and 'labels',
%                    like one0_SL
%       
%       k            vector of values for VP distance, e.g. k = [0 1]
%        
%       q            vector of values for VP distance, e.g. q = [1 2 5 10 20 50 100 200]
%
%   OUTPUT:
%       VPM          cell array with Victor Purpura distance matrices for
%                    the input structure.
%
%   Notes:
%   
%   VPM{jj, gr_count} contains the VP matrices computed from structSL.spikes{jj, gr_count}
%   
%   Each VPM{jj, gr_count}{r,s} contains the VP matrix for the r-th entry of k
%       and the s-th entry of q
%
%
%   Acknowledgement:
%   
%   The function labdist_faster_qkpara_opt.m by Thomas Kreuz (based on code
%   by Dmitriy Aronov) is used to compute the Victor-Purpura distance
%   between spike trains. The function is available:
%   http://www-users.med.cornell.edu/~jdvicto/labdist_faster_qkpara_opt.html 
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------


lk = length(k);
lq = length(q);

%number of groups of responses in the input structure
N_groups = size(structSL.spikes,2);

%number of selected neurons
N_selected = size(structSL.spikes, 1);

%output structure, storing Victor Purpura distance matrices
VPM = cell(N_selected,N_groups);



for jj_addn = 1 : N_selected

    parfor gr_count = 1:N_groups  % this can be a for/parfor 
        
        nzr_thresh = size(structSL.spikes{jj_addn, gr_count},2);

        Cfixed = cell(lk,lq);
        for r = 1:lk
            for s = 1:lq
                Cfixed{r,s} = zeros(nzr_thresh);
            end
        end


        for ii_nzr = 1 : nzr_thresh
            %fprintf('Computing ii=%d\n',ii_nzr)
            for jj_nzr = ii_nzr+1 : nzr_thresh


                if isempty(structSL.spikes{jj_addn, gr_count}{ii_nzr}) && isempty(structSL.spikes{jj_addn, gr_count}{jj_nzr}) 
                    %we define the distance between two zero responses (empty lists [] of spikes) to be 0
                    D = zeros(lk,lq);
                else
                    D = labdist_faster_qkpara_opt(...
                    structSL.spikes{jj_addn, gr_count}{ii_nzr}, structSL.labels{jj_addn, gr_count}{ii_nzr}, ...
                    structSL.spikes{jj_addn, gr_count}{jj_nzr}, structSL.labels{jj_addn, gr_count}{jj_nzr}, ...
                    q, k);
                end




                for r = 1:lk
                    for s = 1:lq

                        Cfixed{r,s}(ii_nzr,jj_nzr) = D(r,s);
                        Cfixed{r,s}(jj_nzr,ii_nzr) = D(r,s);

                    end
                end

            end
        end
        VPM{jj_addn, gr_count} = Cfixed;
        fprintf('Computed group %d (%d of %d)\n', gr_count, jj_addn, N_selected)
    end

end

end