function [lcv_ISI_vect,lcv_ISI]=spiketimes_stat_lcv(spiketimes)
% returns lcv ISI of each neuron, and mean lcv across neurons (NaN for neurons with fewer than 2 ISIs)
% ISIs are taken in ms (lcv depends on the time unit)
n_neu=length(spiketimes);
lcv_ISI_vect=nan(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    log_isi_vect_this=log10(isi_vect_this);

    if length(log_isi_vect_this)>1
        lcv_ISI_vect(neu)=std(log_isi_vect_this)./mean(log_isi_vect_this);
    end
end
lcv_ISI=mean(lcv_ISI_vect,'omitnan');
