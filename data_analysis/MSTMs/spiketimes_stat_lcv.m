function [lcv_ISI_vect,lcv_ISI]=spiketimes_stat_lcv(spiketimes)
% returns lcv ISI of each neuron, and lcv of ISIs pulling all ISIs together
n_neu=length(spiketimes);
log_isi_vect=[];
lcv_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    log_isi_vect_this=log10(isi_vect_this);
        
    lcv_ISI_vect(neu)=std(log_isi_vect_this)./mean(log_isi_vect_this);
    
    log_isi_vect=[log_isi_vect;log_isi_vect_this];        
end
lcv_ISI=std(log_isi_vect)./mean(log_isi_vect);