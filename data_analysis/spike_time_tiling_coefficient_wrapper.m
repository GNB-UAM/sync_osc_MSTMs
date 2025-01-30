function sttc = spike_time_tiling_coefficient_wrapper(spiketimes,sim_time,inct)
% returns Cutts 14's spike time tiling coefficient measure of synchrony

t_vect=0:inct:sim_time;
n_neu=length(spiketimes);

sttc_mat=nan(n_neu);

% spikeks=zeros(n_neu,length(t_vect)); % spike density
% var_spikeks=zeros(1,n_neu); % variance of the spike density across time for each neuron
for i_neu=1:n_neu
    spikes_this_i=spiketimes(i_neu).t;
    for j_neu=(i_neu+1):n_neu % symmetric measure
        % if i_neu~=j_neu
            spikes_this_j=spiketimes(j_neu).t;
            sttc_mat(i_neu,j_neu)=spike_time_tiling_coefficient_mex(int32(length(spikes_this_i)),int32(length(spikes_this_j)),inct,[0 sim_time],spikes_this_i,spikes_this_j);
        % end
    end
end

sttc=nanmean(nanmean(sttc_mat));

% mean_spikeks=mean(spikeks); % mean over neurons
%
% var_mean_spikeks=var(mean_spikeks); % variance over time
%
% golomb_sync=sqrt(var_mean_spikeks/mean(var_spikeks));