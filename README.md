# Top-spike
A collection of Matlab scripts and functions for topological analysis of spike train data.

This collection of Matlab scripts and functions accompanies the article  
Guidolin, A., Desroches, M., Victor, J. D., Purpura, K. P., & Rodrigues, S. (2022). *Geometry of spiking patterns in early visual cortex: a Topological Data Analytic approach.*

#### Select and organize the spike data
For a given dataset, select the 80 collection with the highest number of non-empty responses, for the 4 neurons firing the highest number of spikes. In each collection, the responses to the first 64 stimuli are considered, and at most one empty response is included (when present in the data).

Use the function **select_one0.m**, for example, for the dataset "L7301_TT1_btc_SPKTs".
Note that it uses the function **spikes_and_labels.m** to correctly extract spike times and labels identifying the different neurons in from the original data.

```matlab
filename = "L7301_TT1_btc_SPKTs";
n_resp = 64;      %number of neural reponses per collection
N_groups = 80;    %number of collections
N_select = 4;     %number of selected neurons
one0_SL = select_one0(filename, n_resp, N_groups, N_select);
```

#### Generate the Victor-Purpura distance matrices of a chosen dataset. Generate the surrogate data and their Victor-Purpura distance matrices.
Use the script **compute_surrogate_VPM.m** to compute the pairwise Victor-Purpura distances between spike trains of the experimental data and store them in matrices, for each parameter *q* and *k* of the Victor-Purpura distance in the chosen grid (*q*=1, 2, 5, 10, 20, 50, 100, 200; *k*=0, 1).
The function **computeVPMpara.m** is used to compute the Victor-Purpura matrices in parallel. It is based the function **labdist_faster_qkpara_opt.m** by Thomas Kreuz (based on code by Dmitriy Aronov) to compute the Victor-Purpura distance between spike trains, which is available at <http://www-users.med.cornell.edu/~jdvicto/labdist_faster_qkpara_opt.html>. We thank Thomas Kreuz for allowing us to include a copy of the function **labdist_faster_qkpara_opt.m** in this directory.

The script **compute_surrogate_VPM.m** also generates (20 times) the surrogate spike data of four different types: uniform resampling of spike times, exchange resampling between collections, exchange resampling within collections, Poisson generated spike trains. The following functions are necessary to generate the surrogate data from the “one0_SL” structure associated with one dataset:
**generate_shuffledSL_stats.m**  
**generate_exchangeSL_stats.m**  
**generate_exchwithinSL_stats.m**  
**generate_PoissonSL_stats.m**  
**compute_firingFr.m**  
**PoissonSpikeGen.m**  
The Victor-Purpura distance matrices are then computed, for each of the 20 computations of each type of surrogate data.

#### Computation of the Betti curves
For a fixed dataset (e.g., "L7301_TT1_btc_SPKTs"), the script **computeBC.m** computes all Betti curves, for increasing/decreasing filtrations, of the experimental data and the surrogate spike data. The input are the cell arrays of Victor-Purpura distance matrices computed in the previous step.
The following functions are called:  
**computeBCripser.m**  
**computeBCripser_fulldataset_incr.m**  
**computeBCripser_fulldataset_decr.m**  
The function computeBCripser.m relies on Ripser (<https://github.com/Ripser/ripser>) by Ulrich Bauer for fast computation of persistent homology. It is therefore necessary to obtain and build Ripser as described in its documentation. We also acknowledge that this function contains a portion of code adapted from a Matlab wrapper around Ripser by Chris Tralie, available at: <https://github.com/ctralie> (function called “RipsFiltrationDM.m”).The entries of the input distance matrix are enumerated increasingly/decreasingly to yield the Betti curves of the increasing/decreasing filtrations. 

The function **computeBCdatamatrix_edgedensity.m** is useful to compute average Betti curves. It uses **BC_rescale_edgedensity.m** to correctly align Betti curves.

#### Betti curves of random and geometric models

The script **computeBC_random_geom.m** computes *k*=300 times the Betti curves (associated with both the increasing and decreasing filtrations) of the following random and geometric models: Euclidean geometry model, hyperbolic geometry model, and random symmetric matrices with zeros on the main diagonal. For more details and different applications of these models, see the manuscript and the following articles:  
Giusti, C., Pastalkova, E., Curto, C., & Itskov, V. (2015). *Clique topology reveals intrinsic geometric structure in neural correlations.* Proceedings of the National Academy of Sciences, 112(44), 13455-13460, and   
Zhou, Y., Smith, B. H., & Sharpee, T. O. (2018). *Hyperbolic geometry of the olfactory space.* Science advances, 4(8), eaaq1458.

The functions used by the script **computeBC_random_geom.m** are the following:  
**compute_manyBC_eucl.m**  
**compute_manyBC_hyp.m**    
**compute_manyBC_randsym.m**    
**rand_points_Eucl_sym.m**  
**compute_Mdist_hyperbolic.m**  
**computeBCripser.m**  
