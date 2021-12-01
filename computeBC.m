%Compute Betti curves for increasing/decreasing filtration of the original
%data and the four types of surrogate data
%
% Andrea Guidolin (11 Nov 2021)

load('VPM_80exp')
BCdecr_80exp = computeBCripser_fulldataset_decr(VPM_80exp);
save('BCdecr_80exp','BCdecr_80exp')
BCincr_80exp = computeBCripser_fulldataset_incr(VPM_80exp);
save('BCincr_80exp','BCincr_80exp')


load('VPM_shuf')
BCdecr_shuf = computeBCripser_fulldataset_decr(VPM_shuf);
save('BCdecr_shuf','BCdecr_shuf')
BCincr_shuf = computeBCripser_fulldataset_incr(VPM_shuf);
save('BCincr_shuf','BCincr_shuf')


load('VPM_Poisson')
BCdecr_Poisson = computeBCripser_fulldataset_decr(VPM_Poisson);
save('BCdecr_Poisson','BCdecr_Poisson')
BCincr_Poisson = computeBCripser_fulldataset_incr(VPM_Poisson);
save('BCincr_Poisson','BCincr_Poisson')


load('VPM_exchange')
BCdecr_exchange = computeBCripser_fulldataset_decr(VPM_exchange);
save('BCdecr_exchange','BCdecr_exchange')
BCincr_exchange = computeBCripser_fulldataset_incr(VPM_exchange);
save('BCincr_exchange','BCincr_exchange')


load('VPM_exchwithin')
BCdecr_exchwithin = computeBCripser_fulldataset_decr(VPM_exchwithin);
save('BCdecr_exchwithin','BCdecr_exchwithin')
BCincr_exchwithin = computeBCripser_fulldataset_incr(VPM_exchwithin);
save('BCincr_exchwithin','BCincr_exchwithin')
