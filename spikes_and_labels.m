function [S, L] = spikes_and_labels(Struct_data, axis, trial, strength)
%       Produces one array of spikes and one of labels for a (multi)neural
%       response.
%       Useful for producing the input of labdist_faster_qkpara_opt
%
% Andrea Guidolin (11 Nov 2021)
%------------------------------------------------------------------



%FIND ZERO RESPONSES
N_clusters = length(Struct_data.SPKTs.EXPV.Clusters); %number of clusters (units)
w = []; 
for stimulus = 1:64
    cluster = 1;
    while Struct_data.SPKTs.(axis)(trial).(strength).spkTimes{1, cluster}{1, stimulus}(1) == 0  %check if the first entry is 0
        if cluster == N_clusters
            w = [w stimulus];
            break
        else
            cluster = cluster + 1;
        end
    end
end

%FIND NON-ZERO RESPONSES
v = setdiff(1:64, w);

l = length(v);
M = zeros(l);


A = cell(1, l); %matrix_of_trains
N_of_spikes = zeros(1, l);
S = cell(1, l); %spikes 
L = cell(1, l); %labels
for jj = 1:l 
    stimulus_position = v(jj);    
    N_clusters = length(Struct_data.SPKTs.EXPV.Clusters); %number of clusters (units)
    C = Struct_data.SPKTs.(axis)(trial).(strength).spkTimes{1,1}{1,stimulus_position}; 
    X = C';  %row vector
    n_columns = length(X);
    for ii = 2:N_clusters
        c = Struct_data.SPKTs.(axis)(trial).(strength).spkTimes{1,ii}{1,stimulus_position};
        r = c';  %row vector
        if length(r) > n_columns
            T = X;
            X = zeros(ii,length(r));
            X(1:ii-1,1:n_columns) = T;
            X(ii,:) = r;
            n_columns = length(r);
        else
            X(ii,:) = [r zeros(1,n_columns-length(r))];
        end
    end
    A{jj} = X;
    N_of_spikes(jj) = nnz(X);
    
    spikes = nonzeros(X'); %array of non-zero elements ordered by rows of X (columns of X')
    
    mask = X~=0; 
    G = zeros(size(X,1),size(X,2));
    for ii = 1:size(X,1)
        G(ii,:) = ii*mask(ii,:);  %matrix G is obtained from X by replacing non-zero elements with the index of the row
    end
    labels = nonzeros(G'); %array of non-zero elements ordered by rows of G (labels)

    %sort the vectors  spikes, labels  to obtain the sought vectors
    [sorted_spikes, I] = sort(spikes);
    sorted_labels = labels(I(:));
    
    S{jj} = sorted_spikes';
    L{jj} = sorted_labels';
end