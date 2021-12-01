function [one0_SL] = select_one0(filename, n_resp, N_groups, N_selected, varargin)
%one0_SL = SELECT_ONE0(filename, n_resp, N_groups, N_selected, varargin)
%
%   EXAMPLES of use:  
%       one0_SL = select_one0("L7306_TT4_btc_SPKTs", 64, 80, 4)
%       one0_SL = select_one0("L7306_TT4_btc_SPKTs", 64, 80, 4, 'includeClusters', 1)
%
%   INPUT:
%       filename       e.g. "L7306_TT4_btc_SPKTs"
%       n_resp         number of responses per group, typically 64
%       N_groups       number of groups (of 64 responses each) to select (out of 160, axis/trial/strength)
%                       by highest number of non-zero responses                    
%       N_selected     number of neurons we select
%
%       Optional:
%       'includeClusters' {0,1}   if 1 (true) clusters (e.g. 'm1') are
%                                 considered as individual neurons
%
%   OUTPUT:
%       one0_SL        structure containing spike trains and labels of the
%                      N_selected most active (participate in largest number of non-zero resp) neurons
%                      for N_groups groups.
%                      one0_SL.selectedClusters is a vector of labels (neurons/clusters) ordered by most active
%                      one0_SL.selectedClusters_m is a cell array where clusters are indicated by e.g. 'm1' instead of '1'
%   
%   More details:
%
%   The optional argument 'includeClusters' allows one to choose whether
%   clusters generated during the spike sorting of the original data
%   (labeled starting with 'm', e.g. 'm1', in the original datasets) are
%   considered or not
%
%   Criterion to choose the groups:
%   Pick the N_groups groups with the highest number of non-zero resp
%   To break ties within the same class (same number of non-zero resp):
%   random choice
%
%   Criterion to choose the non-zero resp within the selected groups:
%   Randomly pick nzr_thresh non-zero resp for each of the selected groups
%
%
%   We save only spikes S and labels L (output of spikes_and_labels.m, which are
%   what we'll need later to compute VP multi-neuron distance) for the N_selected neurons 
%   in a struct one0_SL.mat
%
%   The struct one0_SL.mat contains
%   the spike times S (1 x n_resp  cell array, e.g. 1x64) 
%   and the labels L (1 x n_resp  cell array, e.g. 1x64)  
%   for each of the N_groups groups (index "k_group")
%   (S, L computed with function spikes_and_trains.m)
%
%
%       one0_SL.spikes{k_group}{ii} = array (row) of spike
%                                       times of the ii reponse 
%       one0_SL.labels{k_group}{ii} = array (row) of neuron
%                                       labels of the ii reponse
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------------------


% Read optional arguments
try
    
    options = varargin;
    for index = 1 : length(options)
        if iscell(options{index}) && ~iscell(options{index}{1})
            options{index} = { options{index} };
        end
    end
    if ~isempty( varargin )
        g = struct(options{:});
    else
        g = [];
    end
    
catch
    
    error('Select_nzr() error: calling convention {''key'', value, ... } error');
    
end



axs = ["R", "G", "B", "C", "D", "E", "T", "U", "V", "W", "A"];
%trials = [1 2 3 4];
strengths = ["m2", "m1", "p1", "p2", "mp0"];

one0_SL = struct;

Struct_data = load(filename);



%number of neurons
N_neurons = size(Struct_data.SPKTs.EXPV.Clusters,2); 

if N_selected > N_neurons
   N_selected = N_neurons;
   fprintf('Warning: N_selected > N_neurons, so all neurons are selected.\n')
end




%This depends on the optional input 'includeClusters'
if isfield(g, 'includeClusters') && g.includeClusters
    v_noCl = ones(1, N_neurons);  
else
    v_noCl = ones(1, N_neurons);
    for ii = 1 : N_neurons
        if Struct_data.SPKTs.EXPV.Clusters{1, ii}(1) == 'm'
            v_noCl(ii) = 0;
        end
    end
end




%number of neurons (NOT CLUSTERS, except if 'includeClusters' is true)
N_neur_noCl = sum(v_noCl(:) == 1);

if N_selected > N_neur_noCl
   N_selected = N_neur_noCl;
   fprintf('Warning: N_selected > N_neur_noCl (#neurons, excluding clusters), so all neurons (excluding clusters) are selected.\n')
end


gr_count = 0;  %here counts the groups (out of 160) with 64 non-zero responses 



%To count non-zero responses for each neuron (including clusters):

neurons = 1:N_neurons;

% Generate matrix Y with
% Y(gr_count,:) = [N_nzr, k_axis, trial, k_strength, random_entry] and
% additional N_neurons coulmns with numbers of non-zero resp for each

for k_axis = 1:10   

    axis = axs(k_axis + 1);    %default 2:end

    for trial = 1:4

        for k_strength = 1:4

            strength = strengths(k_strength);

            [S, L] = spikes_and_labels(Struct_data, axis, trial, strength);

            gr_count = gr_count + 1;

            N_nzr = size(S,2); %number (out of 64) of non-zero responses

            %random entry in 5th column, to break ties randomly when using sortrow
            random_entry = rand(1);  

            %count non-zero resp in each set of 64 stimuli for each neuron 
            nzr_each_neuron = zeros(1,N_neurons);
            
            %Count non-zero responses for each neuron:
            for ii = 1:N_nzr
                spiking_neurons = ismember(neurons,L{ii});
                nzr_each_neuron = nzr_each_neuron + spiking_neurons;
            end

            Y(gr_count,:) = [[N_nzr, k_axis, trial, k_strength, random_entry], nzr_each_neuron];
            %Note: columns from 6th (5+1) to (5+N_neurons)th of Y contain
            %numbers of non-zero resp fo all neurons, from 1 to N_neurons

        end
    end
end  

%Number of non-zero resp for each neuron, total over 160 groups
nzr_each_neuron_tot = sum(Y(:, 6:5+N_neurons));



%Sort the rows of Y based on the elements in the first column, 
%and look to the fifth column (random_entry) to break any ties.

YY = sortrows(Y,[1 5],'descend');

%Keep only the first N_groups rows, corresponding to the N_groups (e.g. 80) groups
%with max number of non-zero resp

YY_groups = YY(1:N_groups,1:end);



%Select label numbers corresponding to the N_selected most active neurons
%(excluding clusters)

labels = 1:N_neurons;
labels_noCl = labels(logical(v_noCl));

[~ , I] = sort(sum(YY_groups(:, 5 + labels_noCl)), 'descend');
labels_mostactive_noCl = labels_noCl(I);
labels_mostactive_noCl = labels_mostactive_noCl(1:N_selected);

for k_group = 1:N_groups
    v = YY_groups(k_group,:);
    N_nzr = v(1);
    axis = axs(v(2)  + 1);
    trial = v(3);
    strength = strengths(v(4));

    [S, L] = spikes_and_labels(Struct_data, axis, trial, strength);
    
    %Compare L with labels_mostactive_noCl (the labels of the most active neurons we
    %want to consider)
    
    v_Lselection = [];
    for jj = 1:N_nzr
        labels_mostactive_noCl_jj = ismember(labels_mostactive_noCl, L{jj}); %returns vector true/false for which labels in labels_mostactive_noCl are present in the resp L{jj}
        if sum(labels_mostactive_noCl_jj(:)) > 0   %this happens if at least one of the "most active selected neurons" fires in response L{jj}
            v_Lselection = [v_Lselection jj];
        end
    end
    

    selected_nzr = v_Lselection;
    
    
    %Select only spikes and labels corresponding to labels_mostactive_noCl
    % (the labels of the N_selected most active neurons we want)
    
    for ii = 1 : length(selected_nzr)
        
        v_labels_all = L{selected_nzr(ii)}; %vector of all labels (each for one spike) of the fixed response
        
        v_labels_mask = ismember(v_labels_all, labels_mostactive_noCl); %logical vector: entries of v_labels_all that are present in labels_mostactive_noCl

        one0_SL.spikes{k_group}{ii} = S{selected_nzr(ii)}(v_labels_mask);
        
        one0_SL.labels{k_group}{ii} = v_labels_all(v_labels_mask);
        
    end
    
    %We want to 'collapse' all zero responses to just one:
    %Check if there are any (that is, there are less than 64 non-zero resp)
    %and in this case add one additional empty response
    if length(selected_nzr) < n_resp
        one0_SL.spikes{k_group}{end + 1} = [];
        one0_SL.labels{k_group}{end + 1} = [];
    end
end


%Save in the structure the vector of labels of selected most active
%neurons. For reference and also to avoid renaming the labels of
%one0_SL.labels  as, for instance, 1,2,3,4.
one0_SL.selectedClusters = labels_mostactive_noCl;

%Same as one0_SL.selectedClusters but as a cell array that contains strings.
%This is because, if we include clusters like 'm1', we want it to appear here
%as 'm1' instead of '1' (keep the info that it is a cluster, not an individual neuron)
one0_SL.selectedClusters_m = Struct_data.SPKTs.EXPV.Clusters(labels_mostactive_noCl);


one0_SL.summary80groups = YY_groups;

end