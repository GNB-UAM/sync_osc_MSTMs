function [LvR_ISI_vect,LvR_ISI]=spiketimes_stat_lvr(spiketimes,t_refr)
% returns ISI LvR of each neuron, and mean LvR across neurons. LvR pulling all ISIs together is meaningless since these measures capture serial correlations
n_neu=length(spiketimes);
LvR_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);

    LvR_val=(1-(4*isi_vect_this(2:end).*isi_vect_this(1:end-1))./((isi_vect_this(2:end)+isi_vect_this(1:end-1)).^2)).*(1+(4*t_refr)./(isi_vect_this(2:end)+isi_vect_this(1:end-1)));
    LvR_ISI_vect(neu)=3*mean(LvR_val);
end
LvR_ISI=nanmean(LvR_ISI_vect);
