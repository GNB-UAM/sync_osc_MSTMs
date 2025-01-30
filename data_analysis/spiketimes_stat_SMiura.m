function [SM_ISI_vect,SM_ISI]=spiketimes_stat_SMiura(spiketimes)
% returns ISI SM of each neuron, and mean SM across neurons. SM pulling all ISIs together is meaningless since these measures capture serial correlations
% Miura, Keiji, Masato Okada, and Shun-ichi Amari. 2006. “Estimating Spiking Irregularities Under Changing Environments.” Neural Computation 18 (10): 2359–86. https://doi.org/10.1162/neco.2006.18.10.2359.
n_neu=length(spiketimes);
SM_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);

    SM_val=-log((4*isi_vect_this(2:end).*isi_vect_this(1:end-1))./((isi_vect_this(2:end)+isi_vect_this(1:end-1)).^2))./2;
    SM_ISI_vect(neu)=mean(SM_val);
end
SM_ISI=nanmean(SM_ISI_vect);
