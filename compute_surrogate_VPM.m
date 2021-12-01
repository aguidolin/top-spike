% Compute the structures containing spike times and neuron labels
% for the four types of surrogate data we consider. Compute the
% Victor-Purpura distance matrices for the experimental and surrogate spike
% data.
%
% The starting point is the structure one0_SL.mat containing spike times
% and neuron labels of the selected experimental data.
%
% This script computes the structures containing spike times and neuron labels
% for the four types of surrogate data we consider:
% 1. Uniform resampling of spike times ("shuf")
%    one0_shufSL_stats
% 2. Exchange resampling of spike times between collections ("exchange")
%    one0_exchangeSL_stats
% 3. Exchange resampling of spike times within collections ("exchwithin")
%    one0_exchangeSL_stats
% 4. Poisson generated spike trains ("Poisson")
%    one0_exchwithinSL_stat
% 
% For each type of surrogate, the data is generated for (N_times = 20)
% computations
%
% After generating surrogate spike data, compute the Victor-Purpura distance matrices
%    VPM_shuf
%    VPM_exchange
%    VPM_exchwithin
%    VPM_Poisson
%
%
% Andrea Guidolin (11 Nov 2021)
%-------------------------------------------------------------------------

% EXPERIMENTAL DATA (80 GROUPS)
% The data we use for an individual dataset is contained in a stucture
% called "one0_SL"

load('one0_SL');


N_times = 20;  %number of computations

% parameters of the Victor-Purpura distance
k = [0 1];   %r  
q = [1 2 5 10 20 50 100 200];   %s


%compute Victor-Purpura distance matrices for experimental data
VPM_80exp = computeVPMpara(one0_SL, k, q);

fprintf('VPM_80exp: Done! \n');
save('VPM_80exp', 'VPM_80exp')



% UNIFORM RESAMPLING OF SPIKE TIMES


one0_shufSL_stats = generate_shuffledSL_stats(one0_SL, N_times);
save('one0_shufSL_stats', 'one0_shufSL_stats')

VPM_shuf = computeVPMpara(one0_shufSL_stats, k, q);

fprintf('VPM_shuf: Done! \n');
save('VPM_shuf', 'VPM_shuf')


% EXCHANGE BETWEEN COLLECTIONS


one0_exchangeSL_stats = generate_exchangeSL_stats(one0_SL, N_times);
save('one0_exchangeSL_stats', 'one0_exchangeSL_stats')

VPM_exchange = computeVPMpara(one0_exchangeSL_stats, k, q);

fprintf('VPM_exchange: Done! \n');
save('VPM_exchange', 'VPM_exchange')



% EXCHANGE WITHIN COLLECTION


one0_exchwithinSL_stats = generate_exchwithinSL_stats(one0_SL, N_times);
save('one0_exchwithinSL_stats', 'one0_exchwithinSL_stats')

VPM_exchwithin = computeVPMpara(one0_exchangeSL_stats, k, q);

fprintf('VPM_exchwithin: Done! \n');
save('VPM_exchwithin', 'VPM_exchwithin')



% POISSON DATA


firingFr = compute_firingFr(one0_SL);
one0_PoissonSL_stats = generate_PoissonSL_stats(one0_SL, firingFr, N_times);
save('one0_PoissonSL_stats', 'one0_PoissonSL_stats')

VPM_Poisson = computeVPMpara(one0_PoissonSL_stats, k, q);

fprintf('VPM_Poisson: Done! \n');
save('VPM_Poisson', 'VPM_Poisson')