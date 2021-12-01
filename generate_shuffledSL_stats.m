function shuffledSL = generate_shuffledSL_stats(structSL, N_times)
%   SHUFFLEDSL = GENERATE_SHUFFLEDSL_STATS(structSL)
%
%   Use on input struct of the type  nzr_SL
%
%   INPUT:
%       structSL     structure with fields 'spikes' and 'labels',
%                    like nzr_SL or nzr_SL_addn
%       N_times      number of times to repeat the generating process
%
%
%   OUTPUT:
%       shuffledSL   structure with fields 'spikes' and 'labels', generated
%                    by shuffling the spikes of the input 
%                    (but maintaining the sequence of labels!)
%                    
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------



%number of groups of responses in the input structure
N_groups = size(structSL.spikes,2);

%number of responses for each group in the input structure
%MODIFICATION: this number is variable now, it is assigne below
%nzr_thresh = size(structSL.spikes{1, 1},2);



%output structure
shuffledSL = struct;

shuffledSL.spikes = cell(N_times,N_groups);
shuffledSL.labels = cell(N_times,N_groups);




for gr_count = 1 : N_groups

    nzr_thresh = size(structSL.spikes{1, gr_count},2);

    for k_nzr = 1 : nzr_thresh

        N_spikes = length(structSL.spikes{1, gr_count}{k_nzr});

        new_spikes = 0.320 * rand(N_times, N_spikes);  %new spikes, uniformly dist. in [0, 0.320]

        for k_time = 1 : N_times
            
            new_spikes_sorted = sort(new_spikes(k_time, :));

            shuffledSL.spikes{k_time, gr_count}{k_nzr} = new_spikes_sorted;
            shuffledSL.labels{k_time, gr_count}{k_nzr} = structSL.labels{1, gr_count}{k_nzr};
            
        end
    end

end



shuffledSL.selectedClusters = structSL.selectedClusters;
shuffledSL.selectedClusters_m = structSL.selectedClusters_m;


end