function corr_ind = modulus_metric_wrapper(spiketimes,sim_time)
% returns the modulus metric measure of synchrony as implemented in Rusu, C. V., & Florian, R. V. (2014). A new class of metrics for spike trains. Neural Computation, 26(2), 306–348. doi:10.1162/NECO_a_00545

n_neu=length(spiketimes);

corr_ind_mat=nan(n_neu);

for i_neu=1:n_neu
    if isempty(spiketimes(i_neu).t)
        continue
    end
    spikes_this_i=spiketimes(i_neu).t;
    for j_neu=(i_neu+1):n_neu % symmetric measure
        if isempty(spiketimes(j_neu).t)
            continue
        end
        % if i_neu~=j_neu
        spikes_this_j=spiketimes(j_neu).t;
        corr_ind_mat(i_neu,j_neu)=modulus_metric_mex(int32(length(spikes_this_i)),int32(length(spikes_this_j)),spikes_this_i,spikes_this_j,0,sim_time);
        % end
    end
end

corr_ind=nanmean(nanmean(corr_ind_mat));
