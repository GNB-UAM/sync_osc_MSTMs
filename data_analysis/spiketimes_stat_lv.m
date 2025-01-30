function [Lv_ISI_vect,Lv_ISI]=spiketimes_stat_lv(spiketimes)
% returns ISI Lv of each neuron, and mean Lv across neurons. Lv pulling all ISIs together is meaningless since these measures capture serial correlations
n_neu=length(spiketimes);
Lv_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);

    Lv_val=1-(4*isi_vect_this(2:end).*isi_vect_this(1:end-1))./((isi_vect_this(2:end)+isi_vect_this(1:end-1)).^2);
    Lv_ISI_vect(neu)=3*mean(Lv_val);
end
Lv_ISI=nanmean(Lv_ISI_vect);
