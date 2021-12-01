function firingFr = compute_firingFr(structSL)
%   FIRINGFR = COMPUTE_FIRINGFR(structSL)
%
%   Use on input struct of the type  one0_SL
%
%   INPUT:
%       structSL     structure with fields 'spikes' and 'labels',
%                    like one0_SL 
%
%   OUTPUT:
%       firingFr     vector with firing frequencies of the neurons of
%                    structSL.selectedClusters   
%
%   Notes:
%   
%   The vector firingFr is a required input of the function
%   generate_PoissonSL
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------


%Number of units of the SL structure, 
N_selected = length(structSL.selectedClusters);  
%and list of their "names" (numbers as in the original SPKTs data set)
list_units = structSL.selectedClusters;

%Number of groups (of 64 responses each, including empty ones)
N_groups = size(structSL.spikes,2);


spikeCount = zeros(1, N_selected);


for gr_count = 1 : N_groups 

    for k_resp = 1 : size(structSL.spikes{1, gr_count},2)

        x = structSL.labels{1, gr_count}{k_resp};

        y = zeros(1, N_selected);

        for ii = 1 : N_selected
            y(ii) = sum(x==list_units(ii));
        end

        spikeCount = spikeCount + y;

    end
end



%   Frequency (in Hz = spikes per second) is computed dividing the number
%   of spikes by the total time (in seconds). 
%
%   When there are no empty responses in the original data, the total time
%   is obtained as 80 (groups) * 64 (responses) * 0.32 (duration of each response).
%
%   Here we want to determine the total time only of non zero responses

tot_nzr = 0; %total number of non-zero resp in the 80 groups
tot_one0resp = 0; %how many groups have the only allowed zero response

for gr_count = 1 : N_groups 
 
    tot_nzr = tot_nzr + size(structSL.spikes{1, gr_count},2);
    
    if isempty(structSL.spikes{1, gr_count}{end})
        tot_one0resp = tot_one0resp + 1;
    end
    
end

tot_nzr = tot_nzr - tot_one0resp; 


%Now we can compute the total time (of the non-zero responses)

totalTime = tot_nzr * 0.32;  %s

%and the firing frequency of the selected neurons (considering only non-zero resp)

firingFr = spikeCount / totalTime;


end