function [cv_ISI_vect,cv_ISI]=spiketimes_stat_cv(spiketimes)
% returns ISI CV of each neuron, and mean CV across neurons (NaN for neurons with fewer than 2 ISIs)
n_neu=length(spiketimes);
cv_ISI_vect=nan(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    if length(isi_vect_this)>1
        cv_ISI_vect(neu)=std(isi_vect_this)./mean(isi_vect_this);
    end
end
cv_ISI=mean(cv_ISI_vect,'omitnan');
