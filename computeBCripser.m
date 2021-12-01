function BC = computeBCripser(A, varargin)
%BC = COMPUTEBCRIPSER(A, varargin)
%
%   Input: A    square matrix (distance or dis-similarity matrix)
%   
%   Output: BC  Betti curves for beta1, beta2 and beta3 (dimension of homology 1,2,3)
%
%   Optional arguments:
%   'edge density': a number between 0 and 1 to set a threshold on the
%                   relative number of edges added to the filtration of simplicial
%                   complexes associated with A
%
%   'enumeration': 'decr' to compute Betti curves of the decreasing filtration (entries of the input matrix enumerated decresignly)
%                  ['incr' (default) to compute Betti curves of the increasing filtration]
%
%
%   EXAMPLES of use:  
%       BC = computeBCripser(A);
%       BC = computeBCripser(A, 'enumeration', 'decr');
%       BC = computeBCripser(A, 'edge_density', 0.8, 'enumeration', 'decr');
%
%
%   
%   REQUIRED: Ripser, by Ulrich Bauer (https://github.com/Ripser/ripser)
%   C++ code for fast computation of Vietoris–Rips persistence barcodes
%
%   ACKNOWLEDGEMENT:
%   This function contains a portion of code adapted from a Matlab wrapper around Ripser
%   by Chris Tralie, available at: https://github.com/ctralie
%
% Andrea Guidolin (11 Nov 2021)
%---------------------------------------------



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
    
    error('computeBCripser() error: calling convention {''key'', value, ... } error');
    
end



% Default value for max_edge_density is 0.6
% This is the point at which the filtration stops.

if isfield(g, 'edge_density') 
    max_edge_density = g.edge_density;
else
    max_edge_density = 0.6; 
end



% thresh is computed from max_edge_density
% It is the ordinal of the edge which, when added to the filtration, causes the edge
% density of the graph to cross the value max_edge_density

thresh = ceil(max_edge_density*size(A,1)*(size(A,1)-1)/2);



% Put into a vector v the entries of the upper tiangular part of A
% (excluding diagonal), ordered lexicographically by row and then by column

At = A.';
m  = (1:size(At,1)).' > (1:size(At,2));
v  = At(m);

% Enumerate the entries of v, based on the ordering.
% 'incr' (default): increasing enumeration: smallest entry is replaced by '1', second smallest by '2', etc. 
% 'decr': decreasing enumeration: largest entry is replaced by '1', second largest by '2', etc.

if isfield(g, 'enumeration') && strcmp(g.enumeration, 'decr')
    [~, I] = sort(v,'descend');
    [~, J] = sort(I);
else
    [~, I] = sort(v);
    [~, J] = sort(I); 
end




% Write J (enumeration vector of upper triangular part of distance matrix)
% to txt file

dlmwrite('upperdist.txt', J, ',');


% Compute barcode using ripser. The output is the string cmdout
% Note the threshold value: it corresponds to 0.6 edge density

[~,cmdout] = system(sprintf('~/ripser/ripser --format upper-distance --dim 3 --threshold %d upperdist.txt', thresh));

delete('upperdist.txt');


% Read the barcode (or persistence diagram) from the output of ripser and 
% store it as a cell array PD.
% The portion of code below is adapted from a Matlab wrapper around ripser
% coded by Chris Tralie: https://github.com/ctralie

lines = strsplit(cmdout, '\n');
PD = {};
for ii = 1:length(lines)
    if length(lines{ii}) < 4
        continue
    end
    if strcmp(lines{ii}(1:4), 'dist')
        continue
    elseif strcmp(lines{ii}(1:4), 'spar')
        continue    
    elseif strcmp(lines{ii}(1:4), 'valu')
        continue
    elseif strcmp(lines{ii}(1:4), 'pers')
        PD{end+1} = {};
    else
        s = strrep(lines{ii}, ' ', '');
        s = strrep(s, '[', '');
        s = strrep(s, ']', '');
        s = strrep(s, '(', '');
        s = strrep(s, ')', '');
        fields = strsplit(s, ',');
        PD{end}{end+1} = str2double(fields);
    end
end
for ii = 1:length(PD)
    PD{ii} = cell2mat(PD{ii}');
end


% Compute Betti curves from persistence diagrams.

x_max = thresh;   %set the max value along x axis to the threshold

BC = zeros(x_max,3);
for n_betti = 1:3
    for jj = 1 : size(PD{n_betti+1},1)
        birth = PD{n_betti+1}(jj,1);
        death = PD{n_betti+1}(jj,2);
        if isnan(death)
            death = x_max + 1;
        end
        BC(birth:death-1, n_betti) = BC(birth:death-1, n_betti) + ones(death-birth, 1);    
    end           
end
        

end