function spkTrain = PoissonSpikeGen(fr)
%   Returns a spike train of duration 0.32s and chosen frequency (fr, in Hz 
%   or equivalently 'spikes per second')
%   as a vector of spiking times
%
%   The code below is a modified version of the Poisson spike generator included 
%   in the lecture notes on neural coding by Naureen Ghani, 
%   available at http://www.columbia.edu/cu/appliedneuroshp/Fall2017/neuralcoding.pdf 
%
% Andrea Guidolin (11 Nov 2021)
%---------------------------------------------------

tSim = 0.32; % s, time of the simulation 
nTrials = 1;

dt = 1/10000000; % s,  width of the bins
nBins = floor(tSim/dt);
spikeMat = rand(nTrials , nBins) < fr*dt;
tVec = 0:dt:tSim -dt;

spkTrain = tVec(spikeMat);
end
