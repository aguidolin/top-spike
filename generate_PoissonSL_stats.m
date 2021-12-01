function PoissonSL = generate_PoissonSL_stats(structSL, firingFr, N_times)
%   POISSONSL = GENERATE_POISSONSL_STATS(structSL, firingFr)
%
%   Use on input struct of the type  one0_SL
%
%   INPUT:
%       structSL     structure with fields 'spikes' and 'labels',
%                    like one0_SL 
%       firingFr     vector of firing frequencies of all neurons
%                    of structSL 
%       N_times      number of times to repeat the generating process
%
%   OUTPUT:
%       PoissonSL    structure with fields 'spikes' and 'labels',
%                    containing Poisson generated spike trains
%                    
%
%   Notes:
%   
%   PoissonSL.spikes{k_time, gr_count}
%   PoissonSL.labels{k_time, gr_count}
%
%   Note: this function is for a structure N_times x N_groups cells
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------


%number of groups of responses in the input structure
N_groups = size(structSL.spikes,2);

%Number of units of the SL structure, 
N_selected = length(structSL.selectedClusters);  
%and list of their "names" (numbers as in the original SPKTs data set)
list_units = structSL.selectedClusters;


%output structure
PoissonSL = struct;

PoissonSL.spikes = cell(N_times,N_groups);
PoissonSL.labels = cell(N_times,N_groups);


%Count number of non-zero resp for each group of the input struc

% number of responses for each group (all non-zero, plus at most one empty response)
N_resp_groups = zeros(1,N_groups); 
% number of empty resp for each group (0 or 1)
N_one0_groups = zeros(1,N_groups); 

for gr_count = 1 : N_groups 
 
    N_resp_groups(gr_count) = size(structSL.spikes{1, gr_count},2);
    
    if isempty(structSL.spikes{1, gr_count}{end})
        N_one0_groups(gr_count) = 1;
    end
    
end


% number of non-zero resp for each group
N_nzr_groups = N_resp_groups - N_one0_groups;


%Now: produce Poisson spike trains for the non-zero responses in the original data
%(the only zero resp allowed is copied at the end in the groups that had it in the 
%original data)

for k_time = 1 : N_times

    for gr_count = 1:N_groups

        for k_nzr = 1:N_nzr_groups(gr_count)

            spikes = [];
            labels = [];



            for jj = 1 : N_selected
               %spikes/labels, using the input frequencies

               new_spikes = PoissonSpikeGen(firingFr(jj));
               new_labels = list_units(jj)*ones(1,length(new_spikes));

               spikes = [spikes new_spikes];  %list concatenation
               labels = [labels new_labels];

            end

            [sorted_spikes, I] = sort(spikes);
            sorted_labels = labels(I);

            PoissonSL.spikes{k_time, gr_count}{k_nzr} = sorted_spikes;
            PoissonSL.labels{k_time, gr_count}{k_nzr} = sorted_labels;

        end

        if N_one0_groups(gr_count)==1 
            PoissonSL.spikes{k_time, gr_count}{end+1} = [];
            PoissonSL.labels{k_time, gr_count}{end+1} = [];
        end

    end
    
    fprintf('Generated Poisson data %d\n', k_time);
    
end


PoissonSL.selectedClusters = structSL.selectedClusters;
PoissonSL.selectedClusters_m = structSL.selectedClusters_m;


end