sttc_dir='/home/fabiano/libraries/Detecting_pairwise_correlations_in_spike_trains-master/';
sync_osc_dir='/home/fabiano/neuron/sync_osc/';

cd(sttc_dir)
mex spike_time_tiling_coefficient_mex.c % this does not recognize mxGetDoubles
% mex -R2018a spike_time_tiling_coefficient_mex.c
mex correlation_index_mex.c
cd(sync_osc_dir)