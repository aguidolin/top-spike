function exchangeSL = generate_exchwithinSL_stats(structSL, N_times)
%   EXCHANGESL = GENERATE_EXCHWITHINSL_STATS(structSL, N_TIMES)
%
%   Use on input struct of the type  one0_SL
%
%   INPUT:
%       structSL     structure with fields 'spikes' and 'labels',
%                    like one0_SL 
%       N_times      repetitions in the generation process
%
%   OUTPUT:
%       exchangeSL   structure with fields 'spikes' and 'labels',
%                    containing synthetic generated spike trains (shuffle exchange technique)
%                    
%
%   Notes:
%   
%   exchangeSL.spikes{1, gr_count}
%   exchangeSL.labels{1, gr_count}
%
%   Note: this function is for a structure N_times x N_groups cells
%   Note: this function is similar to generate_exchangeSL,
%         but spike times are exchanged only within the same collection of
%         64 responses (exchanges across collections are now forbidden) 
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
exchangeSL = struct;

exchangeSL.spikes = cell(N_times,N_groups);
exchangeSL.labels = cell(N_times,N_groups);



%Count number of spikes of each neuron in each response.
%Save all spike times in a "bag of spikes", grouped by the neurons that
%fired them


N_spikes_resp = cell(1,N_groups);

bag_spikes = cell(N_selected,N_groups);

shuffled_bag_spikes = cell(N_selected,N_groups);


for gr_count = 1 : 80
 
    for k_resp = 1 : size(structSL.spikes{1, gr_count},2)
        
        resp_spikes = structSL.spikes{1, gr_count}{k_resp};
        resp_labels = structSL.labels{1, gr_count}{k_resp};
        
        spkcount = zeros(1,N_selected);
        
        for ii = 1 : N_selected
            
            mask_labels = resp_labels==list_units(ii);
            
            bag_spikes{ii,gr_count} = [bag_spikes{ii,gr_count}, resp_spikes(mask_labels)]; 
            
            spkcount(ii) = sum(mask_labels);
            
        end            
        
        
        N_spikes_resp{gr_count}{k_resp} = spkcount;
        
    end
    
    
    %Now we have for each group a small "bag of spikes"  bag_spikes{ii,gr_count}
    %with gr_count fixed (counter of groups) and ii is the ii-th of the 4
    %neurons
    
    %Randomly permute the spike times in the "bag of spikes", to generate a
    %"bag of shuffled spikes" (from which to draw spikes sequentially, which is
    %equivalent to randomly pick them from the original bag).
    %NOTE: we do this permutation within each group!

    
    %shuffled_bag_spikes = cell(N_times,N_selected);

    for k_time = 1 : N_times
    
        for ii = 1 : N_selected

            s = randperm(length(bag_spikes{ii,gr_count}));

            shuffled_bag_spikes{ii,gr_count}{1, k_time} = bag_spikes{ii,gr_count}(s);

        end   
    
    end
    
    %Now we have for each group a small "shuffled bag of spikes" (divided into four compartments):  
    %shuffled_bag_spikes{ii,gr_count}  is a permutation of the spikes of  bag_spikes{ii,gr_count} 
    
    %Draw spikes from the bag of spikes

    for k_time = 1 : N_times

        count = zeros(1,N_selected); %count how many spikes we have drawn (for each neuron)

        for k_resp = 1 : size(structSL.spikes{1, gr_count},2)

            spikes = [];
            labels = [];        

            for ii = 1 : N_selected

                %randomly pick from the "bag of spikes" a quantity of spikes of the neuron list_units(ii)
                %equal to the number N_spikes_resp{gr_count}{k_resp}(ii) 

                n_drawn_ii = N_spikes_resp{gr_count}{k_resp}(ii);

                if n_drawn_ii ~= 0

                    new_spikes_ii = shuffled_bag_spikes{ii,gr_count}{1, k_time}(count(ii)+1 : count(ii)+n_drawn_ii);

                    new_labels_ii = list_units(ii)*ones(1,n_drawn_ii);

                    spikes = [spikes new_spikes_ii];  
                    labels = [labels new_labels_ii];

                    count(ii) = count(ii) + n_drawn_ii;

                end

            end

            [sorted_spikes, I] = sort(spikes);
            sorted_labels = labels(I);

            exchangeSL.spikes{k_time, gr_count}{k_resp} = sorted_spikes;
            exchangeSL.labels{k_time, gr_count}{k_resp} = sorted_labels;

        end
    
    end
  
end


exchangeSL.selectedClusters = structSL.selectedClusters;
exchangeSL.selectedClusters_m = structSL.selectedClusters_m;

end