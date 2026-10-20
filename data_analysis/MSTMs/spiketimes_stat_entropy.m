function [en_ISI_vect,en_ISI]=spiketimes_stat_entropy(spiketimes)
% returns log ISI entropy of each neuron, and mean entropy across neurons (NaN for neurons with fewer than 2 ISIs)
n_neu=length(spiketimes);
en_ISI_vect=nan(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    log_isi_vect_this=log10(isi_vect_this);

    if length(log_isi_vect_this)>1
        en_ISI_vect(neu)=ISIentropy(log_isi_vect_this);
    end
end
en_ISI=mean(en_ISI_vect,'omitnan');
